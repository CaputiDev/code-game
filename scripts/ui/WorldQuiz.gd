## WorldQuiz.gd
## UI controller for the post-world quiz screen.
## Drives a QuizManager and reacts to its signals to update the display.
class_name WorldQuiz extends Control

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _quiz_manager: QuizManager = $QuizManager

# Question view
@onready var _question_view: Control     = $QuestionView
@onready var _counter_label: Label       = $QuestionView/Header/CounterLabel
@onready var _question_label: RichTextLabel = $QuestionView/QuestionLabel
@onready var _pseudocode_label: RichTextLabel = $QuestionView/PseudocodeLabel
@onready var _options_container: VBoxContainer = $QuestionView/OptionsContainer
@onready var _feedback_panel: PanelContainer   = $QuestionView/FeedbackPanel
@onready var _feedback_icon: Label    = $QuestionView/FeedbackPanel/HBox/FeedbackIcon
@onready var _feedback_label: Label   = $QuestionView/FeedbackPanel/HBox/FeedbackLabel
@onready var _explanation_label: RichTextLabel = $QuestionView/FeedbackPanel/ExplanationLabel
@onready var _next_question_button: Button     = $QuestionView/FeedbackPanel/NextButton

# Result view
@onready var _result_view: Control  = $ResultView
@onready var _score_label: Label    = $ResultView/VBox/ScoreLabel
@onready var _continue_button: Button = $ResultView/VBox/ContinueButton
@onready var _retry_button: Button    = $ResultView/VBox/RetryButton

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _world_index: int = 0
var _option_buttons: Array[Button] = []
var _answer_submitted: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_world_index = GameState.current_world

	_quiz_manager.question_presented.connect(_on_question_presented)
	_quiz_manager.answer_evaluated.connect(_on_answer_evaluated)
	_quiz_manager.quiz_finished.connect(_on_quiz_finished)

	_next_question_button.pressed.connect(_on_next_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)

	_result_view.visible = false
	_feedback_panel.visible = false

	EventBus.play_music.emit("quiz")
	_quiz_manager.start_quiz(_world_index)

# ---------------------------------------------------------------------------
# Question display
# ---------------------------------------------------------------------------

func _on_question_presented(question: Question, number: int, total: int) -> void:
	_answer_submitted = false
	_feedback_panel.visible = false

	_counter_label.text = tr("QUIZ_QUESTION_COUNTER") % [number, total]
	_question_label.text = question.question_text

	# Show pseudocode block if present.
	if question.pseudocode != "":
		_pseudocode_label.visible = true
		_pseudocode_label.text = "[code]%s[/code]" % question.pseudocode
	else:
		_pseudocode_label.visible = false

	# Rebuild option buttons.
	for btn in _option_buttons:
		btn.queue_free()
	_option_buttons.clear()

	var letters: Array[String] = ["A", "B", "C", "D"]
	for i in question.options.size():
		var btn := Button.new()
		btn.text = "%s) %s" % [letters[i], question.options[i]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _submit_answer(i))
		_options_container.add_child(btn)
		_option_buttons.append(btn)

# ---------------------------------------------------------------------------
# Answer submission
# ---------------------------------------------------------------------------

func _submit_answer(index: int) -> void:
	if _answer_submitted:
		return
	_answer_submitted = true

	# Disable all buttons while showing feedback.
	for btn in _option_buttons:
		btn.disabled = true

	_quiz_manager.submit_answer(index)

func _on_answer_evaluated(correct: bool, correct_index: int, explanation: String) -> void:
	# Highlight correct / wrong buttons.
	for i in _option_buttons.size():
		if i == correct_index:
			_option_buttons[i].modulate = Color.GREEN
		elif _answer_submitted and not correct and i != correct_index:
			pass  # Leave neutral.

	_feedback_panel.visible = true
	if correct:
		_feedback_icon.text  = "✅"
		_feedback_label.text = tr("QUIZ_CORRECT")
	else:
		_feedback_icon.text  = "❌"
		_feedback_label.text = tr("QUIZ_WRONG")
		# Highlight correct answer.
		if correct_index < _option_buttons.size():
			_option_buttons[correct_index].modulate = Color.GREEN

	_explanation_label.text = explanation
	_next_question_button.text = tr("QUIZ_CONTINUE")

func _on_next_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	_quiz_manager.advance()

# ---------------------------------------------------------------------------
# Result screen
# ---------------------------------------------------------------------------

func _on_quiz_finished(score: int, total: int) -> void:
	_question_view.visible = false
	_result_view.visible = true

	_score_label.text = tr("QUIZ_RESULT_SCORE") % [score, total]

	var passed: bool = score >= ceili(total * 0.66)
	_continue_button.visible = passed
	_retry_button.visible    = not passed

func _on_continue_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	get_tree().change_scene_to_file("res://scenes/menus/WorldSelect.tscn")

func _on_retry_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	get_tree().reload_current_scene()
