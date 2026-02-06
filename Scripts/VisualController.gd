extends Node
class_name VisualController

@onready var action_controller: ActionController = ActionController.new()
@onready var upgrade_controller: UpgradeController = UpgradeController.new()
@onready var qte: QTEController = QTEController.new()
@onready var data_handler: DataHandler = DataHandler.new()

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

@onready var block: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block
@onready var forage: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage
@onready var attack: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack
@onready var speed_btt: Button = $"../TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/UpgradePanel/UpgradeMargin/HBoxupgrade/SpdPanel/SpeedUpgradeButton"
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

var upgrade_digit_containers := {
	data_handler.TOTAL: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	upgrade_controller.UpgradeType.SPEED: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	upgrade_controller.UpgradeType.OUTPUT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	upgrade_controller.UpgradeType.KNIGHT: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
	upgrade_controller.UpgradeType.TOUGHNESS: {
		ResourceType.WOOD: null,
		ResourceType.MEAT: null,
		ResourceType.GOLD: null,
	},
}

var upgrade_patches := {
	upgrade_controller.UpgradeType.SPEED: speed_9p_rect,
	upgrade_controller.UpgradeType.OUTPUT: output_9p_rect,
	upgrade_controller.UpgradeType.KNIGHT: e_knight_9p_rect,
	upgrade_controller.UpgradeType.TOUGHNESS: toughness_9p_rect,
}


var upgrade_buttons := {
	upgrade_controller.UpgradeType.SPEED: speed_btt,
	upgrade_controller.UpgradeType.OUTPUT: output_btt,
	upgrade_controller.UpgradeType.KNIGHT: knight_btt,
	upgrade_controller.UpgradeType.TOUGHNESS: toughness_btt,
}


func _ready() -> void:
	upgrade_patches[upgrade_controller.UpgradeType.SPEED] = speed_9p_rect
	upgrade_patches[upgrade_controller.UpgradeType.OUTPUT] = output_9p_rect
	upgrade_patches[upgrade_controller.UpgradeType.KNIGHT] = e_knight_9p_rect
	upgrade_patches[upgrade_controller.UpgradeType.TOUGHNESS] = toughness_9p_rect
	upgrade_buttons[upgrade_controller.UpgradeType.SPEED] = speed_btt
	upgrade_buttons[upgrade_controller.UpgradeType.OUTPUT] = output_btt
	upgrade_buttons[upgrade_controller.UpgradeType.KNIGHT] = knight_btt
	upgrade_buttons[upgrade_controller.UpgradeType.TOUGHNESS] = toughness_btt

	upgrade_digit_containers[UpgradeController.UpgradeType.SPEED][ResourceType.WOOD] = wood_digits_speed
	upgrade_digit_containers[UpgradeController.UpgradeType.SPEED][ResourceType.MEAT] = meat_digits_speed
	upgrade_digit_containers[UpgradeController.UpgradeType.SPEED][ResourceType.GOLD] = gold_digits_speed

	upgrade_digit_containers[UpgradeController.UpgradeType.OUTPUT][ResourceType.WOOD] = wood_digits_output
	upgrade_digit_containers[UpgradeController.UpgradeType.OUTPUT][ResourceType.MEAT] = meat_digits_output
	upgrade_digit_containers[UpgradeController.UpgradeType.OUTPUT][ResourceType.GOLD] = gold_digits_output

	upgrade_digit_containers[UpgradeController.UpgradeType.KNIGHT][ResourceType.WOOD] = wood_digits_knight
	upgrade_digit_containers[UpgradeController.UpgradeType.KNIGHT][ResourceType.MEAT] = meat_digits_knight
	upgrade_digit_containers[UpgradeController.UpgradeType.KNIGHT][ResourceType.GOLD] = gold_digits_knight

	upgrade_digit_containers[UpgradeController.UpgradeType.TOUGHNESS][ResourceType.WOOD] = wood_digits_toughness
	upgrade_digit_containers[UpgradeController.UpgradeType.TOUGHNESS][ResourceType.MEAT] = meat_digits_toughness
	upgrade_digit_containers[UpgradeController.UpgradeType.TOUGHNESS][ResourceType.GOLD] = gold_digits_toughness

	upgrade_digit_containers[DataHandler.TOTAL][ResourceType.WOOD] = wood_digits_total
	upgrade_digit_containers[DataHandler.TOTAL][ResourceType.MEAT] = meat_digits_total
	upgrade_digit_containers[DataHandler.TOTAL][ResourceType.GOLD] = gold_digits_total


	qte.setup([attack, block, forage])

	knight.visible = true
	knight_2.visible = false
	knight_3.visible = false

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


# ============= INPUTS ================
func _on_attack_pressed():
	action_controller.request_action(ActionController.ActionType.ATTACK)


func _on_forage_pressed():
	action_controller.request_action(ActionController.ActionType.FORAGE)


func _on_block_pressed():
	action_controller.request_action(ActionController.ActionType.BLOCK)


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
	do_upgrade_feedback(upgrade_controller.UpgradeType.SPEED, true)


func _on_speed_upgrade_button_button_up() -> void:
	do_upgrade_feedback(upgrade_controller.UpgradeType.SPEED, false)


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


# ================ ACTION ==================
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


# ================ UPGRADE ==================
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


func update_upgrade_patch(type: UpgradeController.UpgradeType) -> void: # signal here
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


func check_nine_patch_for_upgrade(upgrade: UpgradeController.UpgradeType, action) -> void:
	match upgrade:
		UpgradeController.UpgradeType.OUTPUT:
			check_nine_patch(output_9p_rect, output_chosen, output_choosing, action)
		UpgradeController.UpgradeType.SPEED:
			check_nine_patch(speed_9p_rect, speed_chosen, speed_choosing, action)
		UpgradeController.UpgradeType.TOUGHNESS:
			check_nine_patch(toughness_9p_rect, toughness_chosen, toughness_choosing, action)
		UpgradeController.UpgradeType.KNIGHT:
			check_nine_patch(e_knight_9p_rect, knight_chosen, knight_choosing, action)


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

func do_upgrade_feedback(type: UpgradeController.UpgradeType, action): # signal here
	check_nine_patch_for_upgrade(upgrade_controller.current_upgrade, false)

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


func get_label_from_upgrade(type: UpgradeController.UpgradeType) -> Label:
	match type:
		UpgradeController.UpgradeType.SPEED:
			return spd_label
		UpgradeController.UpgradeType.OUTPUT:
			return output_label
		UpgradeController.UpgradeType.KNIGHT:
			return knight_label
		UpgradeController.UpgradeType.TOUGHNESS:
			return toughness_label
	return null


func update_floating_totals() -> void:
	var containers = upgrade_digit_containers[DataHandler.TOTAL]

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
