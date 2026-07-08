@tool
class_name ButtonComponent
extends Node
## When set as the child of any control, allows it to behave like a button.


signal pressed()


## "_normal" and "_hovered" will be appended to this to get the type variations with
@export var theme_type_variation_base: String = ""


@onready var _control: Control = get_parent() as Control


var _is_hovered := false
var _is_pressed := false


func _ready() -> void:
	if not _control: return

	_control.mouse_filter = Control.MOUSE_FILTER_STOP

	if not Engine.is_editor_hint():
		_control.mouse_entered.connect(_on_control_mouse_entered)
		_control.mouse_exited.connect(_on_control_mouse_exited)
		_control.gui_input.connect(_on_control_gui_input)

	_update_appearance()

func _on_control_mouse_entered() -> void:
	_is_hovered = true
	UiSoundEffects.play("ui_menu_mouse_over")
	_update_appearance()

func _on_control_mouse_exited() -> void:
	_is_hovered = false
	_update_appearance()

func _on_control_gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or event is not InputEventMouseButton: return

	if event.button_index == MOUSE_BUTTON_LEFT and not event.is_echo():
		if event.is_pressed():
			_is_pressed = true
		elif event.is_released():
			_is_pressed = false
			if _is_hovered:
				pressed.emit()
				UiSoundEffects.play("ui_menu_click")

func _update_appearance() -> void:
	if not _control: return

	if _is_hovered:
		_set_control_to_mode("hovered")
	elif not _is_hovered:
		_set_control_to_mode("normal")

func _set_control_to_mode(mode: String) -> void:
	var type_variation := _get_type_variation_name(mode)
	_control.theme_type_variation = type_variation

func _get_type_variation_name(mode: String) -> String:
	return "%s_%s" % [theme_type_variation_base, mode]
