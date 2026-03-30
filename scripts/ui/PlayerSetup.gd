## PlayerSetup.gd
## Screen shown on first boot to collect the player's name and surname.
## After confirmation, creates a UUID, saves to disk, and transitions
## to the main menu.
class_name PlayerSetup extends Control

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _first_name_input: LineEdit = $Panel/VBox/FirstNameInput
@onready var _last_name_input: LineEdit  = $Panel/VBox/LastNameInput
@onready var _confirm_button: Button     = $Panel/VBox/ConfirmButton
@onready var _error_label: Label         = $Panel/VBox/ErrorLabel
@onready var _welcome_label: Label       = $Panel/VBox/WelcomeLabel

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_error_label.visible = false
	_welcome_label.text  = tr("SETUP_WELCOME")
	_first_name_input.placeholder_text = tr("SETUP_FIRST_NAME_PLACEHOLDER")
	_last_name_input.placeholder_text  = tr("SETUP_LAST_NAME_PLACEHOLDER")
	_confirm_button.text = tr("SETUP_CONFIRM")

	_confirm_button.pressed.connect(_on_confirm_pressed)
	_first_name_input.text_submitted.connect(func(_t): _last_name_input.grab_focus())
	_last_name_input.text_submitted.connect(func(_t): _on_confirm_pressed())

	_first_name_input.grab_focus()

# ---------------------------------------------------------------------------
# Confirmation
# ---------------------------------------------------------------------------

func _on_confirm_pressed() -> void:
	var first: String = _first_name_input.text.strip_edges()
	var last: String  = _last_name_input.text.strip_edges()

	if first.length() < 2:
		_show_error("Por favor, insira um nome válido.")
		_first_name_input.grab_focus()
		return
	if last.length() < 2:
		_show_error("Por favor, insira um sobrenome válido.")
		_last_name_input.grab_focus()
		return

	# Commit player profile.
	GameState.player_first_name = first
	GameState.player_last_name  = last
	GameState.player_uuid       = SaveManager.generate_uuid()

	EventBus.player_profile_set.emit(GameState.player_display_name)
	EventBus.play_sfx.emit("ui_click")
	SaveManager.save()

	# Animate out → transition to main menu.
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
	)

func _show_error(message: String) -> void:
	_error_label.text = message
	_error_label.visible = true
	var tween := _error_label.create_tween()
	tween.tween_property(_error_label, "modulate:a", 1.0, 0.0)
	tween.tween_property(_error_label, "modulate:a", 0.0, 2.0).set_delay(2.0)
	tween.tween_callback(func(): _error_label.visible = false)
