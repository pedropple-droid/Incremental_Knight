# 🔴🟠🟢🔵⚪
# [QOL]🔴
# refactor all code, take out form main and divide into separate script containers
# == Function call == 
# You push someone:
# “Hey, YOU, do this.”
# == Signal ==
# You shout into the room:
# “This just happened.”
# Whoever cares responds.
# ---------------------------------------------------------------
# [UPGRADE PANELS]🟠
# it should register that the mouse is hovering, and, let's change it to clicking and holding
# ---------------------------------------------------------------
# [ACTION PANELS]🟠
# somehow, we've made it much harder for ourselfs in the way that it worked eprfectly and now it doesn't
# but, that's not a problem, we've managed to refactor a lot of code, nice
# atm, i've got some issues with the chosen and choosing panel, don't overcomplicate it, just try to fix it
# ---------------------------------------------------------------
# [VISUAL PANEL]⚪
# ---------------------------------------------------------------
# [TOUGHNESS TIMER]🔵
# unresponsive, refactor its idea whenever
# ---------------------------------------------------------------
# [QTE]🔵
# qte still kinda sucks, it's kinda just there in number and in visual
# still about qte, i could add a differente color meter for when my knight is 
# waiting to finish an action to perform another one, or, maybe, make different
# animations for him to change between actions so qte would make more sense in a sense
#  ---------------------------------------------------------------
# [GAME FEEL]⚪
# fixd some numbers, game might go much smoother now, but i do need to add difficulty increase7
#  ---------------------------------------------------------------

extends Control

class_name MainController

@onready var timer_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/TimerLabel
@onready var countdown_timer: Timer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/Timer
@onready var action_space: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace
@onready var visual_space: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace
@onready var upgrade_space: PanelContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var action_panels := [
	$TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel,
	$TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel,
	$TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel,
]
@onready var qte: QTEController = QTEController.new()
@onready var action_controller: ActionController = ActionController.new()
@onready var data_handler: DataHandler = DataHandler.new()
@onready var attack: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack
@onready var forage: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage
@onready var block: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block
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
@onready var fake_cursor: TextureRect = $FakeCursor
@onready var speed_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/SpeedChosen
@onready var toughness_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/ToughnessChosen
@onready var output_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/OutputChosen
@onready var knight_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/KnightChosen
@onready var speed_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/SpeedChoosing
@onready var toughness_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/ToughnessChoosing
@onready var output_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/OutputChoosing
@onready var knight_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/KnightChoosing
@onready var attack_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack/AttackChosen
@onready var forage_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage/ForageChosen
@onready var block_chosen: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block/BlockChosen
@onready var attack_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack/AttackChoosing
@onready var forage_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage/ForageChoosing
@onready var block_choosing: NinePatchRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block/BlockChoosing
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
@onready var spd_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton/SpdLabel
@onready var output_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/OutPutPanel/OutputUpgradeButton/OutputLabel
@onready var knight_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/KnightPanel/ExtraKnightUpgrade/KnightLabel
@onready var toughness_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/ToughnessPanel/ToughnessButton/ToughnessLabel
@onready var knight_3: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight3
@onready var knight_2: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight2
@onready var knight: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/KnightCentering/HBoxKnights/Knight


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

