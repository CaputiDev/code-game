## BaseLevel.gd
## Base class for all playable levels in CodeGame.
##
## Provides:
##   - Automatic attempt counting and timing.
##   - Level completion detection and telemetry dispatch.
##   - Player death / reset handling.
##   - Debug skip shortcut (F1 key, debug_skip_level action).
##   - Concept-of-the-level metadata for HUD and telemetry.
##
## Usage:
##   Attach to the root node of any Level*.tscn.
##   Set [world_index], [level_index], and [concept] in the Inspector.
##   Call [complete_level] from a trigger area or goal node.
class_name BaseLevel extends Node

# ---------------------------------------------------------------------------
# Exports — set per-level in Inspector
# ---------------------------------------------------------------------------

## Which world this level belongs to (0 = intro, 1–3 = concept worlds).
@export var world_index: int = 0

## Level index within the world (0-based).
@export var level_index: int = 0

## Programming concept taught in this level (matches i18n key suffix).
## e.g. "if", "else", "and", "or", "variable", "function", "loop", "recursion"
@export var concept: String = ""

## Path to the next level scene, relative to "res://".
## Leave empty to show WorldQuiz or WorldSelect after completion.
@export_file("*.tscn") var next_level_path: String = ""

## Whether debug skip (F1) is allowed. Disable in release builds.
@export var allow_debug_skip: bool = true

# ---------------------------------------------------------------------------
# Node references (assign in subclass or autodetect by group)
# ---------------------------------------------------------------------------

## Spawn point for the player. Tag a Node2D with group "player_spawn".
@onready var _spawn_point: Node2D = _find_by_group("player_spawn")

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------

var _level_completed: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Announce level start to all listeners.
	EventBus.level_started.emit(world_index, level_index, concept)
	print("[BaseLevel] World %d / Level %d — Concept: %s" \
		% [world_index, level_index, concept])
	_on_level_ready()

func _input(event: InputEvent) -> void:
	if allow_debug_skip and event.is_action_pressed("debug_skip_level"):
		print("[BaseLevel] DEBUG: Skipping level.")
		complete_level()

## Virtual. Override for level-specific _ready logic.
func _on_level_ready() -> void:
	pass

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Call this when the player reaches the goal / exit of the level.
func complete_level() -> void:
	if _level_completed:
		return
	_level_completed = true

	var elapsed := GameState.get_elapsed_seconds()
	var data := {
		"world":        world_index,
		"level":        level_index,
		"concept":      concept,
		"attempts":     GameState.current_attempts,
		"time_seconds": snappedf(elapsed, 0.1),
		"decisions":    GameState.current_decisions.duplicate(),
	}

	EventBus.level_completed.emit(data)
	EventBus.play_sfx.emit("level_complete")
	SaveManager.save()

	await get_tree().create_timer(0.5).timeout
	_go_to_next()

## Call this when the player falls into a pit, hits a bug, or resets.
func fail_attempt() -> void:
	if _level_completed:
		return
	EventBus.player_attempt_failed.emit(world_index, level_index)
	await get_tree().create_timer(0.3).timeout
	_respawn_player()

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------

func _go_to_next() -> void:
	if next_level_path != "":
		get_tree().change_scene_to_file("res://" + next_level_path)
	else:
		# Show level-complete screen, which will offer quiz or world select.
		get_tree().change_scene_to_file("res://scenes/menus/LevelComplete.tscn")

func _respawn_player() -> void:
	# Signal any child nodes tagged with "player" to teleport to spawn.
	var players := get_tree().get_nodes_in_group("player")
	for player in players:
		if player.has_method("respawn"):
			if _spawn_point:
				player.respawn(_spawn_point.global_position)
			else:
				player.respawn(Vector2.ZERO)

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _find_by_group(group_name: String) -> Node2D:
	var nodes := get_tree().get_nodes_in_group(group_name)
	if nodes.size() > 0:
		return nodes[0] as Node2D
	return null
