## QuizData.gd
## Autoload-ready singleton that holds the full bank of quiz questions
## organized by world. Questions are defined in GDScript for ease of
## maintenance without external files.
##
## To add a question:
##   1. Call _make_question() with the required fields.
##   2. Append it to the correct world array in _build_bank().
##
## Access: QuizData.get_questions_for_world(world_index)
extends Node

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _bank: Dictionary = {}  # world_index (int) → Array[Question]

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_build_bank()
	print("[QuizData] Loaded %d worlds of questions." % _bank.size())

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Returns all questions for a given world index.
func get_questions_for_world(world: int) -> Array[Question]:
	return _bank.get(world, [] as Array[Question])

## Returns a single question by ID, searching all worlds.
func find_question(id: String) -> Question:
	for world_questions: Array[Question] in _bank.values():
		for q: Question in world_questions:
			if q.question_id == id:
				return q
	return null

# ---------------------------------------------------------------------------
# Question bank — World 0: Algorithms & Sequences (Intro)
# ---------------------------------------------------------------------------

func _build_w0() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w0_q1", 0, "algorithm", 1,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que é um algoritmo?",
		"",
		[
			"Um programa de computador escrito em Python.",
			"Uma sequência finita de instruções para resolver um problema.",
			"Uma linguagem de programação.",
			"Um arquivo de texto com comandos aleatórios.",
		],
		1,
		"Um algoritmo é uma sequência finita e ordenada de passos que resolve um problema. Pode ser escrito em qualquer idioma ou linguagem!"
	))

	questions.append(_make_question(
		"w0_q2", 0, "sequence", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual das sequências abaixo representa corretamente como preparar um copo de suco?",
		"",
		[
			"Tomar o suco → Colocar o suco → Abrir a embalagem",
			"Abrir a embalagem → Colocar o suco → Tomar o suco",
			"Tomar o suco → Abrir a embalagem → Colocar o suco",
			"Colocar o suco → Tomar o suco → Abrir a embalagem",
		],
		1,
		"Um algoritmo deve seguir a ordem correta das etapas. Abrir → Colocar → Tomar é a única sequência que faz sentido lógico."
	))

	questions.append(_make_question(
		"w0_q3", 0, "logic", 3,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Por que a ordem das instruções é importante em um algoritmo?",
		"",
		[
			"Porque faz o programa rodar mais rápido.",
			"Porque altera o resultado final ou impede a execução.",
			"Porque o computador só lê de trás para frente.",
			"Não é importante, a ordem não altera o resultado.",
		],
		1,
		"A sequência é fundamental. Se você tentar vestir os sapatos antes das meias, o resultado não será o esperado!"
	))

	questions.append(_make_question(
		"w0_q4", 0, "algorithm_real_life", 4,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual das atividades abaixo NÃO pode ser descrita como um algoritmo?",
		"",
		[
			"Uma receita de bolo.",
			"O manual de montagem de um móvel.",
			"Sentir saudade de um amigo.",
			"As regras de um jogo de tabuleiro.",
		],
		2,
		"Algoritmos são sequências lógicas de ações. Sentimentos são subjetivos e não seguem um passo a passo mecânico."
	))

	questions.append(_make_question(
		"w0_q5", 0, "flowchart", 5,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Em um fluxograma, o que o símbolo de 'Losango' (Diamante) costuma representar?",
		"",
		[
			"O início ou fim do programa.",
			"Uma ação ou comando simples.",
			"Uma tomada de decisão (condição).",
			"A entrada de dados via teclado.",
		],
		2,
		"O losango é o símbolo padrão para decisões. Ele pergunta algo (Ex: 'Está chovendo?') e cria dois caminhos possíveis (Sim ou Não)."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 1: if / else / AND / OR
# ---------------------------------------------------------------------------

func _build_w1() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w1_q1", 1, "if", 1,
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete o pseudocódigo abaixo para que a porta abra quando o jogador tem a chave:",
		"Algoritmo AbrirPorta\nVar tem_chave: lógico\nInicio\n  tem_chave <- Verdadeiro\n  ___ (tem_chave) entao\n    Escreva(\"Porta aberta!\")\n  Senão\n    Escreva(\"Porta trancada.\")\n  FimSe\nFimAlgoritmo",
		["Enquanto", "Se", "Para", "Repita"],
		1,
		"\"Se\" (if) é a estrutura condicional correta. Ela verifica se a condição é verdadeira e só então executa o bloco interno."
	))

	questions.append(_make_question(
		"w1_q2", 1, "and", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"A porta abre quando o Botão A E o Botão B estão pressionados. O Botão A está pressionado e o Botão B está solto. A porta abre?",
		"",
		[
			"Sim, porque pelo menos um está pressionado.",
			"Sim, porque o Botão A é suficiente.",
			"Não, porque com AND ambos devem ser verdadeiros.",
			"Depende da cor da porta.",
		],
		2,
		"Com o operador AND (E), TODAS as condições devem ser verdadeiras. Como o Botão B está solto (falso), o resultado é falso e a porta permanece fechada."
	))

	questions.append(_make_question(
		"w1_q3", 1, "if_else", 3,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Para que serve o comando 'Senão' (else) em uma estrutura condicional?",
		"",
		[
			"Para repetir uma ação enquanto o 'Se' for verdadeiro.",
			"Para executar um código quando a condição do 'Se' for FALSA.",
			"Para terminar o programa imediatamente.",
			"Para definir o nome de uma variável.",
		],
		1,
		"O 'Senão' é o plano B. Se a condição principal falhar, o código dentro do 'Senão' será o herói da vez."
	))

	questions.append(_make_question(
		"w1_q4", 1, "or", 4,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Em uma lógica OR (OU), a condição 'Se (A OU B)' será verdadeira quando:",
		"",
		[
			"Somente quando A e B forem verdadeiros ao mesmo tempo.",
			"Somente quando ambos forem falsos.",
			"Quando PELO MENOS UM deles (A ou B) for verdadeiro.",
			"Nunca será verdadeira.",
		],
		2,
		"O operador OR (OU) é generoso: basta que um dos botões seja pressionado para que a condição seja aceita."
	))

	questions.append(_make_question(
		"w1_q5", 1, "logic_nested", 5,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual será a saída?\nVar num: 15\nSe (num % 2 = 0) entao \"Par\"\nSenão Se (num > 10) entao \"Ímpar Maior que 10\"\nSenão \"Pequeno\"",
		"",
		[
			"Par",
			"Pequeno",
			"Ímpar Maior que 10",
			"Erro de sintaxe",
		],
		2,
		"15 não é par (resto 1). Entra no Senão e testa se 15 > 10. Como é verdadeiro, imprime 'Ímpar Maior que 10'."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 2: Variables & Functions
# ---------------------------------------------------------------------------

func _build_w2() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w2_q1", 2, "variable", 1,
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete o pseudocódigo para contar os itens coletados:",
		"Algoritmo ColetarItens\nVar contador: inteiro\nInicio\n  contador <- 0\n  contador <- ___ + 1\n  Escreva(contador)\nFimAlgoritmo",
		["1", "contador", "0", "item"],
		1,
		"Para incrementar uma variável, usamos ela mesma: contador ← contador + 1. Isso lê o valor atual e adiciona 1, salvando o resultado de volta."
	))

	questions.append(_make_question(
		"w2_q2", 2, "function", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Para que serve uma função em programação?",
		"",
		[
			"Para armazenar um valor que pode mudar.",
			"Para repetir uma ação um número fixo de vezes.",
			"Para agrupar instruções com um nome, permitindo chamá-las várias vezes.",
			"Para verificar se uma condição é verdadeira ou falsa.",
		],
		2,
		"Uma função é um bloco de código nomeado e reutilizável. Em vez de repetir o mesmo código várias vezes, criamos uma função e a chamamos quando precisamos."
	))

	questions.append(_make_question(
		"w2_q3", 2, "variable_assign", 3,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que acontece com o valor de uma variável quando fazemos uma nova atribuição (X <- 10)?",
		"",
		[
			"O valor anterior é somado ao novo.",
			"O valor anterior é apagado e substituído pelo novo.",
			"O programa cria uma nova variável com o mesmo nome.",
			"Nada acontece se a variável já tiver um valor.",
		],
		1,
		"Uma variável é como uma caixa que só cabe um item por vez. Ao colocar algo novo, o que estava lá antes é descartado."
	))

	questions.append(_make_question(
		"w2_q4", 2, "function_params", 4,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que são 'parâmetros' (ou argumentos) de uma função?",
		"",
		[
			"São os nomes das cores do jogo.",
			"São valores que enviamos para dentro da função para ela usar.",
			"São os botões que o jogador aperta no teclado.",
			"É o tempo que a função demora para rodar.",
		],
		1,
		"Parâmetros permitem que funções sejam dinâmicas. Ex: a função 'pular(altura)' usa o parâmetro 'altura' para saber quão alto deve ir."
	))

	questions.append(_make_question(
		"w2_q5", 2, "variable_type", 5,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual o tipo de dado ideal para armazenar o nome de um jogador?",
		"",
		[
			"Inteiro (Integer)",
			"Lógico (Booleano)",
			"Cadeia de Caracteres (String)",
			"Real (Float)",
		],
		2,
		"Nomes são textos. Em programação, textos são chamados de 'String' ou 'Cadeia de Caracteres'."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 3: Loops & Recursion
# ---------------------------------------------------------------------------

func _build_w3() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w3_q1", 3, "loop", 1,
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete a condição de parada do laço para que ele execute exatamente 3 vezes:",
		"Algoritmo Repeticao\nVar i: inteiro\nInicio\n  i <- 1\n  Enquanto (i ___ 3) faca\n    Escreva(i)\n    i <- i + 1\n  FimEnquanto\nFimAlgoritmo",
		["= 3", "<= 3", "> 3", "= 0"],
		1,
		"\"i <= 3\" significa \"enquanto i for menor ou igual a 3\". Com i começando em 1 e incrementando até 3, o laço executa exatamente 3 vezes."
	))

	questions.append(_make_question(
		"w3_q2", 3, "recursion", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que é a 'condição de parada' em uma função recursiva?",
		"",
		[
			"O número máximo de vezes que a função pode ser chamada.",
			"A condição que faz a função chamar a si mesma novamente.",
			"A condição que determina quando a função PARA de se chamar.",
			"O valor retornado pela última chamada da função.",
		],
		2,
		"A condição de parada (caso base) é fundamental na recursividade. Sem ela, a função chamaria a si mesma infinitamente, causando um erro de estouro de pilha."
	))

	questions.append(_make_question(
		"w3_q3", 3, "loop_infinite", 3,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que causa um 'Loop Infinito'?",
		"",
		[
			"Um computador muito rápido.",
			"Uma condição de parada que nunca é atingida (sempre Verdadeira).",
			"O uso de muitas variáveis ao mesmo tempo.",
			"Quando o jogador esquece de salvar o jogo.",
		],
		1,
		"Se a condição de um laço for sempre verdadeira (Ex: 'Enquanto 1 < 2'), o programa nunca sai do loop e pode travar."
	))

	questions.append(_make_question(
		"w3_q4", 3, "for_vs_while", 4,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Normalmente, usamos o laço 'Para' (For) em vez do 'Enquanto' (While) quando:",
		"",
		[
			"Não sabemos quantas vezes vamos repetir.",
			"Queremos que o código rode mais devagar.",
			"Já sabemos exatamente quantas vezes queremos repetir.",
			"A condição depende da cor de um objeto.",
		],
		2,
		"O laço 'Para' é ideal para contagens conhecidas. O 'Enquanto' é usado quando a repetição depende de um evento incerto."
	))

	questions.append(_make_question(
		"w3_q5", 3, "recursion_concept", 5,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual a melhor definição visual para 'Recursividade'?",
		"",
		[
			"Um espelho refletindo outro espelho infinitamente.",
			"Uma linha reta que nunca termina.",
			"Um círculo perfeito sem início ou fim.",
			"Uma escada que sobe sem parar.",
		],
		0,
		"Recursividade é quando algo é definido em termos de si mesmo. Um espelho refletindo outro cria cópias de si mesmo, similar a uma função chamando a si mesma."
	))

	return questions

# ---------------------------------------------------------------------------
# Question builder helper
# ---------------------------------------------------------------------------

func _build_bank() -> void:
	_bank[0] = _build_w0()
	_bank[1] = _build_w1()
	_bank[2] = _build_w2()
	_bank[3] = _build_w3()

func _make_question(
		id: String,
		world: int,
		concept: String,
		difficulty: int,
		type: Question.QuestionType,
		question_text: String,
		pseudocode: String,
		options: Array[String],
		correct_index: int,
		explanation: String
) -> Question:
	var q := Question.new()
	q.question_id   = id
	q.world         = world
	q.concept       = concept
	q.difficulty    = difficulty
	q.type          = type
	q.question_text = question_text
	q.pseudocode    = pseudocode
	q.options       = options
	q.correct_index = correct_index
	q.explanation   = explanation
	return q

