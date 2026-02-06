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
		_set_queue(action)
		return

	_start_action(action)


func animation_finished() -> void:
	is_busy = false
	_apply_queued_action()


func _set_queue(action: ActionType) -> void:
	if action == current_action:
		queued_action = ActionType.IDLE
	else:
		queued_action = action


func _apply_queued_action() -> void:
	if queued_action == ActionType.IDLE:
		_enter_idle()
		return

	_start_action(queued_action)


func _start_action(action: ActionType) -> void:
	current_action = action
	is_busy = true
	action_changed.emit(current_action)


func _enter_idle() -> void:
	current_action = ActionType.IDLE
	is_busy = false
	action_changed.emit(current_action)
