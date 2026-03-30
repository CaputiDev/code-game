## GameState.gd
## Global game state singleton. Tracks the current player session,
## progression, and in-level runtime state.
## This is the single source of truth for mutable game data.
extends Node

# ---------------------------------------------------------------------------
# Player profile
# ---------------------------------------------------------------------------

## Player's first name, set on first boot.
var player_first_name: String = ""

## Player's last name, set on first boot.
var player_last_name: String = ""

## Returns the full display name.
var player_display_name: String:
	get:
		return ("%s %s" % [player_first_name, player_last_name]).strip_edges()

## Unique identifier generated once per installation.
var player_uuid: String = ""

# ---------------------------------------------------------------------------
# Progression
# ---------------------------------------------------------------------------

## Index of the highest unlocked world (0 = intro, 1–3 = concept worlds).
var highest_unlocked_world: int = 0

## Dict mapping world index → highest unlocked level index.
## e.g. { 0: 2, 1: 1 }
var unlocked_levels: Dictionary = {}

## Dict mapping world index → quiz score.
## -1 means quiz not yet attempted.
var quiz_scores: Dictionary = { 0: -1, 1: -1, 2: -1, 3: -1 }

# ---------------------------------------------------------------------------
# Current session / level
# ---------------------------------------------------------------------------

## World index currently being played.
var current_world: int = 0

## Level index currently being played.
var current_level: int = 0

## The programming concept associated with the current level.
var current_concept: String = ""

## Number of attempts on the current level (resets per level load).
var current_attempts: int = 0

## Timestamp when the current level started (Engine.get_ticks_msec()).
var _level_start_ticks: int = 0

## Accumulated decisions/actions taken in the current level.
var current_decisions: Array[String] = []

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Connect to EventBus to track level events automatically.
	EventBus.level_started.connect(_on_level_started)
	EventBus.player_attempt_failed.connect(_on_attempt_failed)
	EventBus.level_completed.connect(_on_level_completed)

# ---------------------------------------------------------------------------
# Level tracking
# ---------------------------------------------------------------------------

func _on_level_started(world: int, level: int, concept: String) -> void:
	current_world = world
	current_level = level
	current_concept = concept
	current_attempts = 1
	current_decisions.clear()
	_level_start_ticks = Time.get_ticks_msec()

func _on_attempt_failed(_world: int, _level: int) -> void:
	current_attempts += 1
	current_decisions.clear()
	_level_start_ticks = Time.get_ticks_msec()

func _on_level_completed(_data: Dictionary) -> void:
	_unlock_next(current_world, current_level)

## Records an in-level decision string (used for telemetry path tracking).
func record_decision(decision: String) -> void:
	current_decisions.append(decision)

## Returns elapsed seconds since the current attempt started.
func get_elapsed_seconds() -> float:
	return (Time.get_ticks_msec() - _level_start_ticks) / 1000.0

# ---------------------------------------------------------------------------
# Progression helpers
# ---------------------------------------------------------------------------

## Marks a level as completed and unlocks the next one.
func _unlock_next(world: int, level: int) -> void:
	if not unlocked_levels.has(world):
		unlocked_levels[world] = 0
	if level >= unlocked_levels[world]:
		unlocked_levels[world] = level + 1
	# Unlock next world after last level (configurable per world)
	# WorldConfig is defined in WorldConfig.gd (resource)

## Returns true if a given world/level combination is unlocked.
func is_level_unlocked(world: int, level: int) -> bool:
	if world > highest_unlocked_world:
		return false
	if not unlocked_levels.has(world):
		return world == 0 and level == 0
	return level <= unlocked_levels[world]

## Records a quiz result for a world.
func record_quiz_score(world: int, score: int) -> void:
	quiz_scores[world] = score
	# Unlock next world on first quiz completion
	if score >= 0 and world == highest_unlocked_world:
		highest_unlocked_world = mini(world + 1, 3)

# ---------------------------------------------------------------------------
# Reset (for testing / new game)
# ---------------------------------------------------------------------------

func reset_progress() -> void:
	highest_unlocked_world = 0
	unlocked_levels = {}
	quiz_scores = { 0: -1, 1: -1, 2: -1, 3: -1 }
	current_attempts = 0
	current_decisions.clear()
