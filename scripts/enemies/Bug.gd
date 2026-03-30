## Bug.gd
## World 1 specific Bug — eliminated when a ConditionalDoor's condition is met.
##
## Wire a ConditionalDoor (or any BaseMechanic) to [linked_mechanic_path]
## in the Inspector. When that mechanic activates, this bug is eliminated.
class_name Bug extends BaseBug

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## Path to the mechanic whose activation eliminates this bug.
@export var linked_mechanic_path: NodePath

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _sprite: Sprite2D        = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _linked_mechanic: BaseMechanic = null

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_bug_ready() -> void:
	concept = "if"

	if linked_mechanic_path:
		_linked_mechanic = get_node_or_null(linked_mechanic_path)
		if _linked_mechanic:
			_linked_mechanic.activated.connect(_on_mechanic_activated)
		else:
			push_warning("[Bug] '%s': linked mechanic not found at path: %s" \
				% [bug_id, linked_mechanic_path])

	# Also watch for body enter to warn player.
	var area := $HitArea as Area2D
	if area:
		area.body_entered.connect(_on_body_entered)

# ---------------------------------------------------------------------------
# Condition
# ---------------------------------------------------------------------------

func evaluate_elimination_condition() -> bool:
	if _linked_mechanic:
		return _linked_mechanic.is_active
	return false

func _on_mechanic_activated() -> void:
	check_and_eliminate()

# ---------------------------------------------------------------------------
# Player collision (gentle: no instant death in tutorial worlds)
# ---------------------------------------------------------------------------

func _on_body_entered(body: Node) -> void:
	if _is_eliminated:
		return
	if body.is_in_group("player") and body.has_method("on_bug_collision"):
		body.on_bug_collision()

# ---------------------------------------------------------------------------
# Elimination effect
# ---------------------------------------------------------------------------

func play_elimination_effect() -> void:
	if _animation_player and _animation_player.has_animation("glitch"):
		_animation_player.play("glitch")
	# Shake the sprite.
	if _sprite:
		var tween := _sprite.create_tween().set_loops(3)
		tween.tween_property(_sprite, "position:x", 4.0, 0.05)
		tween.tween_property(_sprite, "position:x", -4.0, 0.05)
		tween.tween_property(_sprite, "position:x", 0.0, 0.05)
