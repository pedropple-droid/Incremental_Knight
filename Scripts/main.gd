# add a mouse hidden animation for action hold and upgrade success
# qte still kinda sucks, it's kinda just there in number and in visual
# still about qte, i could add a differente color meter for when my knight is 
# waiting to finish an action to perform another one, or, maybe, make different
# animations for him to change between actions so qte would make more sense in a sense
# fixd some numbers, game might go much smoother now, but i do need to add difficulty increase

extends Control

const MAIN_2 = preload("uid://ey2i670agjff")

const original_output_correction = 0.08
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15
const DIGIT_BASE_SIZE := 6
const DIGIT_SCALE := 0.5

const CURSOR_01 = preload("uid://bigflnfdn68dm")
const CURSOR_02 = preload("uid://cxshok2ga3xac")
const CURSOR_03 = preload("uid://7jg0px7vfs51")
const CURSOR_04 = preload("uid://m2j7b6we60s3")
const SMALL_RED_SQUARE_BUTTON_REGULAR = preload("uid://cwxlgqhhovp82")
const SMALL_RED_SQUARE_BUTTON_PRESSED = preload("uid://bd3ec46nfqfdd")
const WOODEIGHT = preload("uid://bhkspl4ccxfw1")
const WOODFIVE = preload("uid://d372enmkxh3uv")
const WOODFOUR = preload("uid://bs518fa5fw1dq")
const WOODNINE = preload("uid://detx2fiyifthq")
const WOODONE = preload("uid://de05num5hud5e")
const WOODSEVEN = preload("uid://24qi0j0ipoea")
const WOODSIX = preload("uid://csw5wob8r56pg")
const WOODTHREE = preload("uid://bixtv427vmrr1")
const WOODTWO = preload("uid://cmysxjbm5vjun")
const WOODZERO = preload("uid://c2wfov3tpkcih")
const WOODB = preload("uid://cr0gpnc6franh")
const WOODDOT = preload("uid://cuhmaq0a2nrtr")
const WOODK = preload("uid://c7l2phebs2ogq")
const WOODM = preload("uid://psqabx6t4f86")


enum UpgradeType { 
	TOTAL,
	OUTPUT,
	SPEED,
	TOUGHNESS,
	KNIGHT,
}

enum ActionType {
	IDLE,
	ATTACK,
	BLOCK,
	FORAGE,
}

enum ResourceType {
	WOOD,
	MEAT,
	GOLD,
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
			output_multiplier -= original_output_correction
			output_multiplier = max(
			output_multiplier,
			MIN_OUTPUT_UPGRADE,
		),
	},
	UpgradeType.SPEED: {
		"wood_cost": 4,
		"meat_cost": 5,
		"gold_cost": 10,
		"cost_mult": 1.5,
		"apply": func():
			animation.speed_scale *= 1.1,
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
}

var numbers := {
	ResourceType.WOOD: {
		0: WOODZERO,
		1 : WOODONE,
		2 : WOODTWO,
		3 : WOODTHREE,
		4 : WOODFOUR,
		5 : WOODFIVE,
		6 : WOODSIX,
		7 : WOODSEVEN,
		8 : WOODEIGHT,
		9 : WOODNINE,
	},
	ResourceType.MEAT: {
		0: WOODZERO,
		1 : WOODONE,
		2 : WOODTWO,
		3 : WOODTHREE,
		4 : WOODFOUR,
		5 : WOODFIVE,
		6 : WOODSIX,
		7 : WOODSEVEN,
		8 : WOODEIGHT,
		9 : WOODNINE,
	},
	ResourceType.GOLD: {
		0: WOODZERO,
		1 : WOODONE,
		2 : WOODTWO,
		3 : WOODTHREE,
		4 : WOODFOUR,
		5 : WOODFIVE,
		6 : WOODSIX,
		7 : WOODSEVEN,
		8 : WOODEIGHT,
		9 : WOODNINE,
	},
}

var suffixes := {
	"K": WOODK,
	"M": WOODM,
	"B": WOODB,
	".": WOODDOT,
}

