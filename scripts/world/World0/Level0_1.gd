## Level0_1.gd
## World 0, Level 1 — "O que é um algoritmo?"
##
## A guided, narrative tutorial. The player follows step-by-step instructions
## to open a door. Each step is highlighted with a glowing arrow until clicked.
## This level has no fail state — it's a frictionless introduction.
##
## Pedagogical objective:
##   Player understands that an algorithm is a SEQUENCE of ordered steps.
extends BaseLevel

# ---------------------------------------------------------------------------
# Level-specific nodes
# ---------------------------------------------------------------------------

@onready var _step_labels: Array[Label] = [
	$Steps/Step1Label,
	$Steps/Step2Label,
	$Steps/Step3Label,
]
@onready var _step_buttons: Array[Button] = [
	$Steps/Step1Button,
	$Steps/Step2Button,
	$Steps/Step3Button,
]
@onready var _door_animator: AnimationPlayer = $Door/AnimationPlayer
@onready var _narrator_label: Label = $NarratorPanel/NarratorLabel

var _current_step: int = 0

const STEP_TEXTS: Array[String] = [
	"Passo 1: Pegar a chave 🗝️",
	"Passo 2: Caminhar até a porta 🚪",
	"Passo 3: Usar a chave na fechadura 🔓",
]

const NARRATOR_TEXTS: Array[String] = [
	"Um algoritmo é uma sequência de passos para resolver um problema.\nVamos aprender com um exemplo simples!",
	"Muito bem! Agora caminhamos até a porta.",
	"Quase lá! Só falta usar a chave.",
	"🎉 Você completou o algoritmo! A porta está aberta!",
]

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _on_level_ready() -> void:
	world_index = 0
	level_index = 0
	concept     = "algorithm"
	allow_debug_skip = true

	_narrator_label.text = NARRATOR_TEXTS[0]

	for i in _step_buttons.size():
		if i < STEP_TEXTS.size():
			_step_buttons[i].text = STEP_TEXTS[i]
		_step_buttons[i].pressed.connect(func(): _on_step_pressed(i))
		_step_buttons[i].disabled = (i != 0)  # Only first step enabled.

	_highlight_current_step()

# ---------------------------------------------------------------------------
# Step progression
# ---------------------------------------------------------------------------

func _on_step_pressed(step_index: int) -> void:
	if step_index != _current_step:
		return

	EventBus.play_sfx.emit("button_press")
	GameState.record_decision("algorithm_step:%d" % step_index)

	_step_buttons[step_index].disabled = true
	_step_labels[step_index].modulate = Color.GREEN

	_current_step += 1

	if _current_step >= _step_buttons.size():
		# All steps done — open door.
		_narrator_label.text = NARRATOR_TEXTS[3]
		if _door_animator:
			_door_animator.play("open")
		await get_tree().create_timer(1.2).timeout
		complete_level()
	else:
		_narrator_label.text = NARRATOR_TEXTS[_current_step]
		_step_buttons[_current_step].disabled = false
		_highlight_current_step()

func _highlight_current_step() -> void:
	for i in _step_buttons.size():
		var btn: Button = _step_buttons[i]
		if i == _current_step and not btn.disabled:
			var tween := btn.create_tween().set_loops()
			tween.tween_property(btn, "modulate", Color(1.3, 1.3, 0.5), 0.5)
			tween.tween_property(btn, "modulate", Color.WHITE, 0.5)
		else:
			btn.modulate = Color.WHITE
