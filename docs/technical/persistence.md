# 💾 SaveManager (Serialization System)

O `SaveManager` é responsável por persistir o progresso do jogador entre sessões de jogo, utilizando um sistema de schema versionado.

## Especificações Técnicas

- **Script**: `res://scripts/autoload/SaveManager.gd`
- **Arquivo**: `user://save_data.json`

### Ciclo de Persistência

1. **Serialização (`_serialize`)**: Converte o estado atual do `GameState` (Arrays, Dicionários, Inteiros) em um dicionário compatível com JSON.
2. **Escrita**: Utiliza `FileAccess` para salvar a string JSON formatada no caminho `user://`.
3. **Deserialização (`_deserialize`)**: No carregamento, reconverte strings (chaves de dicionário vindas do JSON) em tipos nativos do Godot (ints/floats).

### Padrão de Migração
O sistema utiliza uma constante `SAVE_VERSION`. Se um arquivo antigo for detectado, o método `_migrate` é chamado para adaptar o JSON antes da carga final.

### Métodos Principais

- `save()`: Disparado ao fim de cada nível ou alteração de perfil.
- `load_save()`: Chamado automaticamente no `_ready` do Autoload.
- `generate_uuid()`: Gera um identificador único para o jogador na primeira execução.

---
[⬅️ Voltar para o README.MD](../../README.md)
