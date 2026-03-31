## SaveManager.gd
## Handles serialization and deserialization of all persistent game data
## to a JSON save file stored in the user's data directory.
## Uses a versioned schema to support future migrations.
extends Node

const SAVE_PATH: String = "user://save_data.json"

func _ready() -> void:
	load_save()
const SAVE_VERSION: int = 1

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Saves the current GameState to disk. Returns true on success.
func save() -> bool:
	var data: Dictionary = _serialize()
	var json_string: String = JSON.stringify(data, "\t")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Could not open save file for writing: %s" % SAVE_PATH)
		return false

	file.store_string(json_string)
	file.close()
	print("[SaveManager] Game saved to %s" % SAVE_PATH)
	return true

## Loads save data from disk into GameState. Returns true if a save was found.
func load_save() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found — starting fresh.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Could not open save file for reading.")
		return false

	var json_string: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		push_error("[SaveManager] Failed to parse save file: %s" % json.get_error_message())
		return false

	_deserialize(json.data)
	print("[SaveManager] Save loaded. Player: %s" % GameState.player_display_name)
	return true

## Deletes the save file (new game / reset).
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
		print("[SaveManager] Save file deleted.")

## Returns true if a save file exists on disk.
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# ---------------------------------------------------------------------------
# Serialization helpers
# ---------------------------------------------------------------------------

func _serialize() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"player": {
			"first_name": GameState.player_first_name,
			"last_name": GameState.player_last_name,
			"uuid": GameState.player_uuid,
		},
		"progression": {
			"highest_unlocked_world": GameState.highest_unlocked_world,
			"unlocked_levels": GameState.unlocked_levels,
			"quiz_scores": GameState.quiz_scores,
		}
	}

func _deserialize(data: Dictionary) -> void:
	# Version migration hook — extend here for future schema changes.
	var version: int = data.get("version", 0)
	if version < SAVE_VERSION:
		data = _migrate(data, version)

	var player: Dictionary = data.get("player", {})
	GameState.player_first_name = player.get("first_name", "")
	GameState.player_last_name  = player.get("last_name", "")
	GameState.player_uuid       = player.get("uuid", "")

	var prog: Dictionary = data.get("progression", {})
	GameState.highest_unlocked_world = prog.get("highest_unlocked_world", 0)
	
	# Dictionary keys are ints but JSON deserializes them as strings.
	var raw_levels: Dictionary = prog.get("unlocked_levels", {})
	var unlocked_levels: Dictionary = {}
	for k in raw_levels.keys():
		unlocked_levels[int(k)] = raw_levels[k]
	GameState.unlocked_levels = unlocked_levels

	# quiz_scores keys are ints but JSON deserializes them as strings.
	var raw_quiz: Dictionary = prog.get("quiz_scores", {})
	var quiz_scores: Dictionary = {}
	for k in raw_quiz.keys():
		quiz_scores[int(k)] = raw_quiz[k]
	GameState.quiz_scores = quiz_scores

# ---------------------------------------------------------------------------
# Migration
# ---------------------------------------------------------------------------

## Migrates older save schemas to the current version.
func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	print("[SaveManager] Migrating save from version %d to %d" % [from_version, SAVE_VERSION])
	# Add migration steps here as the schema evolves.
	return data

# ---------------------------------------------------------------------------
# UUID generation
# ---------------------------------------------------------------------------

## Generates a new random UUID v4 string.
## Called once on first boot if no save exists.
func generate_uuid() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var hex_chars: String = "0123456789abcdef"
	var uuid_parts: PackedStringArray = []
	var lengths: Array[int] = [8, 4, 4, 4, 12]
	for length in lengths:
		var part: String = ""
		for i in range(length):
			part += hex_chars[rng.randi() % 16]
		uuid_parts.append(part)
	return "-".join(uuid_parts)
