## FunctionPortal.gd
## A portal that lets the player record a sequence of actions and replay them.
##
## Educational concept: functions — a named, reusable block of instructions.
##
## Usage in Level 2-3:
##   1. Player steps on the RECORD zone → actions are captured.
##   2. Player steps on the EXECUTE zone → recorded sequence replays.
##   3. Puzzle requires the correct sequence to solve a challenge.
##
## In Godot Editor: place two child Area2D nodes tagged as "record_zone"
## and "execute_zone" groups, or assign via exported NodePaths.
class_name FunctionPortal extends BaseMechanic

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when the player starts recording.
signal recording_started()

## Emitted when recording is stopped and the sequence is saved.
signal recording_saved(actions: Array[String])

## Emitted when the recorded function begins execution.
signal execution_started()

## Emitted when execution is complete.
signal execution_finished()

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Function Settings")

## Maximum number of actions to record. Prevents infinite sequences.
@export var max_actions: int = 8

## Name of this function (displayed on the portal).
@export var function_name: String = "my_function"

## If true, the portal auto-executes on re-entry without re-recording.
@export var auto_execute_on_enter: bool = false

@export_group("Node References")
@export var record_zone_path: NodePath
@export var execute_zone_path: NodePath

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _record_zone: Area2D  = get_node_or_null(record_zone_path)
@onready var _execute_zone: Area2D = get_node_or_null(execute_zone_path)
@onready var _name_label: Label    = $FunctionNameLabel
@onready var _sequence_label: Label = $SequenceLabel
@onready var _sprite: Sprite2D     = $Sprite2D

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

enum PortalState { IDLE, RECORDING, READY, EXECUTING }

var _portal_state: PortalState = PortalState.IDLE
var _recorded_actions: Array[String] = []
var _is_recording: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_ready() -> void:
	mechanic_type   = "function_portal"
	concept         = "function"
	hint_pseudocode = "funcao %s():\n    acao_1()\n    acao_2()\n    acao_3()" % function_name

	if _name_label:
		_name_label.text = "%s()" % function_name

	if _record_zone:
		_record_zone.body_entered.connect(_on_record_zone_entered)
		_record_zone.body_exited.connect(_on_record_zone_exited)

	if _execute_zone:
		_execute_zone.body_entered.connect(_on_execute_zone_entered)

	_refresh_sequence_label()

# ---------------------------------------------------------------------------
# Recording
# ---------------------------------------------------------------------------

## Call this to record a player action into the sequence.
## Typically called by the PlayerController when in the record zone.
func record_action(action: String) -> void:
	if not _is_recording:
		return
	if _recorded_actions.size() >= max_actions:
		push_warning("[FunctionPortal] Max action limit reached.")
		return
	_recorded_actions.append(action)
	_refresh_sequence_label()
	GameState.record_decision("function_record:%s:%s" % [function_name, action])

func _on_record_zone_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_is_recording = true
	_recorded_actions.clear()
	_portal_state = PortalState.RECORDING
	recording_started.emit()
	EventBus.show_concept_hint.emit(concept, hint_pseudocode)

func _on_record_zone_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_is_recording = false
	if _recorded_actions.size() > 0:
		_portal_state = PortalState.READY
		recording_saved.emit(_recorded_actions.duplicate())
		EventBus.function_recorded.emit(mechanic_id, _recorded_actions.size())

# ---------------------------------------------------------------------------
# Execution
# ---------------------------------------------------------------------------

func _on_execute_zone_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if _portal_state == PortalState.READY or auto_execute_on_enter:
		execute()

## Executes the recorded action sequence.
## In a full implementation, this drives an AI-controlled "ghost" player
## or directly manipulates mechanics based on the recorded action list.
func execute() -> void:
	if _portal_state == PortalState.EXECUTING:
		return
	if _recorded_actions.is_empty():
		return

	_portal_state = PortalState.EXECUTING
	execution_started.emit()
	EventBus.function_executed.emit(mechanic_id)
	EventBus.play_sfx.emit("function_execute")
	is_active = true

	# Emit each action with a small delay to visualize the sequence.
	for action in _recorded_actions:
		await get_tree().create_timer(0.4).timeout
		_execute_action(action)

	await get_tree().create_timer(0.3).timeout
	_portal_state = PortalState.READY
	execution_finished.emit()

func _execute_action(action: String) -> void:
	# Actions are string keys. Subclasses or level scripts connect to
	# execution_started / execution_finished and listen for specific keys.
	# This keeps FunctionPortal generic and level-agnostic.
	print("[FunctionPortal] Executing action: %s" % action)

# ---------------------------------------------------------------------------
# BaseMechanic overrides
# ---------------------------------------------------------------------------

func evaluate_condition() -> bool:
	return _portal_state == PortalState.READY or _portal_state == PortalState.EXECUTING

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

func _refresh_sequence_label() -> void:
	if not _sequence_label:
		return
	if _recorded_actions.is_empty():
		_sequence_label.text = "[ vazio ]"
	else:
		_sequence_label.text = "\n".join(_recorded_actions)
