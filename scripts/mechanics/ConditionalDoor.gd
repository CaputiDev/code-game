## ConditionalDoor.gd
## A door that opens or closes based on a configurable boolean logic condition
## applied to a set of connected LogicButton inputs.
##
## Educational concept: if/else, AND, OR operators.
##
## Inspector setup:
##   1. Set [logic_mode] to AND or OR.
##   2. Drag LogicButton nodes into the [input_buttons] array.
##   3. The door refreshes automatically when any connected button changes.
##
## The door also works as a "wall" for Bug obstacles — bugs cannot pass
## through a closed door, forcing the player to meet the condition.
class_name ConditionalDoor extends BaseMechanic

# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

enum LogicMode { AND, OR, XOR, SINGLE }

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Logic")

## The boolean operator applied to all connected button inputs.
@export var logic_mode: LogicMode = LogicMode.AND

## Connected LogicButton nodes. Wire these in the Inspector.
@export var input_buttons: Array[NodePath] = []

@export_group("Movement")

## If true, the door slides open. If false, it fades.
@export var slide_open: bool = true

## Direction and distance the door slides when open.
@export var slide_offset: Vector2 = Vector2(0.0, -80.0)

## Duration of the open/close animation in seconds.
@export var animation_duration: float = 0.35

@export_group("Visuals")

## Sprite for the closed state.
@export var sprite_closed: Texture2D

## Sprite for the open state.
@export var sprite_open: Texture2D

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

## Visual node — Polygon2D for prototype, Sprite2D when art is added.
## Name it "Visual" in the scene.
@onready var _visual: Node2D            = get_node_or_null("Visual")
## Collision lives inside a child StaticBody2D named "DoorBody".
@onready var _collision: CollisionShape2D = $DoorBody/CollisionShape2D
@onready var _condition_label: Label    = $ConditionLabel  # Shows "AND" / "OR"

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _resolved_buttons: Array[LogicButton] = []
var _closed_position: Vector2

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_ready() -> void:
	mechanic_type   = "conditional_door"
	concept         = _concept_for_mode()
	hint_pseudocode = _pseudocode_for_mode()

	_closed_position = position

	# Resolve NodePaths to actual LogicButton nodes.
	for path in input_buttons:
		var node := get_node_or_null(path)
		if node is LogicButton:
			_resolved_buttons.append(node as LogicButton)
			(node as LogicButton).state_changed.connect(_on_input_changed)
		else:
			push_warning("[ConditionalDoor] %s: input at path '%s' is not a LogicButton." \
				% [mechanic_id, path])

	if _condition_label:
		_condition_label.text = LogicMode.keys()[logic_mode]

	refresh()  # Evaluate initial state.

# ---------------------------------------------------------------------------
# BaseMechanic overrides
# ---------------------------------------------------------------------------

func evaluate_condition() -> bool:
	if _resolved_buttons.is_empty():
		return false

	match logic_mode:
		LogicMode.AND:
			for btn in _resolved_buttons:
				if not btn.is_active:
					return false
			return true

		LogicMode.OR:
			for btn in _resolved_buttons:
				if btn.is_active:
					return true
			return false

		LogicMode.XOR:
			var active_count: int = 0
			for btn in _resolved_buttons:
				if btn.is_active:
					active_count += 1
			return active_count == 1

		LogicMode.SINGLE:
			return _resolved_buttons[0].is_active if _resolved_buttons.size() > 0 else false

	return false

func on_activate() -> void:
	EventBus.play_sfx.emit("door_open")
	EventBus.door_state_changed.emit(mechanic_id, true)
	_animate_open()

func on_deactivate() -> void:
	EventBus.door_state_changed.emit(mechanic_id, false)
	_animate_close()

# ---------------------------------------------------------------------------
# Input change handler
# ---------------------------------------------------------------------------

func _on_input_changed(_active: bool) -> void:
	refresh()

# ---------------------------------------------------------------------------
# Animation
# ---------------------------------------------------------------------------

func _animate_open() -> void:
	_set_collision_enabled(false)
	# Tint visual green while open.
	if _visual is Polygon2D: (_visual as Polygon2D).color = Color(0.2, 0.8, 0.2, 1)
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if slide_open:
		tween.tween_property(self, "position",
			_closed_position + slide_offset, animation_duration)
	elif _visual:
		tween.tween_property(_visual, "modulate:a", 0.0, animation_duration)

func _animate_close() -> void:
	if _visual is Polygon2D: (_visual as Polygon2D).color = Color(0.8, 0.2, 0.2, 1)
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	if slide_open:
		tween.tween_property(self, "position", _closed_position, animation_duration)
	elif _visual:
		tween.tween_property(_visual, "modulate:a", 1.0, animation_duration)
	tween.tween_callback(func(): _set_collision_enabled(true))

func _set_collision_enabled(enabled: bool) -> void:
	if _collision:
		_collision.disabled = not enabled

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _concept_for_mode() -> String:
	match logic_mode:
		LogicMode.AND: return "and"
		LogicMode.OR:  return "or"
		LogicMode.XOR: return "xor"
	return "if"

func _pseudocode_for_mode() -> String:
	match logic_mode:
		LogicMode.AND:
			return "if (button_a AND button_b):\n    door.open()"
		LogicMode.OR:
			return "if (button_a OR button_b):\n    door.open()"
		LogicMode.XOR:
			return "if (button_a XOR button_b):\n    door.open()"
		LogicMode.SINGLE:
			return "if (button_pressed):\n    door.open()\nelse:\n    door.close()"
	return ""
