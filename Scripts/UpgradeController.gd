extends Node
class_name UpgradeController

var current_upgrade: UpgradeType

enum UpgradeType { 
	TOTAL,
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
			output_floor *= output_multiplier
			output_multiplier -= DataHandler.original_output_correction
			output_multiplier = max(
			output_multiplier,
			DataHandler.MIN_OUTPUT_UPGRADE,
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
			toughness_level += 1
			timer_speed_multiplier *= 0.9,
	},
	UpgradeType.KNIGHT: {
		"wood_cost": 4000,
		"meat_cost": 5500,
		"gold_cost": 8500,
		"cost_mult": 2.5,
		"apply": func():
			var amount = knights_per_purchase()
			total_knights += amount
			update_knight_visuals()
			update_output_from_knights(),
	},
}
