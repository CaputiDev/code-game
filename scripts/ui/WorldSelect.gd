## WorldSelect.gd
## World selection screen. Shows all worlds with lock/unlock status.
extends Control

@onready var _world_buttons: Array[Button] = []
@onready var _back_button: Button = %BackButton
@onready var _worlds_container: GridContainer = %WorldsContainer
@onready var _title_label: Label = %TitleLabel

const MAX_COLUMNS: int = 3

const WORLD_KEYS: Array[Array] = [
	["WORLD_0_NAME", "WORLD_0_DESC", 0],
	["WORLD_1_NAME", "WORLD_1_DESC", 1],
	["WORLD_2_NAME", "WORLD_2_DESC", 2],
	["WORLD_3_NAME", "WORLD_3_DESC", 3],
	["WORLD_4_NAME", "WORLD_4_DESC", 4],
	["WORLD_5_NAME", "WORLD_5_DESC", 5],
]

## First level scene path per world (index 0).
const WORLD_START_SCENES: Array[String] = [
	"res://scenes/world/World0/Level0_1.tscn",
	"res://scenes/world/World1/Level1_1.tscn",
	"res://scenes/world/World2/Level2_1.tscn",
	"res://scenes/world/World3/Level3_1.tscn",
	"res://scenes/world/World4/Level4_1.tscn",
	"res://scenes/world/World5/Level5_1.tscn",
]

func _ready() -> void:
	if _worlds_container:
		_worlds_container.columns = MAX_COLUMNS

	if _title_label:
		_title_label.text = tr("MENU_WORLD_SELECT")

	# Clear any placeholders
	for child in _worlds_container.get_children():
		child.queue_free()

	# Create cards with a slight delay for animation
	for i in WORLD_KEYS.size():
		var entry = WORLD_KEYS[i]
		var world_idx: int = entry[2]
		var card := _create_world_card(entry)
		_worlds_container.add_child(card)
		
		# Entry animation: Fade in
		card.modulate.a = 0
		var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_interval(i * 0.1)
		tween.tween_property(card, "modulate:a", 1.0, 0.4)

	if _back_button:
		_back_button.text = "← " + tr("LEVEL_COMPLETE_MENU")
		_back_button.pressed.connect(func():
			EventBus.play_sfx.emit("ui_click")
			get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
		)

func _create_world_card(entry: Array) -> Control:
	var world_idx: int = entry[2]
	var unlocked: bool = world_idx <= GameState.highest_unlocked_world
	var is_developed: bool = world_idx == 2
	
	var btn := Button.new()
	btn.name = entry[0]
	btn.custom_minimum_size = Vector2(320, 180)
	btn.clip_contents = true
	
	if not unlocked:
		btn.disabled = true
		btn.text = tr("WORLD_LOCKED")
		return btn
		
	if not is_developed:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 1.0)
		
	# Outer layout
	var main_margin := MarginContainer.new()
	main_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_margin.add_theme_constant_override("margin_left", 15)
	main_margin.add_theme_constant_override("margin_top", 10)
	main_margin.add_theme_constant_override("margin_bottom", 10)
	btn.add_child(main_margin)
	
	var vbox_card := VBoxContainer.new()
	vbox_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_margin.add_child(vbox_card)
	
	# Top: Name
	var name_label := Label.new()
	name_label.text = tr(entry[0])
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox_card.add_child(name_label)
	
	# Middle: Description (Filling space)
	var desc_label := Label.new()
	desc_label.text = tr(entry[1])
	if not is_developed:
		desc_label.text = "Em desenvolvimento...\n\n" + desc_label.text
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.modulate = Color(0.7, 0.8, 1.0, 0.8)
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.size_flags_vertical = SIZE_EXPAND_FILL
	vbox_card.add_child(desc_label)
	
	# Bottom: Stats (Stars and Quiz)
	var stats_hbox := HBoxContainer.new()
	stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox_card.add_child(stats_hbox)
	
	var star_data := GameState.get_world_star_stats(world_idx)
	var stars_label := Label.new()
	stars_label.text = "⭐ %d/%d" % [star_data.earned, star_data.possible]
	stars_label.add_theme_font_size_override("font_size", 16)
	stats_hbox.add_child(stars_label)
	
	var quiz_score: int = GameState.quiz_scores.get(world_idx, -1)
	if quiz_score >= 0:
		var spacer := Control.new()
		spacer.custom_minimum_size.x = 20
		stats_hbox.add_child(spacer)
		
		var quiz_label := Label.new()
		var percentage: float = (float(quiz_score) / 5.0) * 100.0
		quiz_label.text = "Quiz: %d%%" % int(percentage)
		quiz_label.modulate = Color(0.6, 1.0, 0.6)
		quiz_label.add_theme_font_size_override("font_size", 12)
		stats_hbox.add_child(quiz_label)
	
	if is_developed:
		btn.pressed.connect(func(): _on_world_selected(world_idx))
		
		# Hover effect
		btn.mouse_entered.connect(func():
			var tween := create_tween().set_parallel(true)
			tween.tween_property(btn, "custom_minimum_size:y", 190.0, 0.2)
			tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.3, 1.0), 0.2)
		)
		btn.mouse_exited.connect(func():
			var tween := create_tween().set_parallel(true)
			tween.tween_property(btn, "custom_minimum_size:y", 180.0, 0.2)
			tween.tween_property(btn, "modulate", Color.WHITE, 0.2)
		)
	
	return btn

func _on_world_selected(world: int) -> void:
	EventBus.play_sfx.emit("ui_click")
	
	var scene := WORLD_START_SCENES[world]
	if not ResourceLoader.exists(scene):
		_show_coming_soon()
		return
		
	GameState.current_world = world
	# Transition effect
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene))

func _show_coming_soon() -> void:
	if _title_label:
		var old_text = _title_label.text
		_title_label.text = "Em desenvolvimento..."
		_title_label.modulate = Color.YELLOW
		create_tween().tween_interval(1.5).finished.connect(func():
			_title_label.text = old_text
			_title_label.modulate = Color.WHITE
		)
