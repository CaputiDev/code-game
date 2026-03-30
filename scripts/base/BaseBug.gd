## BaseBug.gd
## Base class for all Bug enemies in CodeGame.
##
## Bugs are logical obstacles — they are NOT defeated by direct combat.
## Each bug defines its own elimination condition, which aligns with the
## programming concept being taught in the current level.
##
## Examples:
##   - World 1 Bug: eliminated when a ConditionalDoor's AND condition is met.
##   - World 2 Bug: eliminated when a VariableBlock counter reaches zero.
##   - World 3 Bug: eliminated when a loop's stop condition is satisfied.
##
## Subclasses override [evaluate_elimination_condition] to define their logic.
class_name BaseBug extends CharacterBody2D

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when this bug is eliminated.
signal eliminated(bug: BaseBug)

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## Unique ID for telemetry tracking.
@export var bug_id: String = ""

## The programming concept this bug is associated with.
@export var concept: String = ""

## How many tiles / pixels the bug patrols per cycle.
@export var patrol_range: float = 80.0

## Patrol movement speed in pixels per second.
@export var patrol_speed: float = 40.0

## How long the bug "glitches" before disappearing after elimination.
@export var elimination_delay: float = 0.6

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

const GRAVITY: float = 980.0
var _patrol_origin: Vector2
var _patrol_direction: float = 1.0
var _is_eliminated: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	add_to_group("bugs")
	if bug_id == "":
		bug_id = name
	_patrol_origin = global_position
	_on_bug_ready()

func _physics_process(delta: float) -> void:
	if _is_eliminated:
		return
	_patrol(delta)

## Virtual. Override for bug-specific setup.
func _on_bug_ready() -> void:
	pass

# ---------------------------------------------------------------------------
# Virtual interface
# ---------------------------------------------------------------------------

## Override to define when this bug is eliminated.
## Called each frame by external systems (e.g., ConditionalDoor, VariableBlock).
func evaluate_elimination_condition() -> bool:
	return false

## Override to define visual/audio effects on elimination.
func play_elimination_effect() -> void:
	pass

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Call this to check the condition and eliminate the bug if it is met.
func check_and_eliminate() -> void:
	if _is_eliminated:
		return
	if evaluate_elimination_condition():
		_start_elimination()

## Force-eliminates this bug (e.g., via debug skip).
func force_eliminate() -> void:
	_start_elimination()

# ---------------------------------------------------------------------------
# Patrol movement
# ---------------------------------------------------------------------------

func _patrol(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.x = patrol_speed * _patrol_direction

	var distance_traveled: float = abs(global_position.x - _patrol_origin.x)
	if distance_traveled >= patrol_range:
		_patrol_direction *= -1.0
		scale.x *= -1.0  # Flip sprite

	move_and_slide()

	# Reverse at walls or ledge edges.
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.5:
			_patrol_direction *= -1.0
			scale.x *= -1.0

# ---------------------------------------------------------------------------
# Elimination
# ---------------------------------------------------------------------------

func _start_elimination() -> void:
	_is_eliminated = true
	play_elimination_effect()
	EventBus.bug_eliminated.emit(bug_id, concept)
	EventBus.play_sfx.emit("bug_eliminated")

	# Glitch effect then disappear.
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, elimination_delay) \
		.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(_finish_elimination)

func _finish_elimination() -> void:
	eliminated.emit(self)
	queue_free()
