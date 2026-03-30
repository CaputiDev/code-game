## LevelComplete.gd
## Screen shown after successfully completing a level.
## Displays time, attempt count, and a star rating.
## Reads result data from GameState and the last level_completed event.
class_name LevelComplete extends Control

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _title_label: Label    = %TitleLabel
@onready var _time_label: Label     = %TimeLabel
@onready var _attempts_label: Label = %AttemptsLabel
@onready var _stars_container: HBoxContainer = %StarsContainer
@onready var _next_button: Button   = %NextButton
@onready var _retry_button: Button  = %RetryButton
@onready var _menu_button: Button   = %MenuButton

# ---------------------------------------------------------------------------
# Internal (populated by store_result before scene change)
# ---------------------------------------------------------------------------

## Call this BEFORE changing scene to pass result data.
static var _last_result: Dictionary = {}

static func store_result(data: Dictionary) -> void:
	_last_result = data

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	EventBus.play_music.emit("quiz")  # Soft congratulatory track
	_populate_ui()
	_animate_in()

	_next_button.pressed.connect(_on_next_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)

func _populate_ui() -> void:
	_title_label.text = tr("LEVEL_COMPLETE_TITLE")
	_next_button.text  = tr("LEVEL_COMPLETE_NEXT")
	_retry_button.text = tr("LEVEL_COMPLETE_RETRY")
	_menu_button.text  = tr("LEVEL_COMPLETE_MENU")

	var time_s: float = _last_result.get("time_seconds", 0.0)
	var quiz_score: int = _last_result.get("quiz_score", 0)
	var quiz_total: int = _last_result.get("quiz_total", 5)
	var stars: int = _last_result.get("stars", 0)

	_time_label.text     = tr("LEVEL_COMPLETE_TIME") % _format_time(time_s)
	_attempts_label.text = "Acertos no Quiz: %d/%d" % [quiz_score, quiz_total]

	_display_stars(stars)

	# If next level doesn't exist, hide next button.
	if _last_result.get("next_level_path", "") == "":
		_next_button.visible = false

func _display_stars(count: int) -> void:
	for i in _stars_container.get_children():
		i.queue_free()
	for i in range(3):
		var star := Label.new()
		star.text = "⭐" if i < count else "☆"
		star.add_theme_font_size_override("font_size", 32)
		_stars_container.add_child(star)

func _format_time(seconds: float) -> String:
	var minutes: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

# ---------------------------------------------------------------------------
# Buttons
# ---------------------------------------------------------------------------

func _on_next_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	var next: String = _last_result.get("next_level_path", "")
	if next != "":
		get_tree().change_scene_to_file("res://" + next)
	else:
		get_tree().change_scene_to_file("res://scenes/menus/WorldSelect.tscn")

func _on_retry_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	var cur_scene: String = _last_result.get("scene_path", "")
	if cur_scene != "":
		get_tree().change_scene_to_file("res://" + cur_scene)

func _on_menu_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	get_tree().change_scene_to_file("res://scenes/menus/WorldSelect.tscn")

# ---------------------------------------------------------------------------
# Entrance animation
# ---------------------------------------------------------------------------

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
