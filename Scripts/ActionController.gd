extends Node
class_name ActionController

signal current_action

enum ActionType { 
	ATTACK,
	FORAGE,
	BLOCK,
	IDLE,
}

var action_running = ActionType.IDLE
var old_action = null

func action_active() -> void:
	current_action.emit(action_running)
