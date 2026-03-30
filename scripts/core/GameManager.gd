## GameManager.gd
## Application bootstrap script.
## Attached to the GameManager autoload node or a root scene.
##
## Responsibilities:
##   1. Load save data on startup.
##   2. Route the player to PlayerSetup (first boot) or MainMenu (returning).
##   3. Handle application quit request cleanly.
extends Node

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)

	# Load save → populates GameState.
	var has_save: bool = SaveManager.load_save()

	if not has_save or GameState.player_first_name == "":
		# First boot — go to name setup.
		get_tree().change_scene_to_file("res://scenes/menus/PlayerSetup.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save()
		TelemetryManager._persist_queue()
		get_tree().quit()
