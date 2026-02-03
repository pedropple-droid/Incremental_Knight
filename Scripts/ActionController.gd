extends Node
class_name ActionController

signal current_action

enum ActionType { 
	ATTACK,
	FORAGE,
	BLOCK,
	IDLE,
}

var actions := {
	ActionType.ATTACK: {
		"animation": "attack",
		"resource": "gold",
	},
	ActionType.FORAGE: {
		"animation": "forage",
		"resource": "meat",
	},
	ActionType.BLOCK: {
		"animation": "block",
		"resource": "wood",
	},
	ActionType.IDLE: {
		"animation": "idle",
		"resource": null,
	}
}

var action_running = ActionType.IDLE
var old_action = null

func action_clicked(action: ActionType) -> void:
	if action_running != ActionType.IDLE:
		return
	old_action = action_running
	action_running = action
	current_action.emit(action_running)

func action_active() -> void:
	current_action.emit(action_running)
