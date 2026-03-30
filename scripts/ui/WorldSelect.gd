## WorldSelect.gd
## World selection screen. Shows all worlds with lock/unlock status.
extends Control

@onready var _world_buttons: Array[Button] = []
@onready var _back_button: Button = %BackButton
@onready var _worlds_container: VBoxContainer = %WorldsContainer
@onready var _title_label: Label = %TitleLabel

const WORLD_KEYS: Array[Array] = [
	["WORLD_0_NAME", "WORLD_0_DESC", 0],
	["WORLD_1_NAME", "WORLD_1_DESC", 1],
	["WORLD_2_NAME", "WORLD_2_DESC", 2],
	["WORLD_3_NAME", "WORLD_3_DESC", 3],
]

## First level scene path per world (index 0).
const WORLD_START_SCENES: Array[String] = [
	"res://scenes/world/World0/Level0_1.tscn",
	"res://scenes/world/World1/Level1_1.tscn",
	"res://scenes/world/World2/Level2_1.tscn",
	"res://scenes/world/World3/Level3_1.tscn",
]

func _ready() -> void:
	if _title_label:
		_title_label.text = tr("MENU_WORLD_SELECT")

	for entry in WORLD_KEYS:
		var world_idx: int = entry[2]
		var btn := Button.new()
		btn.size_flags_horizontal = SIZE_EXPAND_FILL
		var unlocked: bool = world_idx <= GameState.highest_unlocked_world
		if unlocked:
			btn.text = tr(entry[0]) + "\n" + tr(entry[1])
		else:
			btn.text = tr("WORLD_LOCKED")
			btn.disabled = true
		btn.pressed.connect(func(): _on_world_selected(world_idx))
		_worlds_container.add_child(btn)
		_world_buttons.append(btn)

	if _back_button:
		_back_button.text = "← Voltar"
		_back_button.pressed.connect(func():
			EventBus.play_sfx.emit("ui_click")
			get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
		)

func _on_world_selected(world: int) -> void:
	EventBus.play_sfx.emit("ui_click")
	GameState.current_world = world
	var scene := WORLD_START_SCENES[world]
	if ResourceLoader.exists(scene):
		get_tree().change_scene_to_file(scene)
	else:
		push_warning("[WorldSelect] Scene not found: %s" % scene)
