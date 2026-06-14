extends Node2D


@export var first_level: PackedScene


@onready var _level_container: Node2D = $LevelContainer
@onready var _menu: Control = $UI/Menu
@onready var _play_button: Label = $UI/Menu/HBoxContainer/PlayButton
@onready var _resume_button: Label = $UI/Menu/HBoxContainer/ResumeButton
@onready var _quit_button: Label = $UI/Menu/HBoxContainer/QuitButton
@onready var _main_menu_button: Label = $UI/Menu/HBoxContainer/MainMenuButton
@onready var _ui_animation_player: AnimationPlayer = $UIAnimationPlayer


var _level: Node = null


func _ready() -> void:
	_update_game_pause()
	_update_menu_buttons()

func _unhandled_input(e: InputEvent) -> void:
	# Don't allow toggling the menu if we're not in a level (in the main menu).
	if e.is_action_pressed("pause") and _level and not _is_in_transition():
		_menu.visible = not _menu.visible
		_update_game_pause()

# Load a level from a `PackedScene` and play a transition animation.
func load_level_from_packed(level_packed_scene: PackedScene) -> void:
	var level: Node = level_packed_scene.instantiate() if level_packed_scene else null

	_menu.visible = not _level

	_do_in_transition(func() -> void: _set_level(level))

# Set the level immediately.
func _set_level(level: Node) -> void:
	for node: Node in _level_container.get_children():
		node.queue_free()
	_level = level
	if _level: _level_container.add_child(_level)
	_update_menu_buttons()
	if not _level: _menu.show()

func _update_game_pause() -> void:
	get_tree().paused = _menu.visible or _is_in_transition()

func _update_menu_buttons() -> void:
	var is_in_level := _level != null
	_play_button.visible = not is_in_level
	_resume_button.visible = is_in_level
	_quit_button.visible = not is_in_level
	_main_menu_button.visible = is_in_level

func _is_in_transition() -> bool:
	return _ui_animation_player.is_playing()

# Play a transition animation, and call `proc` in the middle. Will do nothing if a transition is currently playing.
func _do_in_transition(f: Callable) -> void:
	if _is_in_transition(): return

	_ui_animation_player.play("transition_enter")
	await _ui_animation_player.animation_finished
	_update_game_pause()

	f.call()
	_ui_animation_player.play("transition_leave")
	await _ui_animation_player.animation_finished
	_update_game_pause()


func _on_play_button_pressed() -> void:
	load_level_from_packed(first_level)
	_menu.hide()
	_update_game_pause()

func _on_resume_button_pressed() -> void:
	_menu.hide()
	_update_game_pause()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_main_menu_button_pressed() -> void:
	load_level_from_packed(null)
