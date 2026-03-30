## BaseMechanic.gd
## Abstract base class for all interactive puzzle mechanics.
##
## All mechanics in CodeGame (doors, buttons, variable blocks, portals, etc.)
## extend this class. It provides:
##   - A unique mechanic_id for telemetry identification.
##   - An activated / deactivated signal pair.
##   - A virtual evaluate_condition() entry-point for subclasses.
##   - Automatic EventBus notification on state change.
##   - Optional ConceptHint display when the player enters the trigger area.
##
## Usage:
##   class_name MyMechanic extends BaseMechanic
##   func evaluate_condition() -> bool: return my_state
##   func on_activate() -> void: do_something()
class_name BaseMechanic extends Node2D

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted when the mechanic transitions to the active state.
signal activated()

## Emitted when the mechanic transitions to the inactive state.
signal deactivated()

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

## Unique identifier used in telemetry and for cross-mechanic references.
@export var mechanic_id: String = ""

## Human-readable mechanic type label (e.g. "conditional_door", "logic_button").
@export var mechanic_type: String = ""

## Programming concept this mechanic teaches (e.g. "if", "and", "variable").
@export var concept: String = ""

## Pseudocode string shown in the ConceptHint balloon when activated.
@export_multiline var hint_pseudocode: String = ""

## If true, shows the concept hint balloon when the player enters proximity.
@export var show_hint_on_proximity: bool = true

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

## Current activation state of this mechanic.
var is_active: bool = false:
	set(value):
		if value == is_active:
			return
		is_active = value
		if is_active:
			on_activate()
			activated.emit()
			EventBus.mechanic_activated.emit(mechanic_id, mechanic_type)
			if concept != "" and hint_pseudocode != "":
				EventBus.show_concept_hint.emit(concept, hint_pseudocode)
		else:
			on_deactivate()
			deactivated.emit()
			EventBus.mechanic_deactivated.emit(mechanic_id, mechanic_type)

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	# Ensure mechanics have an ID — fallback to scene-relative path.
	if mechanic_id == "":
		mechanic_id = get_path()
	_on_ready()

## Virtual. Called by _ready() — override instead of _ready() in subclasses.
func _on_ready() -> void:
	pass

# ---------------------------------------------------------------------------
# Virtual interface — override in subclasses
# ---------------------------------------------------------------------------

## Override to implement the condition logic for this mechanic.
## Called by [method refresh] to determine the new state.
func evaluate_condition() -> bool:
	return false

## Override to define what happens when this mechanic activates.
func on_activate() -> void:
	pass

## Override to define what happens when this mechanic deactivates.
func on_deactivate() -> void:
	pass

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Forces a re-evaluation of the mechanic's condition and updates is_active.
## Call this whenever an upstream input (button, variable, etc.) changes.
func refresh() -> void:
	is_active = evaluate_condition()

## Forcefully activates this mechanic without re-evaluating the condition.
func force_activate() -> void:
	is_active = true

## Forcefully deactivates this mechanic without re-evaluating the condition.
func force_deactivate() -> void:
	is_active = false
