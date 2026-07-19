@tool
class_name EditorVisibilityComponent
extends Node
## Allows you to control the visibility of the parent [CanvasItem] separately in-game and in-editor.


@export var visible_in_editor: bool = true :
	set(v):
		visible_in_editor = v
		_update_visibility()

@export var visible_in_game: bool = true :
	set(v):
		visible_in_game = v
		_update_visibility()


@onready var _parent := get_parent() as CanvasItem


func _ready() -> void:
	_update_visibility()


func _update_visibility() -> void:
	if not _parent: return
	if Engine.is_editor_hint():
		_parent.visible = visible_in_editor
	else:
		_parent.visible = visible_in_game
