extends Node2D


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused


func _update_game_pause() -> void:
	pass
