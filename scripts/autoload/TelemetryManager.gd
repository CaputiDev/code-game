## TelemetryManager.gd
## Collects, persists, and dispatches telemetry events for learning analytics.
##
## Design: offline-first.
##   1. Events are pushed to an in-memory queue.
##   2. The queue is flushed to disk immediately after each push.
##   3. On session start/end, the manager attempts an HTTP flush to the
##      configured API endpoint (empty = disabled until backend is ready).
##   4. Successfully dispatched events are removed from the queue.
extends Node

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

## REST API endpoint for telemetry. Leave empty until backend is ready.
## Can be overridden at runtime from a config file.
const CONFIG_PATH: String = "user://telemetry_config.json"
const QUEUE_PATH:  String = "user://telemetry_queue.json"

## Maximum events to hold in the queue before oldest are discarded.
const MAX_QUEUE_SIZE: int = 500

## When true, prints every event to the Godot output panel.
@export var debug_mode: bool = true

var _api_endpoint: String = ""
var _queue: Array[Dictionary] = []
var _http: HTTPRequest

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_load_config()
	_load_queue()
	_setup_http()

	# Connect to EventBus to capture events automatically.
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.player_attempt_failed.connect(_on_attempt_failed)
	EventBus.quiz_answered.connect(_on_quiz_answered)
	EventBus.quiz_completed.connect(_on_quiz_completed)
	EventBus.mechanic_activated.connect(_on_mechanic_activated)
	EventBus.bug_eliminated.connect(_on_bug_eliminated)

	# Attempt to flush leftover events from previous sessions.
	_try_flush()

	if debug_mode:
		print("[TelemetryManager] Ready. Endpoint: '%s'. Queue size: %d" \
			% [_api_endpoint if _api_endpoint != "" else "(not configured)", _queue.size()])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_persist_queue()
		_try_flush()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Pushes a custom event dictionary. [param event_type] is added automatically.
func push_event(event_type: String, payload: Dictionary) -> void:
	var event: Dictionary = {
		"event_type": event_type,
		"player_name": GameState.player_display_name,
		"player_uuid": GameState.player_uuid,
		"timestamp":   Time.get_datetime_string_from_system(true),
	}
	event.merge(payload)

	if debug_mode:
		print("[Telemetry] %s → %s" % [event_type, JSON.stringify(event)])

	_queue.append(event)
	if _queue.size() > MAX_QUEUE_SIZE:
		_queue.pop_front()

	_persist_queue()
	_try_flush()

## Returns a copy of the current event queue (for debugging / inspection).
func get_queue() -> Array[Dictionary]:
	return _queue.duplicate(true)

## Clears all queued events (does NOT delete persisted queue file).
func clear_queue() -> void:
	_queue.clear()

# ---------------------------------------------------------------------------
# EventBus handlers → event builders
# ---------------------------------------------------------------------------

func _on_level_completed(data: Dictionary) -> void:
	var elapsed: float = GameState.get_elapsed_seconds()
	var understood: bool = GameState.current_attempts <= 3

	push_event("level_complete", {
		"world":        data.get("world", GameState.current_world),
		"level":        data.get("level", GameState.current_level),
		"concept":      GameState.current_concept,
		"understood":   understood,
		"attempts":     GameState.current_attempts,
		"time_seconds": snappedf(elapsed, 0.1),
		"decisions":    GameState.current_decisions.duplicate(),
	})

func _on_attempt_failed(world: int, level: int) -> void:
	push_event("level_attempt_failed", {
		"world":        world,
		"level":        level,
		"concept":      GameState.current_concept,
		"attempt_number": GameState.current_attempts,
		"time_seconds": snappedf(GameState.get_elapsed_seconds(), 0.1),
	})

func _on_quiz_answered(data: Dictionary) -> void:
	push_event("quiz_answer", data)

func _on_quiz_completed(world: int, score: int, total: int) -> void:
	push_event("quiz_complete", {
		"world":   world,
		"score":   score,
		"total":   total,
		"passed":  score >= ceili(total * 0.66),
	})

func _on_mechanic_activated(mechanic_id: String, mechanic_type: String) -> void:
	push_event("mechanic_activated", {
		"world":         GameState.current_world,
		"level":         GameState.current_level,
		"mechanic_id":   mechanic_id,
		"mechanic_type": mechanic_type,
	})

func _on_bug_eliminated(bug_id: String, concept: String) -> void:
	push_event("bug_eliminated", {
		"world":   GameState.current_world,
		"level":   GameState.current_level,
		"bug_id":  bug_id,
		"concept": concept,
	})

# ---------------------------------------------------------------------------
# HTTP dispatch
# ---------------------------------------------------------------------------

func _setup_http() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

func _try_flush() -> void:
	if _api_endpoint == "" or _queue.is_empty():
		return
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return  # Already sending

	var batch: Array[Dictionary] = _queue.slice(0, mini(_queue.size(), 50))
	var body: String = JSON.stringify({ "events": batch })
	var headers: PackedStringArray = ["Content-Type: application/json"]

	var err: Error = _http.request(_api_endpoint, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		push_warning("[TelemetryManager] HTTP request failed: %s" % error_string(err))

func _on_request_completed(result: int, response_code: int,
		_headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code in [200, 201, 202, 204]:
		var sent_count: int = mini(_queue.size(), 50)
		_queue = _queue.slice(sent_count)
		_persist_queue()
		if debug_mode:
			print("[TelemetryManager] Flushed %d events. Remaining: %d" \
				% [sent_count, _queue.size()])
	else:
		push_warning("[TelemetryManager] Flush failed (HTTP %d). Events retained in queue." \
			% response_code)

# ---------------------------------------------------------------------------
# Persistence
# ---------------------------------------------------------------------------

func _persist_queue() -> void:
	var file := FileAccess.open(QUEUE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[TelemetryManager] Cannot write queue file.")
		return
	file.store_string(JSON.stringify({ "queue": _queue }, "\t"))
	file.close()

func _load_queue() -> void:
	if not FileAccess.file_exists(QUEUE_PATH):
		return
	var file := FileAccess.open(QUEUE_PATH, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_queue = json.data.get("queue", [])
	file.close()
	if debug_mode:
		print("[TelemetryManager] Loaded %d queued events from disk." % _queue.size())

func _load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_api_endpoint = json.data.get("api_endpoint", "")
	file.close()
