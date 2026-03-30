## VariableBlock.gd
## An interactive element that represents a variable in memory.
##
## Educational concept: variables, assignment, arithmetic operations.
##
## The block displays its current value and can be incremented, decremented,
## or set to a specific value by player interaction or by other mechanics.
## When the value reaches a target, it emits [condition_met].
##
## Example usage in Level 2-1:
##   - Player collects 3 energy orbs → each orb calls increment().
##   - When value == target_value, a ConditionalDoor opens.
class_name VariableBlock extends BaseMechanic

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when the variable's value reaches [target_value].
signal condition_met()

## Emitted on every value change.
signal value_changed(old_val: int, new_val: int)

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Variable")

## Display name for this variable (shown in HUD and hint).
@export var var_name: String = "counter"

## Starting value.
@export var initial_value: int = 0

## Target value that triggers [condition_met].
@export var target_value: int = 3

## If true, the condition triggers when value == target_value.
## If false, it triggers when value >= target_value.
@export var exact_match: bool = false

## Operation performed when the player interacts directly.
## Collectibles and triggers can call increment/decrement directly.
enum Operation { INCREMENT, DECREMENT, RESET }
@export var interact_operation: Operation = Operation.INCREMENT

@export_group("Visuals")
@export var show_value_label: bool = true
@export var show_progress_bar: bool = true

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _value_label: Label = $ValueLabel
@onready var _progress_bar: ProgressBar = $ProgressBar
@onready var _var_name_label: Label = $VarNameLabel
@onready var _sprite: Sprite2D = $Sprite2D

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _current_value: int = 0

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

var current_value: int:
	get: return _current_value

func increment(amount: int = 1) -> void:
	_set_value(_current_value + amount)

func decrement(amount: int = 1) -> void:
	_set_value(_current_value - amount)

func set_value(new_value: int) -> void:
	_set_value(new_value)

func reset() -> void:
	_set_value(initial_value)

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_ready() -> void:
	mechanic_type   = "variable_block"
	concept         = "variable"
	hint_pseudocode = "%s ← %d\n%s ← %s + 1" % [var_name, initial_value, var_name, var_name]

	_current_value = initial_value
	_refresh_ui()

# ---------------------------------------------------------------------------
# Interaction
# ---------------------------------------------------------------------------

func on_player_interact(_player: Node) -> void:
	match interact_operation:
		Operation.INCREMENT: increment()
		Operation.DECREMENT: decrement()
		Operation.RESET:     reset()
	GameState.record_decision("variable_interact:%s=%d" % [var_name, _current_value])

# ---------------------------------------------------------------------------
# BaseMechanic overrides
# ---------------------------------------------------------------------------

func evaluate_condition() -> bool:
	if exact_match:
		return _current_value == target_value
	return _current_value >= target_value

# ---------------------------------------------------------------------------
# Internal value update
# ---------------------------------------------------------------------------

func _set_value(new_val: int) -> void:
	var old_val: int = _current_value
	if old_val == new_val:
		return

	_current_value = new_val
	value_changed.emit(old_val, new_val)
	EventBus.variable_changed.emit(var_name, old_val, new_val)
	EventBus.play_sfx.emit("variable_change")

	_refresh_ui()
	_animate_change()

	if evaluate_condition():
		is_active = true
		condition_met.emit()

# ---------------------------------------------------------------------------
# UI refresh
# ---------------------------------------------------------------------------

func _refresh_ui() -> void:
	if _value_label and show_value_label:
		_value_label.text = str(_current_value)
		_value_label.visible = true
	elif _value_label:
		_value_label.visible = false

	if _progress_bar and show_progress_bar:
		_progress_bar.max_value = target_value
		_progress_bar.value = _current_value
		_progress_bar.visible = true
	elif _progress_bar:
		_progress_bar.visible = false

	if _var_name_label:
		_var_name_label.text = "%s = %d" % [var_name, _current_value]

# ---------------------------------------------------------------------------
# Micro-animation
# ---------------------------------------------------------------------------

func _animate_change() -> void:
	if not _value_label:
		return
	var tween := _value_label.create_tween()
	tween.tween_property(_value_label, "scale", Vector2(1.4, 1.4), 0.07)
	tween.tween_property(_value_label, "scale", Vector2.ONE, 0.12) \
		.set_trans(Tween.TRANS_SPRING)
