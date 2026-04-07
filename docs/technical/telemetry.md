# 📡 TelemetryManager (Proxy/Queue Pattern)

O `TelemetryManager` lida com a coleta e persistência de dados pedagógicos de forma resiliente a falhas de conexão (**Offline-first**).

## Especificações Técnicas

- **Script**: `res://scripts/autoload/TelemetryManager.gd`
- **Endpoints**: Configurados via `user://telemetry_config.json`.
- **Fila Local**: `user://telemetry_queue.json`.

### Fluxo do Dado

1. **Captura**: Ouve sinais do `EventBus` (ex: `level_completed`).
2. **Normalização**: O método `push_event` anexa o `player_uuid`, `timestamp` e metadados globais.
3. **Persistência**: O evento é salvo imediatamente no disco.
4. **Despacho**: O método `_try_flush` tenta enviar lotes de 50 eventos via HTTP POST.

### Métodos Principais

| Método | Função |
|---|---|
| `push_event(type, payload)` | Constrói o envelope do evento e adiciona à fila. |
| `_try_flush()` | Realiza a requisição `HTTPRequest` se houver endpoint configurado. |
| `_on_request_completed(...)` | Se sucesso (HTTP 200/201), remove os eventos da fila e salva o estado atualizado. |

### Estrutura do Payload (Exemplo)
```json
{
  "event_type": "level_complete",
  "player_uuid": "e44d-...",
  "timestamp": "2024-10...",
  "world": 1,
  "understood": true,
  "attempts": 2
}
```

---
[⬅️ Voltar para o README.MD](../../README.md)