var upgrade_digit_containers := {
	UpgradeType.TOTAL: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	UpgradeType.SPEED: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	UpgradeType.OUTPUT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	UpgradeType.KNIGHT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	UpgradeType.TOUGHNESS: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
}

var upgrade_patches := {
	UpgradeType.SPEED: speed_9p_rect,
	UpgradeType.OUTPUT: output_9p_rect,
	UpgradeType.KNIGHT: e_knight_9p_rect,
	UpgradeType.TOUGHNESS: toughness_9p_rect,
}

var upgrade_buttons := {
	UpgradeType.SPEED: speed_btt,
	UpgradeType.OUTPUT: output_btt,
	UpgradeType.KNIGHT: knight_btt,
	UpgradeType.TOUGHNESS: toughness_btt,
}

var upgrade_panels := {
	UpgradeType.SPEED: spd_panel,
	UpgradeType.OUTPUT: out_put_panel,
	UpgradeType.KNIGHT: knight_panel,
	UpgradeType.TOUGHNESS: toughness_panel,
}

var buttons: Array

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var spd_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/SpdLabel
@onready var output_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/OutputLabel
@onready var knight_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/KnightLabel
@onready var toughness_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/ToughnessLabel
@onready var knight_3: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight3
@onready var knight_2: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight2
@onready var knight: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight
@onready var pawn: Sprite2D = $TabContainer/ResourcesTab/PanelContainer/MarginContainer/HBoxContainer/HutSpace/MarginContainer/Pawn
@onready var gold_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsSpeed
@onready var meat_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsSpeed
@onready var wood_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsSpeed
@onready var gold_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsOutput
@onready var meat_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsOutput
@onready var wood_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsOutput
@onready var gold_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsKnight
@onready var meat_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsKnight
@onready var wood_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsKnight
@onready var gold_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsToughness
@onready var meat_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsToughness
@onready var wood_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsToughness
@onready var wood_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/WoodIcon/WoodDigits
@onready var meat_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/MeatIcon/MeatDigits
@onready var gold_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/GoldIcon/GoldDigits
@onready var block: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block
@onready var forage: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage
@onready var attack: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack
@onready var speed_btt: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton
@onready var output_btt: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton
@onready var knight_btt: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade
@onready var toughness_btt: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton
@onready var attack_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack/Attack9PRect
@onready var forage_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage/Forage9PRect
@onready var block_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block/Block9PRect
@onready var speed_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/Speed9PRect
@onready var output_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/Output9PRect
@onready var e_knight_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/EKnight9PRect
@onready var toughness_9p_rect: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/Toughness9PRect
@onready var timer_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/TimerLabel
@onready var countdown_timer: Timer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/Timer
@onready var upgrade_margin: MarginContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin
@onready var spd_panel: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel
@onready var toughness_panel: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel
@onready var out_put_panel: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel
@onready var knight_panel: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel

var gold: int = 100000
var meat: int = 100000
var wood: int = 100000

var time_left := 120.0
var output_floor := 1.0
var output := 1.0
var output_tween: Tween
var output_multiplier := 2.0
var knight_set_level := 0
var toughness_level := 0
var timer_speed_multiplier: float = 1.0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.5

var last_action: ActionType = ActionType.IDLE
var action_loop_running := false
var pressing = false
var performing = false
var choosing = false
var upgrading = false
var hovering = false

var start_button_position: Vector2

var current_upgrade : UpgradeType
var current_action: ActionType
var current_button: Button

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var heat := 1.8

var at_pawn := false

