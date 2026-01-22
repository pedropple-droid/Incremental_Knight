extends Control

const MAIN_2 = preload("uid://ey2i670agjff")

const original_output_correction = 0.08
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15
const DIGIT_BASE_SIZE := 8
const DIGIT_SCALE := 2
const CURSOR_01 = preload("uid://bigflnfdn68dm")
const CURSOR_02 = preload("uid://cxshok2ga3xac")

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
		"wood_cost": 15,
		"meat_cost": 25,
		"gold_cost": 40,
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
		"wood_cost": 150,
		"meat_cost": 300,
		"gold_cost": 450,
		"cost_mult": 3.0,
		"apply": func():
			pass,
	},
	UpgradeType.KNIGHT: {
		"wood_cost": 40000,
		"meat_cost": 55000,
		"gold_cost": 85000,
		"cost_mult": 3.0,
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

var buttons: Array

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var spd_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/SpeedUpgradeButton/RichTextLabel
@onready var output_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/OutputUpgradeButton/RichTextLabel
@onready var knight_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/OutputUpgradeButton/RichTextLabel
@onready var toughness_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ToughnessButton/RichTextLabel
@onready var knight_3: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/HBoxKnights/Knight3
@onready var knight_2: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/HBoxKnights/Knight2
@onready var knight: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginKnight/HBoxKnights/Knight
@onready var pawn: Sprite2D = $TabContainer/ResourcesTab/PanelContainer/MarginContainer/HBoxContainer/HutSpace/MarginContainer/Pawn
@onready var wood_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/SpeedUpgradeButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsSpeed
@onready var meat_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/SpeedUpgradeButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsSpeed
@onready var gold_digits_speed: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/SpeedUpgradeButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsSpeed
@onready var wood_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/OutputUpgradeButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsOutput
@onready var meat_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/OutputUpgradeButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsOutput
@onready var gold_digits_output: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/OutputUpgradeButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsOutput
@onready var wood_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ExtraKnightUpgrade/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsKnight
@onready var meat_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ExtraKnightUpgrade/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsKnight
@onready var gold_digits_knight: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ExtraKnightUpgrade/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsKnight
@onready var gold_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ToughnessButton/CenterContainer/HBoxContainer/GoldContainer/MarginContainer/VBoxContainer/CenterContainer/GoldDigitsTOughness
@onready var meat_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ToughnessButton/CenterContainer/HBoxContainer/MeatContainer/MarginContainer/VBoxContainer/CenterContainer/MeatDigitsToughness
@onready var wood_digits_toughness: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/UpgradeSpace/MarginContainer/HBoxupgrade/ToughnessButton/CenterContainer/HBoxContainer/WoodContainer/MarginContainer/VBoxContainer/CenterContainer/WoodDigitsToughness
@onready var wood_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/WoodIcon/WoodDigits
@onready var meat_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/MeatIcon/MeatDigits
@onready var gold_digits_total: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginValue/HValueBox/GoldIcon/GoldDigits
@onready var block: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/BlockPanel/block
@onready var forage: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/ForagePanel/forage
@onready var attack: Button = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/ActionSpace/MarginContainer/SliderPanel/MarginContainer/VBoxContainer/AttackPanel/attack

var gold: int = 0
var meat: int = 0
var wood: int = 0

var output_floor: float = 1.0
var output: float = 1.0
var output_tween: Tween
var output_multiplier := 2.0
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.5

var action_loop_running := false
var pressing = false
var performing = false
var choosing = false
var upgrading = false
var hovering = false

var current_upgrade : UpgradeType
var current_action: ActionType
var current_button: Button

var heat := 1.8

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var at_pawn := false

func _ready() -> void:
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

	update_all_upgrade_costs()
	update_floating_totals()
	start_qte_loop()

func _process(_delta):
	pass

func update_knight_visuals(): #UPDATE THIS
	knight.visible = total_knights >= 1
	knight_2.visible = total_knights >= 2
	knight_3.visible = total_knights >= 3

func update_output_from_knights():
	print('[UPDATE_OUTPUT_FROM_KNIGHTS]')
	output *= total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func on_upgrade_mouse_entered(type: UpgradeType):
	if upgrading:
		return
	current_upgrade = type
	choosing = true
	upgrading = true
	start_upgrade_loop()

func on_upgrade_mouse_exited():
	choosing = false
	upgrade_streak = 0
	current_upgrade_delay = BASE_UPGRADE_DELAY
	upgrade_anim_speed = BASE_UPGRADE_DELAY

func start_upgrade_loop():
	while choosing:
		if can_buy(current_upgrade):
			await do_upgrade_feedback(current_upgrade)
			await get_tree().create_timer(current_upgrade_delay).timeout
			print("[CAN_BUY], choosin")
		else:
			await get_tree().process_frame
	upgrading = false

func can_buy(type: UpgradeType) -> bool:
	var up = upgrades[type]
	if wood < up.wood_cost:
		return false
	if meat < up.meat_cost:
		return false
	if gold < up.gold_cost:
		return false
	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		return false
	return true

func do_upgrade_feedback(type: UpgradeType):
	var label_type := get_label_from_upgrade(type)

	var in_time := 0.5 / upgrade_anim_speed
	var pop_time := 0.2 / upgrade_anim_speed
	var out_time := 0.5 / upgrade_anim_speed
	var placeholder_time := 0.8

	if type == UpgradeType.TOUGHNESS:
		var tween = get_tree().create_tween()
		while choosing:
			tween.tween_property(
				label_type,
				"theme_override_font_sizes/normal_font_size",
				30,
				placeholder_time
			).set_trans(Tween.TRANS_BACK)
			await tween.finished
			if choosing:
				tween = get_tree().create_tween()
				tween.chain().tween_property(
					label_type,
					"theme_override_font_sizes/normal_font_size",
					102,
					pop_time
				)
				await tween.finished
				try_buy_upgrade(UpgradeType.TOUGHNESS)
			tween = get_tree().create_tween()
			tween.tween_property(
				label_type,
				"theme_override_font_sizes/normal_font_size",
				16,
				in_time
			)
			await tween.finished
			return

		try_buy_upgrade(type)
		return

	var tween := get_tree().create_tween()
	tween.tween_property(
		label_type,
		"theme_override_font_sizes/normal_font_size",
		14,
		in_time
	)
	await tween.finished

	if not choosing:
		tween = get_tree().create_tween()
		tween.tween_property(
			label_type,
			"theme_override_font_sizes/normal_font_size",
			16,
			0.1
		)
		await tween.finished
		return

	try_buy_upgrade(type)

	tween = get_tree().create_tween()
	tween.tween_property(
		label_type,
		"theme_override_font_sizes/normal_font_size",
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
		"theme_override_font_sizes/normal_font_size",
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

func get_label_from_upgrade(type: UpgradeType) -> RichTextLabel:
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
	if type == UpgradeType.TOUGHNESS:
		choosing = false
		upgrading = false
		await get_tree().process_frame
		get_tree().change_scene_to_packed(MAIN_2)
		return

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

	update_upgrade_cost(type)
	update_floating_totals()

func _on_speed_upgrade_button_mouse_entered():
	on_upgrade_mouse_entered(UpgradeType.SPEED)

func _on_speed_upgrade_button_mouse_exited():
	on_upgrade_mouse_exited()

func _on_output_upgrade_button_mouse_entered():
	on_upgrade_mouse_entered(UpgradeType.OUTPUT)

func _on_output_upgrade_button_mouse_exited():
	on_upgrade_mouse_exited()

func _on_extra_knight_upgrade_mouse_entered() -> void:
	on_upgrade_mouse_entered(UpgradeType.KNIGHT)

func _on_extra_knight_upgrade_mouse_exited() -> void:
	on_upgrade_mouse_exited()

func _on_placeholder_button_mouse_entered() -> void:
	on_upgrade_mouse_entered(UpgradeType.TOUGHNESS)

func _on_placeholder_button_mouse_exited() -> void:
	on_upgrade_mouse_exited()

func _on_attack_button_down() -> void:
	pressing = true
	current_action = ActionType.ATTACK
	start_action_loop()

func _on_attack_button_up() -> void:
	pressing = false
	current_button = null

func _on_block_button_down() -> void:
	pressing = true
	current_action = ActionType.BLOCK
	start_action_loop()

func _on_block_button_up() -> void:
	pressing = false
	current_button = null

func _on_forage_button_down() -> void:
	pressing = true
	current_action = ActionType.FORAGE
	start_action_loop()

func _on_forage_button_up() -> void:
	pressing = false
	current_button = null

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
		if c == ".":
			icon.texture = suffixes["."] # adiciona o ponto
		else:
			var digit = int(c)
			icon.texture = digit_map[digit] # textura do ícone vira a específica da variável acima
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED # seta o stretch mode
		icon.custom_minimum_size = Vector2(
			DIGIT_BASE_SIZE * DIGIT_SCALE,
			DIGIT_BASE_SIZE * DIGIT_SCALE
			) # seta o tamanho mínimo
		container.add_child(icon) # this being, the icons will not be added beforehand, they will be called within my scene
	if suffix != "":
		var icon = TextureRect.new()
		icon.texture = suffixes[suffix]
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED # seta o stretch mode
		icon.custom_minimum_size = Vector2(
		DIGIT_BASE_SIZE * DIGIT_SCALE,
		DIGIT_BASE_SIZE * DIGIT_SCALE
		) # seta o tamanho mínimo
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
		var rounded = int(value/1_000)
		return {
			"number_str": str(rounded),
			"suffix": "K"
		}
	elif value < 1_000_000_000:
		var rounded = int(value/1_000_000)
		return {
			"number_str": str(rounded),
			"suffix": "M"
		}
	else:
		var rounded = int(value/1_000_000_000)
		return {
			"number_str": str(rounded),
			"suffix": "B"
		}

func start_qte_loop():
	var random_interval = rng.randf_range(2.0, 6.0)
	await get_tree().create_timer(random_interval).timeout
	awarn_qte()

func awarn_qte():
	var random_choice = buttons.pick_random()
	print('[AWARN_QTE]', random_choice)
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
				print('attack qte succeded!')
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
				print('attack qte failed...')
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
				print('block qte succeded!')
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
				print('block qte failed...')
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
				print('forage qte succeded!')
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
				print('forage qte failed...')
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
	print('[CLOSE_QTE_LOOP] quick time event loop has closed!')
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

func declare_hovered(button):
	var tween = get_tree().create_tween()
	if hovering:
		tween.tween_property(
			button,
			"size",
			Vector2 (80, 110),
			0.2
		).set_trans(Tween.TRANS_EXPO)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2 (-10, -5),
			0.2
		).set_trans(Tween.TRANS_EXPO)
		await tween.finished
	else:
		tween.kill()
		await get_tree().create_timer(0.2).timeout
		tween = get_tree().create_tween()
		tween.tween_property(
			button,
			"size",
			Vector2 (60, 100),
			0.2
		).set_trans(Tween.TRANS_EXPO)
		tween.parallel().tween_property(
			button,
			"position",
			Vector2 (0, 0),
			0.2
		).set_trans(Tween.TRANS_EXPO)

func _on_attack_mouse_entered() -> void:
	hovering = true
	Input.set_custom_mouse_cursor(CURSOR_02, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(attack)

func _on_attack_mouse_exited() -> void:
	hovering = false
	Input.set_custom_mouse_cursor(CURSOR_01, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(attack)

func _on_forage_mouse_entered() -> void:
	hovering = true
	Input.set_custom_mouse_cursor(CURSOR_02, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(forage)

func _on_forage_mouse_exited() -> void:
	hovering = false
	Input.set_custom_mouse_cursor(CURSOR_01, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(forage)

func _on_block_mouse_entered() -> void:
	hovering = true
	Input.set_custom_mouse_cursor(CURSOR_02, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(block)

func _on_block_mouse_exited() -> void:
	hovering = false
	Input.set_custom_mouse_cursor(CURSOR_01, Input.CURSOR_ARROW, Vector2 (25, 18))
	declare_hovered(block)
