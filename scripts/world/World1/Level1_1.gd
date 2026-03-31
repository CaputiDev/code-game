## Level1_1.gd
## Mundo 1, Fase 1 — "Sua Primeira Variável"
##
## O jogador vê um HUD exibindo o valor de uma variável.
## Ao coletar o item, a variável 'ponto' aumenta de 0 para 1.
##
## Objetivo Pedagógico:
##   Introduzir o conceito de variável como um "espaço de armazenamento"
##   que pode mudar durante a execução do programa.
extends BaseLevel

@onready var _variable_display: Label = %VariableDisplay
@onready var _collector: Area2D        = $Collector

var _score: int = 0

func _on_level_ready() -> void:
	world_index = 1
	level_index = 0
	concept     = "variable"
	
	if _collector:
		_collector.body_entered.connect(_on_collect)
	
	_update_ui()

func _on_collect(body: Node) -> void:
	if not body.is_in_group("player") or _score > 0:
		return
	
	_score = 1
	EventBus.play_sfx.emit("button_press")
	GameState.record_decision("variable_assigned")
	
	_update_ui()
	
	if _collector:
		_collector.queue_free()
	
	# After seeing the change, level complete after short delay.
	await get_tree().create_timer(1.0).timeout
	complete_level()

func _update_ui() -> void:
	if _variable_display:
		_variable_display.text = "Var pontos = %d" % _score