func _ready() -> void:
	await get_tree().process_frame
	buttons = [attack, block, forage]
	animation.play("idle")
	knight.visible = true
	knight_2.visible = false
	knight_3.visible = false

	upgrade_digit_containers[UpgradeType.SPEED][ResourceType.WOOD] = wood_digits_speed
	upgrade_digit_containers[UpgradeType.SPEED][ResourceType.MEAT] = meat_digits_speed
	upgrade_digit_containers[UpgradeType.SPEED][ResourceType.GOLD] = gold_digits_speed

	upgrade_digit_containers[UpgradeType.OUTPUT][ResourceType.WOOD] = wood_digits_output
	upgrade_digit_containers[UpgradeType.OUTPUT][ResourceType.MEAT] = meat_digits_output
	upgrade_digit_containers[UpgradeType.OUTPUT][ResourceType.GOLD] = gold_digits_output

	upgrade_digit_containers[UpgradeType.KNIGHT][ResourceType.WOOD] = wood_digits_knight
	upgrade_digit_containers[UpgradeType.KNIGHT][ResourceType.MEAT] = meat_digits_knight
	upgrade_digit_containers[UpgradeType.KNIGHT][ResourceType.GOLD] = gold_digits_knight

	upgrade_digit_containers[UpgradeType.TOUGHNESS][ResourceType.WOOD] = wood_digits_toughness
	upgrade_digit_containers[UpgradeType.TOUGHNESS][ResourceType.MEAT] = meat_digits_toughness
	upgrade_digit_containers[UpgradeType.TOUGHNESS][ResourceType.GOLD] = gold_digits_toughness

	upgrade_digit_containers[UpgradeType.TOTAL][ResourceType.WOOD] = wood_digits_total
	upgrade_digit_containers[UpgradeType.TOTAL][ResourceType.MEAT] = meat_digits_total
	upgrade_digit_containers[UpgradeType.TOTAL][ResourceType.GOLD] = gold_digits_total

	upgrade_patches[UpgradeType.SPEED] = speed_9p_rect
	upgrade_patches[UpgradeType.OUTPUT] = output_9p_rect
	upgrade_patches[UpgradeType.KNIGHT] = e_knight_9p_rect
	upgrade_patches[UpgradeType.TOUGHNESS] = toughness_9p_rect
	upgrade_buttons[UpgradeType.SPEED] = speed_btt
	upgrade_buttons[UpgradeType.OUTPUT] = output_btt
	upgrade_buttons[UpgradeType.KNIGHT] = knight_btt
	upgrade_buttons[UpgradeType.TOUGHNESS] = toughness_btt

	update_all_upgrade_costs()
	update_floating_totals()
	start_qte_loop()
	setup_timer()

func _process(delta):
	for type in upgrade_patches.keys():
		update_upgrade_patch(type)
	time_left = max(time_left - delta * timer_speed_multiplier, 0)
	timer_label.text = format_time(time_left)

func setup_timer():
	countdown_timer.start()

func _on_countdown_timer_timeout():
	time_left -= 1.0 * timer_speed_multiplier
	timer_label.text = format_time(time_left)

	if time_left <= 0:
		countdown_timer.stop()
		timer_label.text = "00:00"

func format_time(seconds: float) -> String:
	var s := int(seconds)
	@warning_ignore("integer_division")
	var mins := s / 60
	var secs := s % 60
	return "%02d:%02d" % [mins, secs]

func update_knight_visuals(): 
	knight.visible = total_knights >= 1
	knight_2.visible = total_knights >= 2
	knight_3.visible = total_knights >= 3

func update_all_upgrade_patches() -> void:
	for type in upgrade_patches.keys():
		update_upgrade_patch(type)

func update_upgrade_patch(type: UpgradeType) -> void:
	var patch: NinePatchRect = upgrade_patches[type]
	var button: Button = upgrade_buttons[type]

	if can_buy(type):
		patch.texture = SMALL_RED_SQUARE_BUTTON_REGULAR
		patch.position = Vector2(0, 0)
		button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED 
	else:
		patch.texture = SMALL_RED_SQUARE_BUTTON_PRESSED
		patch.position = Vector2(0, -10)
		button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED

func update_output_from_knights():
	output *= total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func on_upgrade_mouse_entered(type: UpgradeType):
	if upgrading:
		return
	current_upgrade = type
	choosing = true
	start_upgrade_loop()

