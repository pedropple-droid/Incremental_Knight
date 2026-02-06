extends Node
class_name DataHandler

const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const DIGIT_BASE_SIZE := 6
const DIGIT_SCALE := 0.5
const original_output_correction = 0.08
const MIN_OUTPUT_UPGRADE := 1.15
const TOTAL := -1

enum UpgradeType { 
	OUTPUT,
	SPEED,
	TOUGHNESS,
	KNIGHT,
}

@onready var main_controller: MainController = MainController.new()

var in_time := 0.5 / upgrade_anim_speed
var pop_time := 0.2 / upgrade_anim_speed
var out_time := 0.5 / upgrade_anim_speed
var gold: int = 0
var meat: int = 0
var wood: int = 0
var time_left := 120.0
var toughness_level := 0
var timer_speed_multiplier: float = 1.0
var max_knights_per_run: int = 3
var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.5
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var heat := 1.8
var output_multiplier := 2.0
var output_floor := 1.0
var knight_set_level := 0
var total_knights: int = 1
var output := 1.0

func knights_per_purchase():
	return int(pow(3, knight_set_level))


func update_output_from_knights():
	output *= total_knights


func check_resource_gain(action: ActionController.ActionType):
	match action:
		ActionController.ActionType.ATTACK:
			@warning_ignore("narrowing_conversion")
			gold += output 
			print(gold, meat, wood)
		ActionController.ActionType.FORAGE:
			@warning_ignore("narrowing_conversion")
			meat += output
			print(gold, meat, wood)
		ActionController.ActionType.BLOCK:
			@warning_ignore("narrowing_conversion")
			wood += output
			print(gold, meat, wood)
		ActionController.ActionType.IDLE:
			pass


func can_buy(type: UpgradeType) -> bool:
	var up = main_controller.upgrades[type]
	if wood < up["wood_cost"]:
		return false
	if meat < up["meat_cost"]:
		return false
	if gold < up["gold_cost"]:
		return false
	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		return false
	return true


func try_buy_upgrade(type: UpgradeType) -> void:
	var up = main_controller.upgrades[type]

	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		main_controller.knight_label.text = "Maxed out!!"
		return

	wood -= up.wood_cost
	meat -= up.meat_cost
	gold -= up.gold_cost
	up.apply.call()
	up.wood_cost = int(up.wood_cost * up.cost_mult)
	up.meat_cost = int(up.meat_cost * up.cost_mult)
	up.gold_cost = int(up.gold_cost * up.cost_mult)

	update_upgrade_cost(type)
	update_floating_totals()


func update_upgrade_cost(type: UpgradeType) -> void:
	var up = main_controller.upgrades[type]
	var containers = visual_controller.upgrade_digit_containers[type]
	visual_controller.set_crossroad(up, containers)
