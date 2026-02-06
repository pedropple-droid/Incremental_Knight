extends Node
class_name UpgradeController

@onready var data_handler: DataHandler = DataHandler.new()
@onready var visual_controller: VisualController = VisualController.new()


func _ready() -> void:
	add_child(data_handler)