func on_upgrade_mouse_exited():
	choosing = false
	upgrade_streak = 0
	current_upgrade_delay = BASE_UPGRADE_DELAY
	upgrade_anim_speed = BASE_UPGRADE_DELAY
	if not choosing:
		Input.set_custom_mouse_cursor(CURSOR_01, Input.CURSOR_ARROW, Vector2 (25, 18))

func start_upgrade_loop():
	while choosing:
		upgrading = true
		if can_buy(current_upgrade):
			await do_upgrade_feedback(current_upgrade)
			await get_tree().create_timer(current_upgrade_delay).timeout
		else:
			await get_tree().process_frame
	upgrading = false

func can_buy(type: UpgradeType) -> bool:
	var up = upgrades[type]
	if wood < up["wood_cost"]:
		return false
	if meat < up["meat_cost"]:
		return false
	if gold < up["gold_cost"]:
		return false
	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		return false
	return true

func do_upgrade_feedback(type: UpgradeType):
	var label_type := get_label_from_upgrade(type)
	var in_time := 0.5 / upgrade_anim_speed
	var pop_time := 0.2 / upgrade_anim_speed
	var out_time := 0.5 / upgrade_anim_speed
	var tween = get_tree().create_tween()

	tween = get_tree().create_tween()
	tween.tween_property(
		label_type,
		"theme_override_font_sizes/font_size",
		14,
		in_time
	)
	await tween.finished

	if not choosing:
		tween = get_tree().create_tween()
		tween.tween_property(
			label_type,
			"theme_override_font_sizes/font_size",
			16,
			0.1
		)
		await tween.finished
		return

	try_buy_upgrade(type)

	tween = get_tree().create_tween()
	tween.tween_property(
		label_type,
		"theme_override_font_sizes/font_size",
		24,
		pop_time
	)
	tween.parallel().tween_property(
		label_type,
		"theme_override_constants/outline_size",
		4,
		pop_time
	)
	tween.chain().tween_property(
		label_type,
		"theme_override_font_sizes/font_size",
		16,
		out_time
	)
	tween.parallel().tween_property(
		label_type,
		"theme_override_constants/outline_size",
		0,
		out_time
	)
	await tween.finished

func get_label_from_upgrade(type: UpgradeType) -> Label:
	match type:
		UpgradeType.SPEED:
			return spd_label
		UpgradeType.OUTPUT:
			return output_label
		UpgradeType.KNIGHT:
			return knight_label
		UpgradeType.TOUGHNESS:
			return toughness_label
	return null

func try_buy_upgrade(type: UpgradeType) -> void:
	var up = upgrades[type]

	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
		return

	upgrade_streak += 1

	if upgrade_streak >= STREAK_THRESHOLD:
		current_upgrade_delay = max(
			MIN_UPGRADE_DELAY,
			current_upgrade_delay * 0.85
		)

		upgrade_anim_speed = min(
			3.0,
			upgrade_anim_speed * 1.15
		)

	wood -= up.wood_cost
	meat -= up.meat_cost
	gold -= up.gold_cost
	up.apply.call()
	up.wood_cost = int(up.wood_cost * up.cost_mult)
	up.meat_cost = int(up.meat_cost * up.cost_mult)
	up.gold_cost = int(up.gold_cost * up.cost_mult)
	Input.set_custom_mouse_cursor(CURSOR_04, Input.CURSOR_ARROW, Vector2 (0, 0))

	update_upgrade_cost(type)
	update_floating_totals()

func _on_speed_upgrade_button_mouse_entered():
	hovering = true
	on_upgrade_mouse_entered(UpgradeType.SPEED)
	declare_hovered_upgrade(speed_btt, speed_9p_rect, spd_panel)

func _on_speed_upgrade_button_mouse_exited():
	hovering = false
	on_upgrade_mouse_exited()
	declare_hovered_upgrade(speed_btt, speed_9p_rect, spd_panel)

