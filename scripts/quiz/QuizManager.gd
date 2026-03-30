## QuizManager.gd
## Manages the state of a quiz session for a single world.
##
## Flow:
##   1. Instantiate / attach this script to a WorldQuiz scene.
##   2. Call start_quiz(world_index) to load questions.
##   3. Call submit_answer(option_index) to record the player's answer.
##   4. Listen to [question_presented] and [quiz_finished] signals to drive UI.
class_name QuizManager extends Node

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when a new question should be displayed.
signal question_presented(question: Question, question_number: int, total: int)

## Emitted after a player submits an answer.
## [param correct] whether the answer was correct.
## [param correct_index] the index of the right answer.
## [param explanation] the explanation text.
signal answer_evaluated(correct: bool, correct_index: int, explanation: String)

## Emitted when all questions have been answered.
signal quiz_finished(score: int, total: int)

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------

var _world: int = 0
var _questions: Array[Question] = []
var _current_index: int = 0
var _score: int = 0
var _question_start_time: int = 0
var _attempt_counts: Dictionary = {}  # question_id → attempts_on_this_question

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Starts a quiz for the given world. Loads questions from QuizData.
func start_quiz(world_index: int) -> void:
	_world           = world_index
	_questions       = QuizData.get_questions_for_world(world_index).duplicate()
	_current_index   = 0
	_score           = 0
	_attempt_counts  = {}

	if _questions.is_empty():
		push_warning("[QuizManager] No questions found for world %d." % world_index)
		quiz_finished.emit(0, 0)
		return

	_present_current()

## Submits an answer for the current question.
## [param option_index] is 0-based (A=0, B=1, C=2, D=3).
func submit_answer(option_index: int) -> void:
	if _current_index >= _questions.size():
		return

	var q: Question = _questions[_current_index]
	var correct: bool = q.is_correct(option_index)
	var elapsed_s: float = (Time.get_ticks_msec() - _question_start_time) / 1000.0

	_attempt_counts[q.question_id] = _attempt_counts.get(q.question_id, 0) + 1

	# Telemetry event.
	var attempt_num: int = _attempt_counts[q.question_id]
	EventBus.quiz_answered.emit({
		"world":        _world,
		"question_id":  q.question_id,
		"concept":      q.concept,
		"correct":      correct,
		"choice_index": option_index,
		"attempts":     attempt_num,
		"time_seconds": snappedf(elapsed_s, 0.1),
	})

	if correct:
		_score += 1
		EventBus.play_sfx.emit("quiz_correct")
	else:
		EventBus.play_sfx.emit("quiz_wrong")

	answer_evaluated.emit(correct, q.correct_index, q.explanation)

## Advances to the next question. Call after showing explanation feedback.
func advance() -> void:
	_current_index += 1
	if _current_index >= _questions.size():
		_finish()
	else:
		_present_current()

## Returns the current question (for external UI inspection).
func get_current_question() -> Question:
	if _current_index < _questions.size():
		return _questions[_current_index]
	return null

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _present_current() -> void:
	_question_start_time = Time.get_ticks_msec()
	var q: Question = _questions[_current_index]
	question_presented.emit(q, _current_index + 1, _questions.size())

func _finish() -> void:
	GameState.record_quiz_score(_world, _score)
	EventBus.quiz_completed.emit(_world, _score, _questions.size())
	SaveManager.save()
	quiz_finished.emit(_score, _questions.size())
