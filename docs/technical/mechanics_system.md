# 🧩 Sistema de Mecânicas (Interactables)

A `BaseMechanic` é a classe abstrata da qual derivam todos os objetos interativos carregados de significado pedagógico no jogo.

## Especificações Técnicas

- **Script**: `res://scripts/base/BaseMechanic.gd`
- **Herança**: `Node2D`

### Padrão Template Method

A `BaseMechanic` define o esqueleto do comportamento e as subclasses preenchem os detalhes:
- `evaluate_condition()`: Retorna `true` ou `false` baseado na lógica específica da peça.
- `on_activate()` / `on_deactivate()`: Definem animações ou efeitos visuais.

### Sistema de Reatividade (Setter Hooks)

O estado `is_active` é protegido por um **Setter**. Toda vez que o valor muda:
1. Dispara `EventBus.mechanic_activated`.
2. Emite sinal local `activated`.
3. Chama `on_activate()`.
4. Se houver um conceito configurado, emite `show_concept_hint`.

### Métodos Principais

| Método | Finalidade |
|---|---|
| `refresh()` | Força uma reavaliação da lógica (`is_active = evaluate_condition()`). |
| `force_activate()` | Ativa a mecânica ignorando sua lógica interna (usado para overrides). |

---
[⬅️ Voltar para o README.MD](../../README.md)