func _on_output_upgrade_button_mouse_entered():
	hovering = true
	on_upgrade_mouse_entered(UpgradeType.OUTPUT)
	declare_hovered_upgrade(output_btt, output_9p_rect, out_put_panel)

func _on_output_upgrade_button_mouse_exited():
	hovering = false
	on_upgrade_mouse_exited()
	declare_hovered_upgrade(output_btt, output_9p_rect, out_put_panel)

func _on_extra_knight_upgrade_mouse_entered() -> void:
	hovering = true
	on_upgrade_mouse_entered(UpgradeType.KNIGHT)
	declare_hovered_upgrade(knight_btt, e_knight_9p_rect, knight_panel)

func _on_extra_knight_upgrade_mouse_exited() -> void:
	hovering = false
	on_upgrade_mouse_exited()
	declare_hovered_upgrade(knight_btt, e_knight_9p_rect, knight_panel)

func _on_toughness_button_mouse_entered() -> void:
	hovering = true
	on_upgrade_mouse_entered(UpgradeType.TOUGHNESS)
	declare_hovered_upgrade(toughness_btt, toughness_9p_rect,toughness_panel)

func _on_toughness_button_mouse_exited() -> void:
	hovering = false
	on_upgrade_mouse_exited()
	declare_hovered_upgrade(toughness_btt, toughness_9p_rect, toughness_panel)

func start_action_loop():
	match current_action:
		ActionType.ATTACK:
			current_button = attack
		ActionType.BLOCK:
			current_button = block
		ActionType.FORAGE:
			current_button = forage
		ActionType.IDLE:
			current_button = null

	if action_loop_running:
		return

	action_loop_running = true

	while pressing:
		await perform_action(current_action)

	action_loop_running = false
	perform_action(ActionType.IDLE)

func perform_action(action):
	performing = true

	match action:
		ActionType.ATTACK:
			animation.play("attack")
			gold += max(output_floor, output)
		ActionType.BLOCK:
			animation.play("block")
			wood += max(output_floor, output)
		ActionType.FORAGE:
			animation.play("forage")
			meat += max(output_floor, output)
		_:
			animation.play("idle")

	await animation.animation_finished
	performing = false
	update_floating_totals()

func clear_container(container: Container) -> void:
	for child in container.get_children():
		child.queue_free()

func set_number_icons(
	container: HBoxContainer,
	value: int,
	resource_type: ResourceType
) -> void:
	clear_container(container)
	var abbrev = abbreviate_number(value) # variável se o número precisa abreviar
	var number_str = abbrev.number_str # o valor original, checado
	var suffix = abbrev.suffix # o sufixo, se necessário
	var digit_map = numbers[resource_type] # variável do mapa de números criados
	for c in number_str: # confere de 0 a 9
		var icon := TextureRect.new() # varíavel do ícone específico para o número específico
		icon.scale = Vector2(20, 20)
		if c == ".":
			icon.texture = suffixes["."] # adiciona o ponto
		else:
			var digit = int(c)
			icon.texture = digit_map[digit] # textura do ícone vira a específica da variável acima
		container.add_child(icon) # this being, the icons will not be added beforehand, they will be called within my scene
	if suffix != "":
		var icon = TextureRect.new()
		icon.texture = suffixes[suffix]
		container.add_child(icon)

func update_all_upgrade_costs() -> void:
	for type in upgrades.keys():
		update_upgrade_cost(type)

func update_upgrade_cost(type: UpgradeType) -> void:
	var up = upgrades[type]
	var containers = upgrade_digit_containers[type]
	set_crossroad(up, containers)

func update_floating_totals() -> void:
	var containers = upgrade_digit_containers[UpgradeType.TOTAL]

	set_number_icons(
		containers[ResourceType.WOOD],
		wood,
		ResourceType.WOOD
	)

	set_number_icons(
		containers[ResourceType.MEAT],
		meat,
		ResourceType.MEAT
	)

	set_number_icons(
		containers[ResourceType.GOLD],
		gold,
		ResourceType.GOLD
	)

