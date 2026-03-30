## ConceptHint.gd
## A floating "balloon" UI element that displays the programming concept
## and matching pseudocode when the player activates a mechanic.
##
## Appears smoothly, stays for a configurable duration, then fades out.
## Listens to EventBus.show_concept_hint and EventBus.hide_concept_hint.
class_name ConceptHint extends CanvasLayer

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## How long the hint stays visible before fading (seconds).
@export var display_duration: float = 4.0

## Fade in / out duration (seconds).
@export var fade_duration: float = 0.25

# ---------------------------------------------------------------------------
# Node references
# ---------------------------------------------------------------------------

@onready var _panel: PanelContainer      = $Panel
@onready var _concept_title: Label       = $Panel/VBox/ConceptTitle
@onready var _pseudocode_label: RichTextLabel = $Panel/VBox/PseudocodeLabel

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

var _hide_timer: SceneTreeTimer = null
var _fade_tween: Tween = null

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	_panel.modulate.a = 0.0
	EventBus.show_concept_hint.connect(_on_show_hint)
	EventBus.hide_concept_hint.connect(hide_hint)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func show_hint(concept: String, pseudocode: String) -> void:
	# Map concept key to translated title.
	var title_key: String = "HINT_%s_TITLE" % concept.to_upper()
	_concept_title.text = tr(title_key) if TranslationServer.has_message(title_key) else concept

	# Display pseudocode in monospace.
	_pseudocode_label.text = "[code]%s[/code]" % pseudocode

	# Cancel any pending hide.
	if _hide_timer:
		_hide_timer = null
	if _fade_tween:
		_fade_tween.kill()

	# Fade in.
	_fade_tween = create_tween()
	_fade_tween.tween_property(_panel, "modulate:a", 1.0, fade_duration)

	# Schedule auto-hide.
	_hide_timer = get_tree().create_timer(display_duration)
	_hide_timer.timeout.connect(hide_hint)

func hide_hint() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_panel, "modulate:a", 0.0, fade_duration)

# ---------------------------------------------------------------------------
# EventBus handler
# ---------------------------------------------------------------------------

func _on_show_hint(concept: String, pseudocode: String) -> void:
	show_hint(concept, pseudocode)
