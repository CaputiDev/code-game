# 🎓 Visão Pedagógica

O CodeGame não é apenas um jogo, é um instrumento de avaliação formativa disfarçado de puzzle.

## Teoria de Aprendizado
O projeto baseia-se no **Construcionismo** (Seymour Papert), onde o aluno constrói conhecimento ao criar ou manipular "objetos para pensar".

### Isomorfismos
Cada mecânica foi desenhada para ser um espelho fiel de uma operação lógica:
- **Porta Condicional** = Fluxo de controle.
- **Botões** = Inputs booleanos.
- **Variáveis** = Estado e memória.

## Métrica `understood`

Como saber se o jogador aprendeu o conceito ou apenas teve sorte? O sistema utiliza a métrica binária `understood`:

- **`understood = true`**: Alcançado quando o jogador completa a fase em **3 ou menos tentativas**. Isso sugere que o player compreendeu o padrão lógico.
- **`understood = false`**: Quando são necessárias mais de 3 tentativas. Indica que o jogador pode estar usando tentativa e erro, sugerindo a necessidade de reforço pedagógico.

## O Sistema de Quiz

Ao final de cada mundo, o `WorldQuiz` valida o conhecimento teórico.

- **Questões de Múltipla Escolha**: Teoria básica.
- **Pseudocódigo**: O jogador deve completar lacunas de lógica para resolver um problema escrito.
- **Métricas do Quiz**: Integradas à telemetria para ajudar o professor/pesquisador a entender onde a turma está tendo mais dificuldade.

---
[⬅️ Voltar para o README.MD](../README.md)
