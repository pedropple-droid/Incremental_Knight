extends Node
class_name ActionController

signal queued_action

enum ActionType { 
	ATTACK,
	FORAGE,
	BLOCK,
	IDLE,
}

var action_to_play = null
var old_button = null

func _on_action_pressed(action_type: ActionController.ActionType, button_type: Button) -> void:
	action_to_play = action_type
	old_button = button_type
	queued_action.emit(action_to_play, old_button)
