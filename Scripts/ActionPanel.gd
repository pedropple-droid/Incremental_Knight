extends Button
class_name ActionPanel

@export var action_type: ActionController.ActionType

signal action_pressed(action_type)

func _pressed():
	action_pressed.emit(action_type)
