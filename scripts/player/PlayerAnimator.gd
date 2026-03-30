## PlayerAnimator.gd
## Manages player animations based on the state machine in PlayerController.
## Decoupled from the controller — receives state updates via play_state().
##
## Expected AnimationPlayer animation names:
##   "idle", "run", "jump", "fall", "interact", "dead"
class_name PlayerAnimator extends Node

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D

## Squash and stretch intensity on land.
@export var squash_amount: float = 0.15

## Stretch intensity on jump.
@export var stretch_amount: float = 0.12

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _current_anim: String = ""

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Called by PlayerController when the state changes.
func play_state(new_state: PlayerController.State) -> void:
	var anim: String = _state_to_anim(new_state)
	if anim == _current_anim:
		return
	_current_anim = anim

	if animation_player and animation_player.has_animation(anim):
		animation_player.play(anim)

	# Micro-animation: squash / stretch
	match new_state:
		PlayerController.State.JUMP:
			_stretch()
		PlayerController.State.IDLE:
			_reset_scale()

## Applies a land squash effect (call from a signal upon landing).
func play_land_squash() -> void:
	_squash()

# ---------------------------------------------------------------------------
# Squash & Stretch helpers
# ---------------------------------------------------------------------------

func _squash() -> void:
	if sprite == null:
		return
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale",
		Vector2(1.0 + squash_amount, 1.0 - squash_amount), 0.05)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1) \
		.set_trans(Tween.TRANS_SPRING)

func _stretch() -> void:
	if sprite == null:
		return
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale",
		Vector2(1.0 - stretch_amount, 1.0 + stretch_amount), 0.06)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.08) \
		.set_trans(Tween.TRANS_SPRING)

func _reset_scale() -> void:
	if sprite:
		sprite.scale = Vector2.ONE

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _state_to_anim(s: PlayerController.State) -> String:
	match s:
		PlayerController.State.IDLE:    return "idle"
		PlayerController.State.RUN:     return "run"
		PlayerController.State.JUMP:    return "jump"
		PlayerController.State.FALL:    return "fall"
		PlayerController.State.INTERACT:return "interact"
		PlayerController.State.DEAD:    return "dead"
	return "idle"
