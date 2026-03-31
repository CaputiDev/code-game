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
var quiz_scores: Dictionary = { 0: -1, 1: -1, 2: -1, 3: -1, 4: -1, 5: -1 }

## Dict mapping "world_level" string keys to star count (0-3).
## e.g. { "0_1": 3, "1_1": 0 }
var star_counts: Dictionary = {}

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
		highest_unlocked_world = mini(world + 1, 5)

## Bulk unlocks content after the initial assessment.
func unlock_content_by_assessment(passed_worlds: Array[int]) -> void:
	# Always start at world 0.
	highest_unlocked_world = 0
	
	if passed_worlds.is_empty():
		unlocked_levels[0] = 0
		return
		
	var max_passed: int = passed_worlds.max()
	highest_unlocked_world = clampi(max_passed + 1, 0, 5)
	
	# Unlock all levels for worlds that were "passed".
	# For simplicity, we assume each world has a fixed number of levels (e.g. 5).
	# This avoids having to check every scene.
	for w in range(highest_unlocked_world + 1):
		unlocked_levels[w] = 5 # Mark as having reached level 5 (all unlocked)
		# Initialize stars as 0 for all levels in unlocked worlds.
		for l in range(6):
			var key: String = "%d_%d" % [w, l]
			if not star_counts.has(key):
				star_counts[key] = 0

## Updates star count for a specific level.
func set_level_stars(world: int, level: int, stars: int) -> void:
	var key: String = "%d_%d" % [world, level]
	var current: int = star_counts.get(key, 0)
	star_counts[key] = max(current, stars)

## Returns an array of star counts for all levels in a world.
func get_world_stars_list(world_idx: int) -> Array[int]:
	var stars: Array[int] = []
	for key in star_counts.keys():
		if key.begins_with("%d_" % world_idx):
			stars.append(star_counts[key])
	return stars

## Returns total stars earned vs total possible for a world.
func get_world_star_stats(world_idx: int, levels_in_world: int = 5) -> Dictionary:
	var list := get_world_stars_list(world_idx)
	var earned := 0
	for s in list:
		earned += s
	return {
		"earned": earned,
		"possible": levels_in_world * 3
	}

# ---------------------------------------------------------------------------
# Reset (for testing / new game)
# ---------------------------------------------------------------------------

func reset_progress() -> void:
	highest_unlocked_world = 0
	unlocked_levels = {}
	quiz_scores = { 0: -1, 1: -1, 2: -1, 3: -1, 4: -1, 5: -1 }
	current_attempts = 0
	current_decisions.clear()
