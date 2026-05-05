## Level2_1.gd
## Mundo 2, Fase 1 — "A Primeira Condição"
##
## The player must collect a key, then interact with the door.
## The door opens ONLY if (has_key == true).
##
## Pedagogical objective:
##   Player experiences the simplest possible if statement:
##   "IF you have the key, THEN the door opens."
##
## Telemetry tracks:
##   - Whether the player tried the door without the key (common mistake).
##   - How many attempts before understanding the condition.
extends BaseLevel

# ---------------------------------------------------------------------------
# Level nodes (assign in scene)
# ---------------------------------------------------------------------------

@onready var _door: ConditionalDoor    = $Door
@onready var _key: Area2D              = $Key
@onready var _key_hint: Label          = $KeyHint
@onready var _door_hint: Label         = $DoorHint
@onready var _has_key_indicator: Label = $HasKeyIndicator
@onready var _goal_area: Area2D        = $GoalArea
@onready var _sign_board: Area2D       = $SignBoard
@onready var _door_approach: Area2D    = $DoorApproachArea

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _has_key: bool = false
var _recorded_door_attempt: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_level_ready() -> void:
	world_index = 2
	level_index = 0
	concept     = "if"

	# Register SpawnPoint so BaseLevel._respawn_player() can find it.
	var spawn := get_node_or_null("SpawnPoint")
	if spawn:
		spawn.add_to_group("player_spawn")

	_door.mechanic_id     = "door_l1_1"
	_door.logic_mode      = ConditionalDoor.LogicMode.SINGLE
	_door.hint_pseudocode = "se (tem_chave):\n    porta.abrir()"

	# Wire a virtual single-input "button" driven by _has_key state.
	# We use _door.force_activate() directly when key is collected.
	_door.force_deactivate()

	if _key:
		_key.body_entered.connect(_on_key_collected)

	if _goal_area:
		_goal_area.body_entered.connect(_on_goal_reached)

	if _sign_board:
		_sign_board.body_entered.connect(_on_sign_entered)
		_sign_board.body_exited.connect(_on_sign_exited)

	if _door_approach:
		_door_approach.body_entered.connect(_on_door_approach_entered)

	_update_key_indicator()

	# Show tutorial hints.
	if _key_hint:
		_key_hint.text = "Colete a chave para abrir a porta!"
	if _door_hint:
		_door_hint.text = "SE (tem_chave) → porta abre"

# ---------------------------------------------------------------------------
# Key collection
# ---------------------------------------------------------------------------

func _on_key_collected(body: Node) -> void:
	if not body.is_in_group("player") or _has_key:
		return

	_has_key = true
	EventBus.play_sfx.emit("button_press")
	GameState.record_decision("key_collected")

	# The "if" condition is now true → open the door.
	_door.force_activate()
	_update_key_indicator()

	if _key:
		_key.queue_free()

	if _key_hint:
		_key_hint.text = "Você tem a chave! Agora vá até a porta."

# ---------------------------------------------------------------------------
# Goal reached
# ---------------------------------------------------------------------------

func _on_goal_reached(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	complete_level()

# ---------------------------------------------------------------------------
# Sign Board & Door Approach
# ---------------------------------------------------------------------------

func _on_sign_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var pseudo = "se (condição):\n    # Executa esta ação se for verdadeiro"
	EventBus.show_concept_hint.emit("if", pseudo)

func _on_sign_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	EventBus.hide_concept_hint.emit()

func _on_door_approach_entered(body: Node) -> void:
	if not body.is_in_group("player") or _has_key or _recorded_door_attempt:
		return
	
	_recorded_door_attempt = true
	GameState.record_decision("tried_door_without_key")
	
	if _door_hint:
		_door_hint.modulate = Color.RED
		var tween := create_tween()
		tween.tween_property(_door_hint, "modulate", Color(1, 0.6, 0.6), 1.0)

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

func _update_key_indicator() -> void:
	if _has_key_indicator:
		_has_key_indicator.text = "tem_chave = %s" % ("Verdadeiro ✅" if _has_key else "Falso ❌")
		_has_key_indicator.modulate = Color.GREEN if _has_key else Color.RED