func set_crossroad(up, containers):
	set_number_icons(
		containers[ResourceType.WOOD],
		up.wood_cost,
		ResourceType.WOOD
	)

	set_number_icons(
		containers[ResourceType.MEAT],
		up.meat_cost,
		ResourceType.MEAT
	)

	set_number_icons(
		containers[ResourceType.GOLD],
		up.gold_cost,
		ResourceType.GOLD
	)

func abbreviate_number(value: int) -> Dictionary:
	if value < 1_000:
		return {
			"number_str": str(value),
			"suffix": ""
		}
	elif value < 1_000_000:
		@warning_ignore("integer_division")
		var rounded = int(value/1_000)
		return {
			"number_str": str(rounded),
			"suffix": "K"
		}
	elif value < 1_000_000_000:
		@warning_ignore("integer_division")
		var rounded = int(value/1_000_000)
		return {
			"number_str": str(rounded),
			"suffix": "M"
		}
	else:
		@warning_ignore("integer_division")
		var rounded = int(value/1_000_000_000)
		return {
			"number_str": str(rounded),
			"suffix": "B"
		}

func start_qte_loop():
	var random_interval = rng.randf_range(2.0, 4.0)
	await get_tree().create_timer(random_interval).timeout
	awarn_qte()

func awarn_qte():
	var random_choice = buttons.pick_random()
	tween_chosen_action(random_choice)


func tween_chosen_action(action):
	var tween = get_tree().create_tween()
	var qte_check := 1.2
	
	tween.tween_property(
		action,
		"modulate",
		Color(1.07, 1.222, 0.0, 1.0),
		qte_check,
	)
	
	await tween.finished
	play_qte(action)

func play_qte(chosen_button):
	var tween = get_tree().create_tween()
	var qte_check := 0.2

	tween.tween_property(
		chosen_button,
		"modulate",
		Color(1.0, 1.0, 1.0),
		qte_check,
	)

	match chosen_button:
		attack:
			if chosen_button == current_button:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(0.0, 1.544, 0.0, 1.0),
					qte_check
				)
				successful_qte()
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
			else:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(1.551, 0.135, 0.0, 1.0),
					qte_check
				)
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
		block:
			if chosen_button == current_button:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(0.0, 1.544, 0.261, 1.0),
					qte_check
				)
				successful_qte()
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
			else:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(1.551, 0.135, 0.0, 1.0),
					qte_check
				)
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
		forage:
			if chosen_button == current_button:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(0.0, 1.544, 0.0, 1.0),
					qte_check
				)
				successful_qte()
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
			else:
				tween.tween_property(
					chosen_button,
					"modulate",
					Color(1.551, 0.135, 0.0, 1.0),
					qte_check
				)
				tween.chain().tween_property(
					chosen_button,
					"modulate",
					Color(1.0, 1.0, 1.0),
					qte_check*2
				)
	await tween.finished
	tween.kill()
	close_qte_loop()

func close_qte_loop():
	start_qte_loop()

func successful_qte():
	if output_tween and output_tween.is_running():
		output_tween.kill()
	output += (output_floor * (heat - 1.0)) * 0.8
	output_tween = get_tree().create_tween()
	output_tween.tween_property(
		self,
		"output",
		output_floor,
		10.0
	).set_delay(1.5)\
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_IN_OUT)

func declare_hovered_upgrade(button, ninepatch, panel):
	var tween = get_tree().create_tween()
	var panel_size: Vector2 = panel.get_size()
	var vector_hover_in := Vector2(15, 15)
	var vector_hover_out := Vector2(-5, -5)
	if hovering:
		tween.tween_property(
			button,
			"size",
			Vector2 (panel_size + vector_hover_in),
			0.2
		).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(
			button,
			"position",
			vector_hover_out,
			0.2
		).set_trans(Tween.TRANS_SINE)
		await tween.finished
	else:
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_REGULAR)
		tween.kill()
		await get_tree().create_timer(0.1).timeout
		tween = get_tree().create_tween()
		tween.tween_property(
			button,
			"size",
			panel_size,
			0.1
		).set_trans(Tween.TRANS_BACK)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2 (0, 0),
			0.1
		).set_trans(Tween.TRANS_BACK)

