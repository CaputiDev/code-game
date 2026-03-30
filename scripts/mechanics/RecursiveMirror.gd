## RecursiveMirror.gd
## A mirror that spawns a visual echo of the player, recursively diminishing,
## until a configurable depth (base case / stop condition) is reached.
##
## Educational concept: recursion — a function that calls itself until a
## base condition is met.
##
## Visual metaphor:
##   The player stands in front of the mirror. A smaller echo appears,
##   which has its own smaller echo, and so on, until depth = 0.
##   The player sets the "depth" (max_depth) via a VariableBlock nearby,
##   then approaches the mirror to trigger the recursion.
##
## Puzzle application:
##   Only when depth == puzzle_target_depth does the mirror unlock a door.
class_name RecursiveMirror extends BaseMechanic

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when the full recursive chain is rendered.
signal recursion_complete(depth_reached: int)

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export_group("Recursion Settings")

## The current recursion depth. Set by a VariableBlock or Inspector.
@export var current_depth: int = 3

## Maximum allowed depth.
@export var max_depth: int = 5

## The depth required to solve the puzzle (unlock connected door).
@export var puzzle_target_depth: int = 3

## Scale factor for each recursive echo (< 1 = smaller each level).
@export var echo_scale_factor: float = 0.65

## Horizontal offset between echoes.
@export var echo_offset: Vector2 = Vector2(48.0, 0.0)

@export_group("Visuals")

## The sprite texture for the player echo.
@export var player_echo_texture: Texture2D

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _echo_container: Node2D = $EchoContainer
@onready var _depth_label: Label = $DepthLabel
@onready var _target_label: Label = $TargetLabel

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_ready() -> void:
	mechanic_type   = "recursive_mirror"
	concept         = "recursion"
	hint_pseudocode = "funcao espelhar(prof):\n  se (prof == 0): retorna\n  mostrar_eco(prof)\n  espelhar(prof - 1)"

	_refresh_labels()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Sets the recursion depth and re-renders the echo chain.
func set_depth(depth: int) -> void:
	current_depth = clampi(depth, 0, max_depth)
	_refresh_labels()
	_render_echoes()
	refresh()  # Re-evaluate condition.

## Called when the player steps in front of the mirror (proximity trigger).
func on_player_interact(_player: Node) -> void:
	_render_echoes()
	GameState.record_decision("mirror_depth:%d" % current_depth)
	EventBus.show_concept_hint.emit(concept, hint_pseudocode)

# ---------------------------------------------------------------------------
# BaseMechanic overrides
# ---------------------------------------------------------------------------

func evaluate_condition() -> bool:
	return current_depth == puzzle_target_depth

func on_activate() -> void:
	recursion_complete.emit(current_depth)

# ---------------------------------------------------------------------------
# Recursive echo rendering
# ---------------------------------------------------------------------------

func _render_echoes() -> void:
	# Clear previous echoes.
	for child in _echo_container.get_children():
		child.queue_free()

	if current_depth <= 0:
		return

	_spawn_echo(0, current_depth, Vector2.ZERO, 1.0)

## Recursive function that spawns echo sprites.
func _spawn_echo(current: int, remaining: int, offset: Vector2, scale_val: float) -> void:
	if remaining <= 0:
		return  # Base case — stop condition reached.

	var echo := Sprite2D.new()
	echo.texture = player_echo_texture
	echo.position = offset
	echo.scale = Vector2(scale_val, scale_val)
	echo.modulate = Color(1.0, 1.0, 1.0, 0.85 - (current * 0.12))
	_echo_container.add_child(echo)

	# Animate echo appearing.
	echo.modulate.a = 0.0
	var tween := echo.create_tween()
	tween.tween_property(echo, "modulate:a",
		0.85 - (current * 0.12), 0.15).set_delay(current * 0.08)

	# Recurse: spawn the next echo at the next offset with reduced scale.
	_spawn_echo(
		current + 1,
		remaining - 1,
		offset + echo_offset * scale_val,
		scale_val * echo_scale_factor
	)

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

func _refresh_labels() -> void:
	if _depth_label:
		_depth_label.text = "prof = %d" % current_depth
	if _target_label:
		_target_label.text = "alvo = %d" % puzzle_target_depth
