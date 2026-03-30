## LogicButton.gd
## A pressable button or lever that emits a boolean state signal.
##
## Educational concept: boolean values, input conditions.
## When the player interacts with this button, it toggles or pulses its state.
##
## Connects to ConditionalDoor.add_input() to drive AND/OR logic.
class_name LogicButton extends BaseMechanic

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Behavior")

## If true, the button toggles on each press. If false, it is a momentary
## pulse (active for [pulse_duration] seconds then resets).
@export var is_toggle: bool = true

## Seconds the button stays active when in pulse mode.
@export var pulse_duration: float = 3.0

## Initial state of the button.
@export var starts_active: bool = false

@export_group("Visuals")

## Sprite shown when the button is active.
@export var sprite_active: Texture2D

## Sprite shown when the button is inactive.
@export var sprite_inactive: Texture2D

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

## Visual node — Polygon2D for prototype, Sprite2D when art is added.
@onready var _visual: Node2D  = get_node_or_null("Visual")
@onready var _label: Label    = $Label
@onready var _pulse_timer: Timer = $PulseTimer

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted every time the button changes state.
## [param active] is the new state.
signal state_changed(active: bool)

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_ready() -> void:
	mechanic_type = "logic_button"
	concept       = "if"
	hint_pseudocode = "if (button_pressed):\n    execute_action()"

	if starts_active:
		is_active = true

	_pulse_timer.timeout.connect(_on_pulse_timeout)

	# Auto-connect this button's InteractionArea to nearby players.
	var area := get_node_or_null("InteractionArea") as Area2D
	if area:
		area.body_entered.connect(func(body: Node2D) -> void:
			if body.has_method("set_nearby_interactable"):
				body.set_nearby_interactable(self)
		)
		area.body_exited.connect(func(body: Node2D) -> void:
			if body.has_method("clear_nearby_interactable"):
				body.clear_nearby_interactable(self)
		)

	_update_visuals()

# ---------------------------------------------------------------------------
# Interaction (called by PlayerController)
# ---------------------------------------------------------------------------

func on_player_interact(_player: Node) -> void:
	EventBus.play_sfx.emit("button_press")
	GameState.record_decision("button_pressed:%s" % mechanic_id)

	if is_toggle:
		is_active = not is_active
	else:
		is_active = true
		_pulse_timer.start(pulse_duration)

	state_changed.emit(is_active)
	_update_visuals()

# ---------------------------------------------------------------------------
# BaseMechanic overrides
# ---------------------------------------------------------------------------

func evaluate_condition() -> bool:
	return is_active

func on_activate() -> void:
	_update_visuals()
	_animate_press()

func on_deactivate() -> void:
	_update_visuals()

# ---------------------------------------------------------------------------
# Pulse timer
# ---------------------------------------------------------------------------

func _on_pulse_timeout() -> void:
	is_active = false
	state_changed.emit(false)
	_update_visuals()

# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------

func _update_visuals() -> void:
	if _visual is Polygon2D:
		(_visual as Polygon2D).color = Color(1.0, 0.9, 0.0, 1) if is_active else Color(0.4, 0.4, 0.4, 1)
	if _label:
		_label.text = "ON" if is_active else "OFF"

func _animate_press() -> void:
	if not _visual:
		return
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(0.85, 0.85), 0.05)
	tween.tween_property(_visual, "scale", Vector2.ONE, 0.1) \
		.set_trans(Tween.TRANS_SPRING)