enum ResourceType {
	WOOD,
	MEAT,
	GOLD,
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

var upgrade_patches := {
	data_handler.SPEED: speed_9p_rect,
	data_handler.OUTPUT: output_9p_rect,
	data_handler.KNIGHT: e_knight_9p_rect,
	data_handler.TOUGHNESS: toughness_9p_rect,
}

var upgrade_buttons := {
	data_handler.SPEED: speed_btt,
	data_handler.OUTPUT: output_btt,
	data_handler.KNIGHT: knight_btt,
	data_handler.TOUGHNESS: toughness_btt,
}

var upgrade_digit_containers := {
	data_handler.TOTAL: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	data_handler.SPEED: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	data_handler.OUTPUT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	data_handler.KNIGHT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	data_handler.TOUGHNESS: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
}

var upgrades := {
	data_handler.OUTPUT: {
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
	data_handler.SPEED: {
		"wood_cost": 4,
		"meat_cost": 5,
		"gold_cost": 10,
		"cost_mult": 1.5,
		"apply": func():
			pass,
	},
	data_handler.TOUGHNESS: {
		"wood_cost": 20,
		"meat_cost": 30,
		"gold_cost": 40,
		"cost_mult": 2.0,
		"apply": func():
			data_handler.toughness_level += 1
			data_handler.timer_speed_multiplier *= 0.9,
	},
	data_handler.KNIGHT: {
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


var current_upgrade: UpgradeType

func _ready() -> void:
	await get_tree().process_frame
	animation.animation_finished.connect(_on_animation_finished)

	upgrade_patches[UpgradeType.SPEED] = speed_9p_rect
	upgrade_patches[UpgradeType.OUTPUT] = output_9p_rect
	upgrade_patches[UpgradeType.KNIGHT] = e_knight_9p_rect
	upgrade_patches[UpgradeType.TOUGHNESS] = toughness_9p_rect
	upgrade_buttons[UpgradeType.SPEED] = speed_btt
	upgrade_buttons[UpgradeType.OUTPUT] = output_btt
	upgrade_buttons[UpgradeType.KNIGHT] = knight_btt
	upgrade_buttons[UpgradeType.TOUGHNESS] = toughness_btt

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

	upgrade_digit_containers[data_handler.TOTAL][ResourceType.WOOD] = wood_digits_total
	upgrade_digit_containers[data_handler.TOTAL][ResourceType.MEAT] = meat_digits_total
	upgrade_digit_containers[data_handler.TOTAL][ResourceType.GOLD] = gold_digits_total

	qte.setup([attack, block, forage])

	knight.visible = true
	knight_2.visible = false
	knight_3.visible = false

	nullify_all()

	add_child(qte)
	qte.qte_started.connect(_on_qte_started)
	qte.qte_success.connect(_on_qte_success)
	qte.qte_fail.connect(_on_qte_fail)
	qte.start()

	add_child(action_controller)
	action_controller.action_changed.connect(_on_action_changed)

	add_child(data_handler)

	update_all_upgrade_costs()
	update_floating_totals()
	setup_timer()


func _process(delta):
	for type in upgrade_patches.keys():
		update_upgrade_patch(type)
	data_handler.time_left = max(data_handler.time_left - delta * data_handler.timer_speed_multiplier, 0)
	timer_label.text = format_time(data_handler.time_left)

# ========= VISUAL =========

func set_crossroad(up, containers):
	set_number_icons(
		containers[data_handler.ResourceType.WOOD],
		up.wood_cost,
		data_handler.ResourceType.WOOD
	)

	set_number_icons(
		containers[data_handler.ResourceType.MEAT],
		up.meat_cost,
		data_handler.ResourceType.MEAT
	)

	set_number_icons(
		containers[data_handler.ResourceType.GOLD],
		up.gold_cost,
		data_handler.ResourceType.GOLD
	)



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


func clear_container(container: Container) -> void:
	for child in container.get_children():
		child.queue_free()


func update_floating_totals() -> void:
	var containers = upgrade_digit_containers[TOTAL]

	set_number_icons(
		containers[ResourceType.WOOD],
		data_handler.wood,
		ResourceType.WOOD
	)

	set_number_icons(
		containers[ResourceType.MEAT],
		data_handler.meat,
		ResourceType.MEAT
	)

	set_number_icons(
		containers[ResourceType.GOLD],
		data_handler.gold,
		ResourceType.GOLD
	)


func chosen_panel(panel, action):
	if action:
		panel.visible = true
	else:
		panel.visible = false
	nullify_others(panel)


func choosing_panel(panel, action):
	if action:
		panel.visible = true
	else:
		panel.visible = false
	nullify_others(panel)


func nullify_others(panel):
	match panel:
		speed_chosen:
			knight_chosen.visible = false
			toughness_chosen.visible = false
			output_chosen.visible = false
		output_chosen:
			knight_chosen.visible = false
			toughness_chosen.visible = false
			speed_chosen.visible = false
		toughness_chosen:
			knight_chosen.visible = false
			output_chosen.visible = false
			speed_chosen.visible = false
		knight_chosen:
			toughness_chosen.visible = false
			output_chosen.visible = false
			speed_chosen.visible = false
		attack_chosen:
			output_chosen.visible = false
			speed_chosen.visible = false
		output_chosen:
			attack_chosen.visible = false
			speed_chosen.visible = false
		speed_chosen:
			attack_chosen.visible = false
			output_chosen.visible = false


func nullify_all():
	knight_chosen.visible = false
	toughness_chosen.visible = false
	output_chosen.visible = false
	speed_chosen.visible = false
	attack_chosen.visible = false
	forage_chosen.visible = false
	block_chosen.visible = false
	knight_choosing.visible = false
	toughness_choosing.visible = false
	output_choosing.visible = false
	speed_choosing.visible = false
	attack_choosing.visible = false
	forage_choosing.visible = false
	block_choosing.visible = false


func _on_animation_finished(anim_name: StringName) -> void:
	action_controller.animation_finished()


func _on_attack_mouse_entered() -> void:
	action_button_tween(true, attack, CURSOR_02)


func _on_attack_mouse_exited() -> void:
	action_button_tween(false, attack, CURSOR_01)


func _on_forage_mouse_entered() -> void:
	action_button_tween(true, forage, CURSOR_02)


func _on_forage_mouse_exited() -> void:
	action_button_tween(false, forage, CURSOR_01)


func _on_block_mouse_entered() -> void:
	action_button_tween(true, block, CURSOR_02)


func _on_block_mouse_exited() -> void:
	action_button_tween(false, block, CURSOR_01)


func _on_speed_upgrade_button_mouse_entered():
	declare_hovered_upgrade(speed_btt, true, speed_9p_rect, speed_choosing)


func _on_speed_upgrade_button_mouse_exited():
	declare_hovered_upgrade(speed_btt, false, speed_9p_rect, speed_choosing)


func _on_output_upgrade_button_mouse_entered():
	declare_hovered_upgrade(output_btt, true, output_9p_rect, output_choosing)


func _on_output_upgrade_button_mouse_exited():
	declare_hovered_upgrade(output_btt, false, output_9p_rect, output_choosing)


func _on_extra_knight_upgrade_mouse_entered() -> void:
	declare_hovered_upgrade(knight_btt, true, e_knight_9p_rect, knight_choosing)


func _on_extra_knight_upgrade_mouse_exited() -> void:
	declare_hovered_upgrade(knight_btt, false, e_knight_9p_rect, knight_choosing)


func _on_toughness_button_mouse_entered() -> void:
	declare_hovered_upgrade(toughness_btt, true, toughness_9p_rect, toughness_choosing)


func _on_toughness_button_mouse_exited() -> void:
	declare_hovered_upgrade(toughness_btt, false, toughness_9p_rect, toughness_choosing)


func _on_speed_upgrade_button_button_down() -> void:
	do_upgrade_feedback(UpgradeType.SPEED, true)


func _on_speed_upgrade_button_button_up() -> void:
	do_upgrade_feedback(UpgradeType.SPEED, false)


# ========= QTE ==========
func _on_qte_started(button: Button) -> void:
	# VISUAL ONLY
	var tween := get_tree().create_tween()
	tween.tween_property(
		button,
		"modulate",
		Color(1.1, 1.2, 0.0),
		0.3
	)


func _on_qte_success(button: Button) -> void:

	var tween := get_tree().create_tween()
	tween.tween_property(
		button,
		"modulate",
		Color(0.0, 1.4, 0.0),
		0.15
	)
	tween.chain().tween_property(
		button,
		"modulate",
		Color.WHITE,
		0.3
	)


func _on_qte_fail(button: Button) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(
		button,
		"modulate",
		Color(1.5, 0.1, 0.0),
		0.15
	)
	tween.chain().tween_property(
		button,
		"modulate",
		Color.WHITE,
		0.3
	)



# ========= ACTION ==========
func _on_action_changed(action: ActionController.ActionType) -> void:
	_play_action_animation(action)
	update_action_panels(action)


func update_action_panels(action):
	attack_chosen.visible = action == ActionController.ActionType.ATTACK
	forage_chosen.visible = action == ActionController.ActionType.FORAGE
	block_chosen.visible = action == ActionController.ActionType.BLOCK


func _play_action_animation(action: ActionController.ActionType) -> void:
	match action:
		ActionController.ActionType.ATTACK:
			animation.play("attack")
		ActionController.ActionType.FORAGE:
			animation.play("forage")
		ActionController.ActionType.BLOCK:
			animation.play("block")
		ActionController.ActionType.IDLE:
			animation.play("idle")


func action_button_tween(hovering, button, texture):
	var tween = get_tree().create_tween()
	var vector_hover_in := Vector2(1.05, 1.05)
	var vector_hover_out := Vector2(1, 1)
	var vector_position_adjust := Vector2(-3, -3)
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	Input.set_custom_mouse_cursor(texture, 0, Vector2(23, 23))

	if hovering: 
		tween.tween_property(
			button,
			"scale",
			vector_hover_in,
			0.05
	)
		tween.parallel().tween_property(
			button,
			"position",
			vector_position_adjust,
			0.05
		)
	else:
		tween.tween_property(
			button,
			"scale",
			vector_hover_out,
			0.1
	)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2(0, 0),
			0.1
		)


func _on_attack_pressed():
	action_controller.request_action(ActionController.ActionType.ATTACK)


func _on_forage_pressed():
	action_controller.request_action(ActionController.ActionType.FORAGE)


func _on_block_pressed():
	action_controller.request_action(ActionController.ActionType.BLOCK)



# =========== UPGRADE ============
func update_all_upgrade_costs() -> void:
	for type in upgrades.keys():
		data_handler.update_upgrade_cost(type)


func declare_hovered_upgrade(button, action, ninepatch, panel):
	var tween = get_tree().create_tween()
	var vector_hover_in := Vector2(1.05, 1.05)
	var vector_hover_out := Vector2(1, 1)
	var vector_position_adjust := Vector2(-8, -8)

	if action:
		choosing_panel(panel, true)
		tween.tween_property(
			button,
			"scale",
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
		choosing_panel(panel, false)
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_REGULAR)
		tween.kill()
		await get_tree().create_timer(0.1).timeout
		tween = get_tree().create_tween()
		tween.tween_property(
			button,
			"scale",
			vector_hover_out,
			0.1
		).set_trans(Tween.TRANS_BACK)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2 (0, 0),
			0.1
		).set_trans(Tween.TRANS_BACK)


func do_upgrade_feedback(type: UpgradeType, action): # signal here
	check_nine_patch_for_upgrade(current_upgrade, false)

	if action:
		var label_type := get_label_from_upgrade(type)

		var tween = get_tree().create_tween()
		tween.tween_property(
			label_type,
			"theme_override_font_sizes/font_size",
			14,
			data_handler.in_time
		)
		await tween.finished

		data_handler.try_buy_upgrade(type)

		tween = get_tree().create_tween()
		tween.tween_property(
			label_type,
			"theme_override_font_sizes/font_size",
			24,
			data_handler.pop_time
		)
		tween.parallel().tween_property(
			label_type,
			"theme_override_constants/outline_size",
			4,
			data_handler.pop_time
		)
		tween.chain().tween_property(
			label_type,
			"theme_override_font_sizes/font_size",
			16,
			data_handler.out_time
		)
		tween.parallel().tween_property(
			label_type,
			"theme_override_constants/outline_size",
			0,
			data_handler.out_time
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


func update_all_upgrade_patches() -> void:
	for type in upgrade_patches.keys():
		update_upgrade_patch(type)


func check_nine_patch(ninepatch, panel, panel_two, action):
	if action:
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_PRESSED)
		panel.visible = true
		panel_two.visible = false
	else:
		ninepatch.set("texture", SMALL_RED_SQUARE_BUTTON_REGULAR)
		panel.visible = false


func update_upgrade_patch(type: UpgradeType) -> void: # signal here
	var patch: NinePatchRect = upgrade_patches[type]
	var button: Button = upgrade_buttons[type]

	if data_handler.can_buy(type):
		patch.texture = SMALL_RED_SQUARE_BUTTON_REGULAR
		patch.position = Vector2(0, 0)
		button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED 
	else:
		patch.texture = SMALL_RED_SQUARE_BUTTON_PRESSED
		patch.position = Vector2(0, -10)
		button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED


func check_nine_patch_for_upgrade(upgrade: UpgradeType, action) -> void:
	match upgrade:
		UpgradeType.OUTPUT:
			check_nine_patch(output_9p_rect, output_chosen, output_choosing, action)
		UpgradeType.SPEED:
			check_nine_patch(speed_9p_rect, speed_chosen, speed_choosing, action)
		UpgradeType.TOUGHNESS:
			check_nine_patch(toughness_9p_rect, toughness_chosen, toughness_choosing, action)
		UpgradeType.KNIGHT:
			check_nine_patch(e_knight_9p_rect, knight_chosen, knight_choosing, action)



# ======= NUMBERS ========
func setup_timer():
	countdown_timer.start()


func format_time(seconds: float) -> String:
	var s := int(seconds)
	@warning_ignore("integer_division")
	var mins := s / 60
	var secs := s % 60
	return "%02d:%02d" % [mins, secs]
# ========================
