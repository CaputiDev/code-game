## LevelAssessment.gd
## Onboarding screen that determines the player's starting point.
## Offers a "Beginner" (progressive) or "Expert" (knowledge test) path.
extends Control

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _choice_view: Control      = %ChoiceView
@onready var _quiz_view: Control        = %QuizView
@onready var _result_view: Control      = %ResultView

@onready var _beginner_button: Button   = %BeginnerButton
@onready var _expert_button: Button     = %ExpertButton
@onready var _finish_button: Button     = %FinishButton

@onready var _progress_label: Label     = %ProgressLabel
@onready var _question_text: RichTextLabel = %QuestionText
@onready var _options_container: VBoxContainer = %OptionsContainer
@onready var _result_text: Label        = %ResultText

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _current_question_index: int = 0
var _questions: Array[Question] = []
var _passed_worlds: Array[int] = []
var _is_evaluating: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_choice_view.visible = true
	_quiz_view.visible   = false
	_result_view.visible = false

	_beginner_button.pressed.connect(_on_beginner_selected)
	_expert_button.pressed.connect(_on_expert_selected)
	_finish_button.pressed.connect(_on_finish_pressed)

# ---------------------------------------------------------------------------
# Choice Handlers
# ---------------------------------------------------------------------------

func _on_beginner_selected() -> void:
	EventBus.play_sfx.emit("ui_click")
	# Beginner: Start standard progression (World 0 only).
	GameState.unlock_content_by_assessment([])
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_expert_selected() -> void:
	EventBus.play_sfx.emit("ui_click")
	_start_assessment()

# ---------------------------------------------------------------------------
# Assessment Logic
# ---------------------------------------------------------------------------

func _start_assessment() -> void:
	_choice_view.visible = false
	_quiz_view.visible   = true
	_is_evaluating       = true

	# Select 1 representative question from each world (Difficulty 2-3).
	_questions.clear()
	for world_idx in range(4):
		var full_bank: Array[Question] = QuizData.get_questions_for_world(world_idx)
		# Pick 1 question around difficulty 2 or 3 for baseline testing.
		var q: Question = null
		for candidate in full_bank:
			if candidate.difficulty == 3:
				q = candidate
				break
		if not q and not full_bank.is_empty():
			q = full_bank[0]
		
		if q:
			_questions.append(q)

	_current_question_index = 0
	_passed_worlds.clear()
	_present_question()

func _present_question() -> void:
	if _current_question_index >= _questions.size():
		_show_results()
		return

	var q: Question = _questions[_current_question_index]
	var concept_name: String = q.concept.capitalize()
	_progress_label.text = "Conceito: %s (%d/%d)" % [concept_name, _current_question_index + 1, _questions.size()]
	_question_text.text = q.question_text

	# Clear previous options.
	for child in _options_container.get_children():
		child.queue_free()

	for i in q.options.size():
		var btn: Button = Button.new()
		btn.text = q.options[i]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _on_option_selected(i))
		_options_container.add_child(btn)

func _on_option_selected(index: int) -> void:
	if not _is_evaluating:
		return

	var q: Question = _questions[_current_question_index]
	if q.is_correct(index):
		_passed_worlds.append(q.world)
		EventBus.play_sfx.emit("quiz_correct")
	else:
		EventBus.play_sfx.emit("quiz_wrong")

	_current_question_index += 1
	_present_question()

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------

func _show_results() -> void:
	_is_evaluating = false
	_quiz_view.visible   = false
	_result_view.visible = true

	GameState.unlock_content_by_assessment(_passed_worlds)
	
	if _passed_worlds.is_empty():
		_result_text.text = "O teste mostrou que é melhor você começar pela introdução para garantir uma base sólida. Vamos lá!"
	else:
		var max_unlocked: int = 0
		if _passed_worlds.size() > 0:
			max_unlocked = _passed_worlds.max() + 1
		
		_result_text.text = "Impressionante! Com base nos seus acertos, desbloqueamos até o Mundo %d para você.\n(Lembrando que as estrelas estão em 0 para você poder platinar depois!)" % max_unlocked

func _on_finish_pressed() -> void:
	EventBus.play_sfx.emit("ui_click")
	SaveManager.save()
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
