extends Node
<<<<<<< HEAD
class_name ActionController
@onready var main: Control = $"."
=======
>>>>>>> parent of 5ddee56 (0.1.1.5.6)


<<<<<<< HEAD
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
=======
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
>>>>>>> parent of 5ddee56 (0.1.1.5.6)
	pass
