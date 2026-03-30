## AudioManager.gd
## Centralized audio manager with SFX pooling and music crossfading.
## Listens to EventBus.play_sfx / play_music / stop_music signals.
extends Node

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

## Master volume for music (0.0 – 1.0).
@export var music_volume: float = 0.7

## Master volume for SFX (0.0 – 1.0).
@export var sfx_volume: float = 1.0

## Number of SFX players in the pool.
const SFX_POOL_SIZE: int = 8

## Crossfade duration in seconds.
const CROSSFADE_DURATION: float = 1.0

# ---------------------------------------------------------------------------
# Sound banks
## Map of logical key → resource path.
## Populated from the file system; override or extend as assets are added.
# ---------------------------------------------------------------------------

const MUSIC_BANK: Dictionary = {
	"main_menu":  "res://assets/audio/music/main_menu.ogg",
	"world_0":    "res://assets/audio/music/world_0.ogg",
	"world_1":    "res://assets/audio/music/world_1.ogg",
	"world_2":    "res://assets/audio/music/world_2.ogg",
	"world_3":    "res://assets/audio/music/world_3.ogg",
	"quiz":       "res://assets/audio/music/quiz.ogg",
}

const SFX_BANK: Dictionary = {
	"button_press":       "res://assets/audio/sfx/button_press.ogg",
	"door_open":          "res://assets/audio/sfx/door_open.ogg",
	"door_locked":        "res://assets/audio/sfx/door_locked.ogg",
	"variable_change":    "res://assets/audio/sfx/variable_change.ogg",
	"function_execute":   "res://assets/audio/sfx/function_execute.ogg",
	"bug_eliminated":     "res://assets/audio/sfx/bug_eliminated.ogg",
	"level_complete":     "res://assets/audio/sfx/level_complete.ogg",
	"quiz_correct":       "res://assets/audio/sfx/quiz_correct.ogg",
	"quiz_wrong":         "res://assets/audio/sfx/quiz_wrong.ogg",
	"player_jump":        "res://assets/audio/sfx/player_jump.ogg",
	"player_land":        "res://assets/audio/sfx/player_land.ogg",
	"concept_hint_show":  "res://assets/audio/sfx/hint_show.ogg",
	"ui_click":           "res://assets/audio/sfx/ui_click.ogg",
}

# ---------------------------------------------------------------------------
# Internal nodes
# ---------------------------------------------------------------------------

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index: int = 0

var _current_music_key: String = ""

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_build_music_players()
	_build_sfx_pool()

	# Connect to EventBus.
	EventBus.play_sfx.connect(play_sfx)
	EventBus.play_music.connect(play_music)
	EventBus.stop_music.connect(stop_music)

	print("[AudioManager] Ready. SFX pool size: %d" % SFX_POOL_SIZE)

# ---------------------------------------------------------------------------
# Music API
# ---------------------------------------------------------------------------

## Plays background music by key. Crossfades if already playing.
func play_music(key: String) -> void:
	if key == _current_music_key:
		return
	if not MUSIC_BANK.has(key):
		push_warning("[AudioManager] Unknown music key: '%s'" % key)
		return

	var stream: AudioStream = _load_stream(MUSIC_BANK[key])
	if stream == null:
		return

	_current_music_key = key
	var next_player: AudioStreamPlayer = \
		_music_player_b if _active_music_player == _music_player_a else _music_player_a

	next_player.stream = stream
	next_player.volume_db = linear_to_db(0.0)
	next_player.play()

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(next_player, "volume_db",
		linear_to_db(music_volume), CROSSFADE_DURATION)
	if _active_music_player != null and _active_music_player.playing:
		tween.tween_property(_active_music_player, "volume_db",
			linear_to_db(0.0), CROSSFADE_DURATION)
		var old := _active_music_player
		tween.tween_callback(old.stop).set_delay(CROSSFADE_DURATION)

	_active_music_player = next_player

## Stops the current music with a fade-out.
func stop_music() -> void:
	if _active_music_player == null or not _active_music_player.playing:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_active_music_player, "volume_db",
		linear_to_db(0.0), CROSSFADE_DURATION)
	tween.tween_callback(_active_music_player.stop)
	_current_music_key = ""

# ---------------------------------------------------------------------------
# SFX API
# ---------------------------------------------------------------------------

## Plays a sound effect by key using the pool (fire-and-forget).
func play_sfx(key: String) -> void:
	if not SFX_BANK.has(key):
		push_warning("[AudioManager] Unknown SFX key: '%s'" % key)
		return

	var stream: AudioStream = _load_stream(SFX_BANK[key])
	if stream == null:
		return

	var player: AudioStreamPlayer = _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % SFX_POOL_SIZE

	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume)
	player.play()

# ---------------------------------------------------------------------------
# Volume control
# ---------------------------------------------------------------------------

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	if _active_music_player and _active_music_player.playing:
		_active_music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _build_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_b = AudioStreamPlayer.new()
	for p in [_music_player_a, _music_player_b]:
		p.bus = "Music"
		add_child(p)
	_active_music_player = _music_player_a

func _build_sfx_pool() -> void:
	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

func _load_stream(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] Audio file not found: '%s'" % path)
		return null
	return load(path)
