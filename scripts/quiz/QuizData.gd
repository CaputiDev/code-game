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
# Question bank — World 0: Algorithms & Sequences
# ---------------------------------------------------------------------------

func _build_w0() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w0_q1", 0, "algorithm",
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
		"w0_q2", 0, "sequence",
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

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 1: if / else / AND / OR
# ---------------------------------------------------------------------------

func _build_w1() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w1_q1", 1, "if",
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete o pseudocódigo abaixo para que a porta abra quando o jogador tem a chave:",
		"Algoritmo AbrirPorta\nVar tem_chave: lógico\nInicio\n  tem_chave <- Verdadeiro\n  ___ (tem_chave) entao\n    Escreva(\"Porta aberta!\")\n  Senão\n    Escreva(\"Porta trancada.\")\n  FimSe\nFimAlgoritmo",
		["Enquanto", "Se", "Para", "Repita"],
		1,
		"\"Se\" (if) é a estrutura condicional correta. Ela verifica se a condição é verdadeira e só então executa o bloco interno."
	))

	questions.append(_make_question(
		"w1_q2", 1, "if_else",
		Question.QuestionType.MULTIPLE_CHOICE,
		"Algoritmo VerificaNumero\nVar num: inteiro\nInicio\n  num <- 15\n  Se (num % 2 = 0) entao\n    Escreva(\"Par\")\n  Senão\n    Se (num > 10) entao\n      Escreva(\"Ímpar Maior que 10\")\n    Senão\n      Escreva(\"Ímpar Menor ou igual a 10\")\n    FimSe\n  FimSe\nFimAlgoritmo\n\nQual será a saída ao executar este algoritmo?",
		"",
		[
			"Par",
			"Ímpar",
			"Ímpar Menor ou igual a 10",
			"Ímpar Maior que 10",
		],
		3,
		"15 é ímpar (15 % 2 ≠ 0), então entra no Senão. Como 15 > 10, a saída é \"Ímpar Maior que 10\"."
	))

	questions.append(_make_question(
		"w1_q3", 1, "and",
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

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 2: Variables & Functions
# ---------------------------------------------------------------------------

func _build_w2() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w2_q1", 2, "variable",
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete o pseudocódigo para contar os itens coletados:",
		"Algoritmo ColetarItens\nVar contador: inteiro\nInicio\n  contador <- 0\n  contador <- ___ + 1\n  Escreva(contador)\nFimAlgoritmo",
		["1", "contador", "0", "item"],
		1,
		"Para incrementar uma variável, usamos ela mesma: contador ← contador + 1. Isso lê o valor atual e adiciona 1, salvando o resultado de volta."
	))

	questions.append(_make_question(
		"w2_q2", 2, "function",
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

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 3: Loops & Recursion
# ---------------------------------------------------------------------------

func _build_w3() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w3_q1", 3, "loop",
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete a condição de parada do laço para que ele execute exatamente 3 vezes:",
		"Algoritmo Repeticao\nVar i: inteiro\nInicio\n  i <- 1\n  Enquanto (i ___ 3) faca\n    Escreva(i)\n    i <- i + 1\n  FimEnquanto\nFimAlgoritmo",
		["= 3", "<= 3", "> 3", "= 0"],
		1,
		"\"i <= 3\" significa \"enquanto i for menor ou igual a 3\". Com i começando em 1 e incrementando até 3, o laço executa exatamente 3 vezes."
	))

	questions.append(_make_question(
		"w3_q2", 3, "recursion",
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que é a \"condição de parada\" em uma função recursiva?",
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
	q.type          = type
	q.question_text = question_text
	q.pseudocode    = pseudocode
	q.options       = options
	q.correct_index = correct_index
	q.explanation   = explanation
	return q