# this one has a differnte var aspect than the one above, fix hereby
func declare_hovered_action(button):
	var tween = get_tree().create_tween()
	var vector_hover_in := Vector2(115, 115)
	var vector_hover_out := Vector2(110, 110)
	var vector_position_adjust := Vector2(-3, -3)
	if hovering:
		Input.set_custom_mouse_cursor(CURSOR_02, Input.CURSOR_ARROW, Vector2 (25, 18))
		tween.tween_property(
			button,
			"size",
			vector_hover_in,
			0.2
		).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(
			button,
			"position",
			vector_position_adjust,
			0.2
		).set_trans(Tween.TRANS_SINE)
		await tween.finished
	else:
		Input.set_custom_mouse_cursor(CURSOR_01, Input.CURSOR_ARROW, Vector2 (25, 18))
		tween.kill()
		await get_tree().create_timer(0.1).timeout
		tween = get_tree().create_tween()
		tween.tween_property(
			button,
			"size",
			vector_hover_out,
			0.1
		).set_trans(Tween.TRANS_BACK)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2 (0, 0),
			0.1
		).set_trans(Tween.TRANS_BACK)

func _on_attack_mouse_entered() -> void:
	hovering = true
	declare_hovered_action(attack)

func _on_attack_mouse_exited() -> void:
	hovering = false
	declare_hovered_action(attack)

func _on_forage_mouse_entered() -> void:
	hovering = true
	declare_hovered_action(forage)

func _on_forage_mouse_exited() -> void:
	hovering = false
	declare_hovered_action(forage)

func _on_block_mouse_entered() -> void:
	hovering = true
	declare_hovered_action(block)

func _on_block_mouse_exited() -> void:
	hovering = false
	declare_hovered_action(block)

func _on_bigger_storage_pressed() -> void:
	animation.play("pawn_to_gold")
	await animation.animation_finished
	await get_tree().create_timer(1).timeout
	animation.play("gold_to_mount")

func _on_extra_pawn_pressed() -> void:
	animation.play("pawn_to_meat")
	await animation.animation_finished
	await get_tree().create_timer(1).timeout
	animation.play("meat_to_mount")

func _on_speed_upgrade_pressed() -> void:
	animation.play("pawn_to_wood")
	await animation.animation_finished
	await get_tree().create_timer(1).timeout
	animation.play("wood_to_mount")

func _on_carry_capacity_upgrade_pressed() -> void:
	animation.play("forageing")

func _on_tab_container_tab_changed(_tab: int) -> void:
	if at_pawn:
		at_pawn = false
		return
	else:
		at_pawn = true
		return

func _on_attack_pressed() -> void:
	switch_action(ActionType.ATTACK)

func _on_forage_pressed() -> void:
	switch_action(ActionType.FORAGE)

func _on_block_pressed() -> void:
	switch_action(ActionType.BLOCK)

func switch_action(new_action: ActionType) -> void:
	if current_action == new_action and pressing:
		pressing = false
		current_action = ActionType.IDLE
		check_nine_patch_for_action(new_action)
		return
	if pressing:
		pressing = false
		check_nine_patch_for_action(current_action)
	pressing = true
	last_action = current_action
	current_action = new_action
	check_nine_patch_for_action(current_action)
	start_action_loop()

func check_nine_patch_for_action(action: ActionType) -> void:
	match action:
		ActionType.ATTACK:
			check_nine_patch(attack_9p_rect)
		ActionType.BLOCK:
			check_nine_patch(block_9p_rect)
		ActionType.FORAGE:
			check_nine_patch(forage_9p_rect)

func check_nine_patch(ninepatch):
	if pressing:
		print("[CHECK_NINE_PATCH] pressing")
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_PRESSED)
	else:
		print("[CHECK_NINE_PATCH] not pressing")
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_REGULAR)
