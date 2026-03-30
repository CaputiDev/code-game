## HUD.gd
## In-game heads-up display showing world/level info, attempt counter,
## and the current programming concept being taught.
class_name HUD extends CanvasLayer

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _world_label: Label   = $HUDPanel/HBox/WorldLabel
@onready var _level_label: Label   = $HUDPanel/HBox/LevelLabel
@onready var _attempt_label: Label = $HUDPanel/HBox/AttemptLabel
@onready var _concept_tag: Label   = $HUDPanel/HBox/ConceptTag
@onready var _player_label: Label  = $HUDPanel/HBox/PlayerLabel

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	EventBus.level_started.connect(_on_level_started)
	EventBus.player_attempt_failed.connect(_on_attempt_failed)
	_player_label.text = GameState.player_display_name

func _on_level_started(world: int, level: int, concept: String) -> void:
	_world_label.text   = "%s %d" % [tr("HUD_WORLD"), world]
	_level_label.text   = "%s %d" % [tr("HUD_LEVEL"), level + 1]
	_attempt_label.text = "%s: 1" % tr("HUD_ATTEMPTS")
	_concept_tag.text   = concept.to_upper()

func _on_attempt_failed(_world: int, _level: int) -> void:
	_attempt_label.text = "%s: %d" % [tr("HUD_ATTEMPTS"), GameState.current_attempts]
	# Flash the attempt label red.
	var tween := _attempt_label.create_tween()
	tween.tween_property(_attempt_label, "modulate", Color.RED, 0.1)
	tween.tween_property(_attempt_label, "modulate", Color.WHITE, 0.3)
