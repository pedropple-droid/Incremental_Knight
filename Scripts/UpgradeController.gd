extends Node
class_name UpgradeController

@onready var data_handler: DataHandler = DataHandler.new()

var current_upgrade: UpgradeType

func _ready() -> void:
	add_child(data_handler)

enum UpgradeType { 
	OUTPUT,
	SPEED,
	TOUGHNESS,
	KNIGHT,
}

var upgrades := {
	UpgradeType.OUTPUT: {
		"wood_cost": 75,
		"meat_cost": 125,
		"gold_cost": 200,
		"cost_mult": 2.0,
		"apply": func():
			@warning_ignore("narrowing_conversion")
			data_handler.output_floor *= data_handler.output_multiplier
			data_handler.output_multiplier -= data_handler.original_output_correction
			data_handler.output_multiplier = max(
			data_handler.output_multiplier,
			data_handler.MIN_OUTPUT_UPGRADE,
		),
	},
	UpgradeType.SPEED: {
		"wood_cost": 4,
		"meat_cost": 5,
		"gold_cost": 10,
		"cost_mult": 1.5,
		"apply": func():
			pass,
	},
	UpgradeType.TOUGHNESS: {
		"wood_cost": 20,
		"meat_cost": 30,
		"gold_cost": 40,
		"cost_mult": 2.0,
		"apply": func():
			data_handler.toughness_level += 1
			data_handler.timer_speed_multiplier *= 0.9,
	},
	UpgradeType.KNIGHT: {
		"wood_cost": 4000,
		"meat_cost": 5500,
		"gold_cost": 8500,
		"cost_mult": 2.5,
		"apply": func():
			var amount = data_handler.knights_per_purchase()
			data_handler.total_knights += amount
			data_handler.update_output_from_knights(),
	},
}
