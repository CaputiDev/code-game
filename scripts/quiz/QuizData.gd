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
		"Um algoritmo é uma sequência finita e ordenada de passos que resolve um problema. " +
		"Pode ser escrito em qualquer idioma ou linguagem!"
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
		"Um algoritmo deve seguir a ordem correta das etapas. " +
		"Abrir → Colocar → Tomar é a única sequência que faz sentido lógico."
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
		"A sequência é fundamental. Se você tentar vestir os sapatos antes das meias, " +
		"o resultado não será o esperado!"
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
		"Algoritmos são sequências lógicas de ações. " +
		"Sentimentos são subjetivos e não seguem um passo a passo mecânico."
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
		"O losango é o símbolo padrão para decisões. Ele pergunta algo (Ex: 'Está chovendo?') " +
		"e cria dois caminhos possíveis (Sim ou Não)."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 1: Basic Structures (Variables, Types, Operators)
# ---------------------------------------------------------------------------

func _build_w1() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w1_q1", 1, "variable", 1,
		Question.QuestionType.FILL_PSEUDOCODE,
		"Complete o pseudocódigo para contar os itens coletados:",
		"Algoritmo ColetarItens\nVar contador: inteiro\nInicio\n" +
		"  contador <- 0\n  contador <- ___ + 1\n  Escreva(contador)\nFimAlgoritmo",
		["1", "contador", "0", "item"],
		1,
		"Para incrementar uma variável, usamos ela mesma: contador ← contador + 1. " +
		"Isso lê o valor atual e " +
		"adiciona 1, salvando o resultado de volta."
	))

	questions.append(_make_question(
		"w1_q2", 1, "variable_assign", 2,
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
		"Uma variável é como uma caixa que só cabe um item por vez. " +
		"Ao colocar algo novo, o que estava lá " +
		"antes é descartado."
	))

	questions.append(_make_question(
		"w1_q3", 1, "and", 3,
		Question.QuestionType.MULTIPLE_CHOICE,
		"No operador E (AND), para que o resultado seja Verdadeiro:",
		"",
		[
			"Apenas uma condição precisa ser verdadeira.",
			"Ambas as condições precisam ser verdadeiras.",
			"Ambas as condições precisam ser falsas.",
			"O resultado é sempre verdadeiro.",
		],
		1,
		"O operador E (AND) é exigente: todas as condições conectadas por ele " +
		"precisam ser verdadeiras para que o resultado final seja verdadeiro."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 2: Flow Control (Conditionals, Loops)
# ---------------------------------------------------------------------------

func _build_w2() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w2_q1", 2, "if", 1,
		Question.QuestionType.FILL_PSEUDOCODE,
		"Qual comando inicia uma tomada de decisão?",
		"Algoritmo Decisao\nVar tem_chave: lógico\nInicio\n" +
		"  ___ (tem_chave) entao\n    AbrirPorta()\n  FimSe\nFimAlgoritmo",
		["Enquanto", "Se", "Para", "Repita"],
		1,
		"\"Se\" (if) é a estrutura condicional correta. Ela verifica se a condição é verdadeira " +
		"e só então executa o bloco interno."
	))

	questions.append(_make_question(
		"w2_q2", 2, "loop", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"Qual a principal diferença entre um 'Se' e um 'Enquanto'?",
		"",
		[
			"Nenhuma, fazem a mesma coisa.",
			"O 'Se' executa uma vez, o 'Enquanto' repete enquanto a condição for verdadeira.",
			"O 'Se' é para números, o 'Enquanto' para texto.",
			"O 'Enquanto' só funciona se o 'Se' falhar.",
		],
		1,
		"O 'Se' testa uma condição e age uma única vez. O 'Enquanto' (while) " +
		"cria um loop, repetindo as instruções até que a condição mude para falso."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 3: Data Structures (Arrays & Objects)
# ---------------------------------------------------------------------------

func _build_w3() -> Array[Question]:
	var questions: Array[Question] = []
	# TODO: Add specific data structure puzzles
	return questions

# ---------------------------------------------------------------------------
# Question bank — World 4: Abstraction & Modularization (Functions & Recursion)
# ---------------------------------------------------------------------------

func _build_w4() -> Array[Question]:
	var questions: Array[Question] = []

	questions.append(_make_question(
		"w4_q1", 4, "function", 1,
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
		"Uma função é um bloco de código nomeado e reutilizável. Em vez de repetir o " +
		"mesmo código várias vezes, criamos uma função e a chamamos quando precisamos."
	))
	
	questions.append(_make_question(
		"w4_q2", 4, "recursion", 2,
		Question.QuestionType.MULTIPLE_CHOICE,
		"O que é recursividade?",
		"",
		[
			"Um tipo de variável global.",
			"Quando uma função chama a si mesma.",
			"Um erro que trava o computador.",
			"Uma forma de organizar arquivos.",
		],
		1,
		"Recursividade é quando uma função chama a si mesma para resolver " +
		"subproblemas, até atingir um caso base."
	))

	return questions

# ---------------------------------------------------------------------------
# Question bank — World 5: Final Challenges
# ---------------------------------------------------------------------------

func _build_w5() -> Array[Question]:
	var questions: Array[Question] = []
	return questions

# ---------------------------------------------------------------------------
# Question builder helper
# ---------------------------------------------------------------------------

func _build_bank() -> void:
	_bank[0] = _build_w0()
	_bank[1] = _build_w1()
	_bank[2] = _build_w2()
	_bank[3] = _build_w3()
	_bank[4] = _build_w4()
	_bank[5] = _build_w5()

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
