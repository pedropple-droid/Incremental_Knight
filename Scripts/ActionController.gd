extends Node
class_name ActionController

enum ActionType {
	IDLE,
	ATTACK,
	BLOCK,
	FORAGE,
}

signal action_started(action)
signal action_active(action)
signal action_ended(action)

var animations: Array = []
var animation_running = null
var performing := false

func setup(animations_avaiable) -> void:
	animations = animations_avaiable

func start() -> void:
	if performing:
		return
	performing = true
	_loop()

func stop() -> void:
	performing = false

func _loop() -> void:
	while performing:
		await get_tree().process_frame
		_start_animation()

func _start_animation() -> void:
	if animations.is_empty():
		return

	
