## Question.gd
## Resource class representing a single quiz question.
##
## Create instances of this resource via File > New Resource > Question
## in the Godot editor, or programmatically via QuizData.gd.
##
## Supports two formats:
##   MULTIPLE_CHOICE — Player selects one option from A–D.
##   FILL_PSEUDOCODE — Player selects the missing piece in a pseudocode block.
class_name Question extends Resource

# ---------------------------------------------------------------------------
# Enums
# ---------------------------------------------------------------------------

enum QuestionType { MULTIPLE_CHOICE, FILL_PSEUDOCODE }

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## Unique ID for tracking performance per question in telemetry.
@export var question_id: String = ""

## Which world this question belongs to.
@export var world: int = 0

## Programming concept being tested.
@export var concept: String = ""

## Format of the question.
@export var type: QuestionType = QuestionType.MULTIPLE_CHOICE

## Difficulty rating (1 = Easy, 5 = Hard).
@export_range(1, 5) var difficulty: int = 1

## The question text (localization key or direct text).
@export_multiline var question_text: String = ""

## For FILL_PSEUDOCODE: the full pseudocode block displayed above the options.
## Use "___" to mark the blank the student must fill.
@export_multiline var pseudocode: String = ""

## Answer choices. For MULTIPLE_CHOICE: 4 items (A, B, C, D).
## For FILL_PSEUDOCODE: 4 possible fill-ins.
@export var options: Array[String] = []

## Index (0-based) of the correct option.
@export var correct_index: int = 0

## Explanation shown after the player answers (right or wrong).
@export_multiline var explanation: String = ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

## Returns the text of the correct option.
func get_correct_text() -> String:
	if correct_index < options.size():
		return options[correct_index]
	return ""

## Returns true if [choice_index] is the correct answer.
func is_correct(choice_index: int) -> bool:
	return choice_index == correct_index
