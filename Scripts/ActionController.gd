extends Node
class_name ActionController

signal action_changed(new_action: ActionType)

enum ActionType {
	ATTACK,
	FORAGE,
	BLOCK,
	IDLE,
}

var current_action: ActionType = ActionType.IDLE
var queued_action: ActionType = ActionType.IDLE
var is_busy := false

func request_action(action: ActionType) -> void:
	if is_busy:
		if action == current_action:
			queued_action = ActionType.IDLE
		else:
			queued_action = action
		return

	queued_action = action
	_apply_queued_action()

func animation_finished() -> void:
	is_busy = false
	_apply_queued_action()

func _apply_queued_action() -> void:
	current_action = queued_action
	is_busy = true
	action_changed.emit(current_action)
