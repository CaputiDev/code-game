## PlayerController.gd
## Platformer player controller for CodeGame.
##
## Handles movement, jumping, interaction, and state management.
## Intentionally has NO combat mechanics — interaction is the primary action.
## Death/reset is triggered by falling off the world or colliding with a Bug.
##
## States:
##   IDLE, RUN, JUMP, FALL, INTERACT, DEAD
class_name PlayerController extends CharacterBody2D

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when the player presses the interact button near an interactable.
signal interacted(target: Node)

## Emitted when the player dies (falls or hits a bug).
signal died()

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Movement")
@export var move_speed: float = 200.0
@export var jump_velocity: float = -420.0
@export var coyote_time: float = 0.1       # seconds after leaving ledge still can jump
@export var jump_buffer_time: float = 0.1  # seconds before landing jump is registered

@export_group("References")
@export var animator: PlayerAnimator

# ---------------------------------------------------------------------------
# State machine
# ---------------------------------------------------------------------------

enum State { IDLE, RUN, JUMP, FALL, INTERACT, DEAD }

var state: State = State.IDLE:
	set(value):
		if value == state:
			return
		_on_state_exit(state)
		state = value
		_on_state_enter(state)

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

const GRAVITY: float = 980.0

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _nearby_interactable: Node = null
var _facing_right: bool = true

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	add_to_group("player")
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_apply_gravity(delta)
	_handle_coyote(delta)
	_handle_jump_buffer(delta)
	_process_horizontal_input()
	_process_jump_input()
	move_and_slide()
	_update_state()
	_check_death()

func _input(event: InputEvent) -> void:
	if state == State.DEAD:
		return
	if event.is_action_pressed("interact"):
		_try_interact()
	if event.is_action_pressed("pause"):
		EventBus.game_paused.emit()

# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _handle_coyote(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

func _handle_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

func _process_horizontal_input() -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed
	if direction > 0.0:
		_facing_right = true
		scale.x = 1.0
	elif direction < 0.0:
		_facing_right = false
		scale.x = -1.0

func _process_jump_input() -> void:
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		EventBus.play_sfx.emit("player_jump")

	# Variable-height jump: release early to jump lower.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

# ---------------------------------------------------------------------------
# State transitions
# ---------------------------------------------------------------------------

func _update_state() -> void:
	match state:
		State.DEAD, State.INTERACT:
			return  # Managed externally.

	if is_on_floor():
		if absf(velocity.x) > 5.0:
			state = State.RUN
		else:
			state = State.IDLE
	else:
		if velocity.y < 0.0:
			state = State.JUMP
		else:
			state = State.FALL

func _on_state_enter(new_state: State) -> void:
	match new_state:
		State.FALL:
			pass  # land sfx will be played on floor collision
	if animator:
		animator.play_state(new_state)

func _on_state_exit(old_state: State) -> void:
	match old_state:
		State.FALL:
			if is_on_floor():
				EventBus.play_sfx.emit("player_land")

# ---------------------------------------------------------------------------
# Interaction
# ---------------------------------------------------------------------------

func _try_interact() -> void:
	if _nearby_interactable and _nearby_interactable.has_method("on_player_interact"):
		state = State.INTERACT
		_nearby_interactable.on_player_interact(self)
		GameState.record_decision("interact:%s" % _nearby_interactable.name)
		await get_tree().create_timer(0.2).timeout
		state = State.IDLE
		interacted.emit(_nearby_interactable)

## Called by InteractionArea (Area2D child) when an interactable enters range.
func set_nearby_interactable(node: Node) -> void:
	_nearby_interactable = node

## Called by InteractionArea when an interactable leaves range.
func clear_nearby_interactable(node: Node) -> void:
	if _nearby_interactable == node:
		_nearby_interactable = null

# ---------------------------------------------------------------------------
# Death
# ---------------------------------------------------------------------------

func _check_death() -> void:
	# Kill zone: fall below the camera view.
	if global_position.y > get_viewport_rect().size.y + 200.0:
		_die()

## Called by Bug collision or kill zones.
func on_bug_collision() -> void:
	_die()

func _die() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	died.emit()
	# BaseLevel listens to this group via get_nodes_in_group("player")
	# and calls fail_attempt() from its own fail_attempt method.
	var level := _find_base_level()
	if level:
		level.fail_attempt()

# ---------------------------------------------------------------------------
# Respawn (called by BaseLevel)
# ---------------------------------------------------------------------------

func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	state = State.IDLE
	modulate = Color.WHITE

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _find_base_level() -> BaseLevel:
	var node: Node = get_parent()
	while node:
		if node is BaseLevel:
			return node as BaseLevel
		var script = node.get_script()
		if script and script.get_global_name() == "BaseLevel":
			return node
		node = node.get_parent()
	return null
