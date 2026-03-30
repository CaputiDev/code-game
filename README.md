# CodeGame 🎮

**Jogo educativo 2D de plataforma/puzzle para ensino de lógica de programação.**

> Desenvolvido como Trabalho de Conclusão de Curso (TCC).
> Motor: **Godot Engine 4.6** | Linguagem: **GDScript** | Plataforma: Desktop (Windows/Linux/macOS)

---

## 🎯 Objetivo Educacional

Ensinar lógica de programação de forma visual e interativa, substituindo abstrações tradicionais por mecânicas jogáveis. Cada elemento do jogo é uma metáfora de um conceito de programação.

---

## 🗺️ Progressão dos Mundos

| Mundo | Nome | Conceito |
|---|---|---|
| 0 | Bem-vindo ao CodeWorld | Algoritmos e Sequências |
| 1 | A Bifurcação | if / else / AND / OR |
| 2 | O Armazém | Variáveis e Funções |
| 3 | O Labirinto Infinito | Loops e Recursividade |

Após cada mundo, um **mini-quiz** avalia o aprendizado com questões de múltipla escolha e preenchimento de pseudocódigo.

---

## 🎮 Mecânicas Educativas

| Mecânica | Conceito Ensinado |
|---|---|
| `ConditionalDoor` | Estrutura `if/else` — porta que abre por condição lógica |
| `LogicButton` | Valores booleanos — botão toggle ou pulse |
| `VariableBlock` | Variáveis — bloco que exibe e altera valores |
| `FunctionPortal` | Funções — grava e executa sequências de ações |
| `RecursiveMirror` | Recursividade — espelho com ecos em cadeia |
| `Bug` | Obstáculo lógico — eliminado pela condição correta |

---

## 🏗️ Arquitetura

### Autoloads (Singletons)
```
EventBus          ← Signal bus desacoplado (todos os eventos passam por aqui)
GameState         ← Estado global: jogador, progressão, sessão atual
SaveManager       ← Persistência em JSON versionado
TelemetryManager  ← Coleta, fila offline-first, envio HTTP
AudioManager      ← Pool de SFX + crossfade de música
```

### Padrões utilizados
- **Signal Bus** (`EventBus`) para comunicação desacoplada entre sistemas
- **Component pattern** via herança (`BaseMechanic`, `BaseLevel`, `BaseBug`)
- **Observer pattern** via sinais do Godot para atualização reativa de UI
- **Offline-first** para telemetria: dados locais → flush HTTP quando disponível
- **Schema versionado** no SaveManager para suporte a migrações futuras

---

## 📊 Sistema de Telemetria

Eventos coletados automaticamente:

| Evento | Dados |
|---|---|
| `level_complete` | mundo, fase, conceito, tentativas, tempo, decisões, `understood` |
| `level_attempt_failed` | mundo, fase, tentativa_número, tempo |
| `quiz_answer` | questão_id, conceito, correto, tentativas, tempo |
| `quiz_complete` | mundo, score, total, passou |
| `mechanic_activated` | id, tipo, mundo, fase |
| `bug_eliminated` | bug_id, conceito, mundo, fase |

**`understood = true`** quando o jogador completa a fase com ≤ 3 tentativas.

Dados persistidos em `user://telemetry_queue.json` e enviados via HTTP quando o backend estiver configurado em `user://telemetry_config.json`.

---

## 🚀 Getting Started

### Requisitos
- Godot Engine 4.6+

### Executar
1. Abra o Godot Editor
2. Importe o projeto: `File > Import > d:/git_clones/code-game/project.godot`
3. Execute com **F5** (cena principal: `MainMenu.tscn`)

### Debug
- **F1** em qualquer fase: pula para a próxima (requer `allow_debug_skip = true` no BaseLevel)
- `TelemetryManager.debug_mode = true`: imprime todos os eventos no Output

---

## 📁 Estrutura de Pastas

```
code-game/
├── assets/          # Áudio, fontes, sprites, tilesets
├── i18n/            # pt_BR.po + messages.pot (template)
├── scenes/
│   ├── core/        # HUD, ConceptHint, PauseMenu
│   ├── menus/       # MainMenu, PlayerSetup, WorldSelect, LevelComplete, WorldQuiz
│   ├── player/      # Player.tscn
│   ├── mechanics/   # ConditionalDoor, LogicButton, VariableBlock, FunctionPortal, RecursiveMirror
│   ├── enemies/     # Bug.tscn
│   └── world/       # World0/, World1/, World2/, World3/
└── scripts/
    ├── autoload/    # EventBus, GameState, SaveManager, TelemetryManager, AudioManager
    ├── base/        # BaseMechanic, BaseLevel, BaseBug
    ├── player/      # PlayerController, PlayerAnimator
    ├── mechanics/   # Scripts das mecânicas
    ├── enemies/     # Bug
    ├── quiz/        # Question, QuizData, QuizManager
    ├── ui/          # HUD, ConceptHint, LevelComplete, WorldQuiz, PlayerSetup, MainMenu
    └── core/        # GameManager (bootstrap)
```

---

## 🎓 Métricas Pedagógicas

O campo `understood` na telemetria é calculado automaticamente:
- **`true`**: fase completada com ≤ 3 tentativas (indica assimilação natural do conceito)
- **`false`**: mais de 3 tentativas (indica necessidade de reforço)

Combinado com os dados do quiz, é possível calcular:
- Taxa de compreensão por conceito
- Conceitos que causam mais dificuldade
- Tempo médio de aprendizado por tópico
- Evolução individual por sessão

---

## 📝 Licença

Projeto acadêmico — TCC. Assets de terceiros sob licenças respectivas (Kenney.nl — CC0).
