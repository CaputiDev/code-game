## EventBus.gd
## Global signal bus for decoupled communication between game systems.
## All game systems emit and connect signals through this singleton,
## avoiding tight coupling between scenes and scripts.
extends Node

# ---------------------------------------------------------------------------
# Session / Player
# ---------------------------------------------------------------------------

## Emitted when the player profile is set (first boot or saved).
signal player_profile_set(player_name: String)

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------

## Emitted when a transition to a new scene is requested.
signal scene_transition_requested(scene_path: String)

## Emitted after a scene finishes loading.
signal scene_loaded(scene_path: String)

# ---------------------------------------------------------------------------
# Level lifecycle
# ---------------------------------------------------------------------------

## Emitted when a level begins (after fade-in).
signal level_started(world: int, level: int, concept: String)

## Emitted when the player successfully completes a level.
## [param data] contains telemetry payload (see TelemetryManager).
signal level_completed(data: Dictionary)

## Emitted each time the player dies / resets the attempt.
signal player_attempt_failed(world: int, level: int)

## Emitted when the player opens the pause menu.
signal game_paused()

## Emitted when the game resumes from pause.
signal game_resumed()

# ---------------------------------------------------------------------------
# Mechanics
# ---------------------------------------------------------------------------

## Emitted when any BaseMechanic activates.
signal mechanic_activated(mechanic_id: String, mechanic_type: String)

## Emitted when any BaseMechanic deactivates.
signal mechanic_deactivated(mechanic_id: String, mechanic_type: String)

## Emitted when a ConditionalDoor state changes.
signal door_state_changed(door_id: String, is_open: bool)

## Emitted when a VariableBlock value changes.
signal variable_changed(var_name: String, old_value: Variant, new_value: Variant)

## Emitted when a FunctionPortal records a new action sequence.
signal function_recorded(portal_id: String, action_count: int)

## Emitted when a FunctionPortal executes its recorded sequence.
signal function_executed(portal_id: String)

# ---------------------------------------------------------------------------
# Bugs (logical obstacles)
# ---------------------------------------------------------------------------

## Emitted when a Bug enemy is eliminated through logic.
signal bug_eliminated(bug_id: String, concept: String)

# ---------------------------------------------------------------------------
# UI / HUD
# ---------------------------------------------------------------------------

## Emitted to show a concept hint balloon over a mechanic.
## [param concept] is the programming concept key (e.g. "if", "and", "variable").
## [param pseudocode] is the short pseudocode string to display.
signal show_concept_hint(concept: String, pseudocode: String)

## Emitted to hide the concept hint balloon.
signal hide_concept_hint()

# ---------------------------------------------------------------------------
# Quiz
# ---------------------------------------------------------------------------

## Emitted when the player submits a quiz answer.
signal quiz_answered(data: Dictionary)

## Emitted when the entire world quiz is completed.
signal quiz_completed(world: int, score: int, total: int)

# ---------------------------------------------------------------------------
# Audio
# ---------------------------------------------------------------------------

## Emitted to play a sound effect by key.
signal play_sfx(sfx_key: String)

## Emitted to play background music by key.
signal play_music(music_key: String)

## Emitted to stop background music.
signal stop_music()
