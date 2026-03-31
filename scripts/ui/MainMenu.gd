## MainMenu.gd
## Main menu controller. Shows the game title, player name greeting,
## and navigation options.
extends Control

@onready var _world_select_button: Button = %WorldSelectButton
@onready var _settings_button: Button    = %SettingsButton
@onready var _quit_button: Button        = %QuitButton
@onready var _greeting_label: Label      = %GreetingLabel
@onready var _title_label: Label         = %TitleLabel

func _ready() -> void:
	# First-boot guard: redirect if player hasn't registered yet.
	if GameState.player_first_name.is_empty():
		get_tree().change_scene_to_file("res://scenes/menus/PlayerSetup.tscn")
		return

	EventBus.play_music.emit("main_menu")

	_title_label.text    = "CodeGame"
	_greeting_label.text = "Olá, %s!" % GameState.player_display_name

	_world_select_button.text = tr("MENU_WORLD_SELECT")
	_settings_button.text     = tr("MENU_SETTINGS")
	_quit_button.text         = tr("MENU_QUIT")

	_world_select_button.pressed.connect(_on_world_select_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	_animate_in()

func _on_play_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	# Continue from last unlocked level.
	var world: int = GameState.highest_unlocked_world
	var level: int = GameState.unlocked_levels.get(world, 0)
	var scene: String = "res://scenes/world/World%d/Level%d_%d.tscn" % [world, world, level]
	if ResourceLoader.exists(scene):
		get_tree().change_scene_to_file(scene)
	else:
		get_tree().change_scene_to_file("res://scenes/menus/WorldSelect.tscn")

func _on_world_select_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	get_tree().change_scene_to_file("res://scenes/menus/WorldSelect.tscn")

func _on_quit_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	get_tree().quit()

func _animate_in() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
