# 🏗️ Estrutura do Projeto

Esta seção detalha o fluxo holístico do CodeGame, mostrando como as diferentes peças da arquitetura se encaixam desde o boot inicial até a persistência de dados.

## Fluxograma Global de Funcionamento

O diagrama abaixo ilustra o ciclo de vida do motor e como os sistemas assíncronos (Telemetria) e síncronos (GameState) colaboram.

```mermaid
graph TD
    %% Estilização
    classDef startEnd fill:#f9f,stroke:#333,stroke-width:2px;
    classDef process fill:#bbf,stroke:#333,stroke-width:1px;
    classDef storage fill:#dfd,stroke:#333,stroke-width:1px;
    classDef event fill:#fdd,stroke:#333,stroke-width:1px;

    subgraph Boot ["1. BOOT DA ENGINE"]
        A[Início do Jogo] --> B[Carregamento de Autoloads]
        B --> B1[(SaveManager: Carrega JSON)]
        B --> B2[Telemetry: Inicia Fila Offline]
        B --> B3[GameState: Sincroniza Variáveis]
    end

    subgraph Nav ["2. NAVEGAÇÃO / MENUS"]
        B3 --> C[MainMenu.tscn]
        C -- Clique em Play --> D[Loop de Gameplay]
    end

    subgraph Loop ["3. LOOP DE GAMEPLAY"]
        D --> E{EventBus: Barramento Central}
        
        subgraph Signals ["Sinais do Motor"]
            S1[Player Input] -->|Emit: mechanic_activated| E
            S2[Collisions] -->|Emit: play_sfx| E
            E -.->|Connect: Listeners| S3[HUD / Audio / Concept Hint]
        end
    end

    subgraph Persist ["4. PERSISTÊNCIA & SAÍDA"]
        D --> F[Fim da Fase]
        F --> G[SaveManager: Serializa JSON]
        F --> H[Telemetry: POST HTTP Batch]
    end

    subgraph Next ["5. PRÓXIMO ESTADO"]
        G & H --> I[LevelQuiz ou WorldSelect]
    end

    %% Classes de Estilo
    class A,I startEnd;
    class B,C,D,F process;
    class B1,G storage;
    class E event;
```

## Detalhes dos Bastidores

### O Papel do EventBus como "Middleware"
Quase nenhuma comunicação no jogo é direta (`A -> B`). O `EventBus` atua como um barramento onde o emissor não sabe quem é o receptor. Isso permite que possamos adicionar ou remover sistemas (como um novo logger ou sistema de conquistas) sem alterar o código do Player ou das Mecânicas.

### Persistência Silenciosa
O `SaveManager` e o `TelemetryManager` trabalham fora da percepção do jogador. Enquanto o `SaveManager` garante a integridade do progresso local (JSON), o `TelemetryManager` gerencia uma fila em memória que tenta se auto-sincronizar com o backend sempre que houver conexão, sem nunca travar a thread principal (non-blocking).

### Autoloads como Estado Persistente
Como o Godot limpa a árvore de nós ao trocar de cenas, os **Autoloads** (Singletons) são cruciais. Eles residem em uma raiz separada (`root`) que nunca é deletada, funcionando como uma memória viva que mantém o UUID do jogador e as estrelas coletadas enquanto ele viaja entre os mundos.

---
[⬅️ Voltar para o README.MD](../../README.md)
