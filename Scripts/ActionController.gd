extends Node
class_name ActionController
@onready var main: Control = $"."

enum ActionType {
	IDLE,
	ATTACK,
	BLOCK,
	FORAGE,
}

var animations: Array = []
var animation_running = null
var performing := false

func _ready() -> void:
	main.action_queued.connect()

func setup(animations_avaiable) -> void:
	animations = animations_avaiable

func action_queued() -> void:
	pass

func action_active() -> void:
	pass

func action_ended() -> void:
	pass
