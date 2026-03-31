## Level1_3.gd
## World 1, Level 3 — "Os Dois Botões" (AND Logic)
##
## Two LogicButtons must BOTH be pressed to open the ConditionalDoor.
## A Bug blocks the path to one of the buttons until the player finds
## the correct approach path.
##
## Pedagogical objective:
##   Player experiences AND logic: both conditions must be true.
##
## Visual aid: the HUD shows a live truth table:
##   Botão A = [F/V]   Botão B = [F/V]   A E B = [F/V]
extends BaseLevel

@onready var _button_a: LogicButton   = $Mechanics/ButtonA
@onready var _button_b: LogicButton   = $Mechanics/ButtonB
@onready var _door: ConditionalDoor   = $Door
@onready var _bug: Bug                = $Enemies/Bug1
@onready var _truth_a: Label          = $HUD/TruthTable/ColA/Value
@onready var _truth_b: Label          = $HUD/TruthTable/ColB/Value
@onready var _truth_result: Label     = $HUD/TruthTable/ColResult/Value
@onready var _goal_area: Area2D       = $GoalArea

func _on_level_ready() -> void:
	world_index = 1
	level_index = 2
	concept     = "and"

	# Wire the door to both buttons with AND logic.
	_door.logic_mode = ConditionalDoor.LogicMode.AND

	# Link bug to door — bug disappears when door opens.
	if _bug:
		_bug.linked_mechanic_path = _bug.get_path_to(_door)

	_button_a.state_changed.connect(func(_s): _update_truth_table())
	_button_b.state_changed.connect(func(_s): _update_truth_table())

	if _goal_area:
		_goal_area.body_entered.connect(_on_goal_reached)

	_update_truth_table()

func _update_truth_table() -> void:
	var a: bool = _button_a.is_active
	var b: bool = _button_b.is_active
	var result: bool = a and b

	_truth_a.text      = "Verdadeiro" if a else "Falso"
	_truth_b.text      = "Verdadeiro" if b else "Falso"
	_truth_result.text = "Verdadeiro" if result else "Falso"

	_truth_a.modulate      = Color.GREEN if a else Color.RED
	_truth_b.modulate      = Color.GREEN if b else Color.RED
	_truth_result.modulate = Color.GREEN if result else Color.RED

func _on_goal_reached(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	complete_level()
