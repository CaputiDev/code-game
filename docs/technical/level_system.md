# 🗺️ Sistema de Níveis (Template Method)

A classe `BaseLevel` define o comportamento padrão para todos os mapas do jogo, garantindo que a telemetria e o ciclo de vida sejam consistentes.

## Especificações Técnicas

- **Script**: `res://scripts/base/BaseLevel.gd`
- **Herança**: `Node` (Raiz da Cena)

### Ciclo de Vida do Level

1. `_ready()`: Emite `EventBus.level_started` e configura o HUD.
2. `complete_level()`: Ponto final da fase. Bloqueia entradas, emite sinais de vitória e solicita ao `SaveManager` que persista o progresso.
3. `fail_attempt()`: Chamado em caso de morte. Emite sinal de falha e coordena o **Respawn Decoupled**.

### Desacoplamento via Grupos

O `BaseLevel` utiliza o sistema de grupos do Godot para encontrar o Player e o Spawn Point sem referências rígidas:
- **`player_spawn`**: O primeiro nó neste grupo é usado como posição de origem.
- **`player`**: Todos os nós neste grupo recebem o comando `respawn()` via reflexão (`has_method`).

### Atributos Exportados
- `world_index`: ID do mundo (0 a 3).
- `concept`: Nome do conceito pedagógico (ex: "if").
- `next_level_path`: Caminho da próxima cena `.tscn`.

---
[⬅️ Voltar para o README.MD](../../README.md)
