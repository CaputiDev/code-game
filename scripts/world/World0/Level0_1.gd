## Level0_1.gd
## Mundo 0, Fase 1 — "O Início da Lógica"
##
## Introdução ao conceito de algoritmo (sequência de passos).
extends BaseLevel

func _on_level_ready() -> void:
	world_index = 0
	level_index = 0
	concept     = "algorithm"
	
	# Wait a bit and then complete the intro level
	await get_tree().create_timer(3.0).timeout
	complete_level()
