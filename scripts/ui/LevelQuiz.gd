## LevelQuiz.gd
## Quiz sequence shown after level completion.
## Presents 5 questions of increasing difficulty (1-5).
extends Control

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _progress_label: Label     = %ProgressLabel
@onready var _difficulty_label: Label   = %DifficultyLabel
@onready var _question_label: RichTextLabel = %QuestionLabel
@onready var _pseudocode_label: RichTextLabel = %PseudocodeLabel
@onready var _options_container: VBoxContainer = %OptionsContainer
@onready var _feedback_panel: PanelContainer   = %FeedbackPanel
@onready var _feedback_icon: Label      = %FeedbackIcon
@onready var _feedback_label: Label     = %FeedbackLabel
@onready var _explanation_label: RichTextLabel = %ExplanationLabel
@onready var _next_button: Button       = %NextButton

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _questions: Array[Question] = []
var _current_index: int = 0
var _score: int = 0
var _answer_submitted: bool = false
var _level_data: Dictionary = {} # Passed from BaseLevel

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_feedback_panel.visible = false
	_next_button.pressed.connect(_on_next_pressed)

	# Fetch questions for the current world.
	var world_idx: int = GameState.current_world
	var full_bank: Array[Question] = QuizData.get_questions_for_world(world_idx)
	
	# Select 1 question for each difficulty 1-5.
	_questions.clear()
	for d in range(1, 6):
		var candidates: Array = full_bank.filter(func(q: Question): return q.difficulty == d)
		if not candidates.is_empty():
			candidates.shuffle()
			_questions.append(candidates[0])
		else:
			# Fallback if specific difficulty is missing.
			if not full_bank.is_empty():
				_questions.append(full_bank.pick_random())

	_current_index = 0
	_score = 0
	_present_question()

# ---------------------------------------------------------------------------
# Quiz Flow
# ---------------------------------------------------------------------------

func _present_question() -> void:
	if _current_index >= _questions.size():
		_finish_quiz()
		return

	_answer_submitted = false
	_feedback_panel.visible = false
	
	var q: Question = _questions[_current_index]
	
	_progress_label.text = "Questão %d de %d" % [_current_index + 1, _questions.size()]
	
	var diff_text := "Fácil"
	match q.difficulty:
		1: diff_text = "Muito Fácil"
		2: diff_text = "Fácil"
		3: diff_text = "Médio"
		4: diff_text = "Difícil"
		5: diff_text = "Desafio"
	_difficulty_label.text = "Dificuldade: %s" % diff_text
	
	_question_label.text = q.question_text
	if q.pseudocode != "":
		_pseudocode_label.text = "[code]%s[/code]" % q.pseudocode
		_pseudocode_label.visible = true
	else:
		_pseudocode_label.visible = false

	# Clear options.
	for child in _options_container.get_children():
		child.queue_free()

	for i in q.options.size():
		var btn: Button = Button.new()
		btn.text = q.options[i]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _on_option_selected(i))
		_options_container.add_child(btn)

func _on_option_selected(index: int) -> void:
	if _answer_submitted:
		return
	_answer_submitted = true

	var q: Question = _questions[_current_index]
	var correct: bool = q.is_correct(index)
	
	if correct:
		_score += 1
		_feedback_icon.text = "✅"
		_feedback_label.text = "Correto!"
		EventBus.play_sfx.emit("quiz_correct")
	else:
		_feedback_icon.text = "❌"
		_feedback_label.text = "Incorreto"
		EventBus.play_sfx.emit("quiz_wrong")

	_explanation_label.text = q.explanation
	_feedback_panel.visible = true
	
	# Disable buttons.
	for child in _options_container.get_children():
		if child is Button:
			child.disabled = true
			if _questions[_current_index].is_correct(child.get_index()):
				child.modulate = Color.GREEN
			elif child.get_index() == index:
				child.modulate = Color.RED

func _on_next_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	_current_index += 1
	_present_question()

func _finish_quiz() -> void:
	# Calculate stars based on score: 5=3, 4=2, 3=1, <3=0.
	var stars: int = 0
	if _score == 5: stars = 3
	elif _score == 4: stars = 2
	elif _score == 3: stars = 1
	
	GameState.set_level_stars(GameState.current_world, GameState.current_level, stars)
	
	# Prepare result data for LevelComplete screen.
	var result_data: Dictionary = {
		"world": GameState.current_world,
		"level": GameState.current_level,
		"quiz_score": _score,
		"quiz_total": _questions.size(),
		"stars": stars,
		"time_seconds": GameState.get_elapsed_seconds(),
		"attempts": GameState.current_attempts
	}
	
	LevelComplete.store_result(result_data)
	get_tree().change_scene_to_file("res://scenes/menus/LevelComplete.tscn")
