# 🔊 Sistema de Áudio (Resource Pooling)

O `AudioManager` centraliza toda a reprodução de som do projeto, tratando música e efeitos especiais de formas distintas.

## Especificações Técnicas

- **Script**: `res://scripts/autoload/AudioManager.gd`
- **Barramentos**: O roteamento é feito para os Bus "Music" e "SFX" do Godot.

### Pooling de Efeitos (SFX)

Para evitar latência e permitir sons sobrepostos, usamos um **Pool** de 8 `AudioStreamPlayer`.
- **Lógica**: O sistema rotaciona entre os players disponíveis (`_sfx_pool_index`).
- **Método**: `play_sfx(key: String)`.

### Crossfade de Música

O gestor mantém dois players de música (`_music_player_a` e `_music_player_b`).
1. Ao trocar de música, o player ativo faz um fade-out (volume para 0).
2. O novo player faz um fade-in simultâneo via `Tween`.
3. **Método**: `play_music(key: String)`.

### Bancos de Som
O áudio é baseado em chaves lógicas (strings), permitindo trocar o asset sem alterar o código que o chama:
- `ui_confirm` → `click_001.ogg`
- `door_open` → `open_004.ogg`

---
[⬅️ Voltar para o README.MD](../../README.md)
