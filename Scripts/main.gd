extends Control

const MAIN_2 = preload("uid://ey2i670agjff")

const original_output_correction = 0.08
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15

const WOODZERO = preload("uid://by3rm72y7rxte")
const WOODONE = preload("uid://bjefj5hmutwiu")
const WOODTWO = preload("uid://se336rvi4ebu")
const WOODTHREE = preload("uid://bckucqks82sn4")
const WOODFOUR = preload("uid://bxbxj0xiaxavd")
const WOODFIVE = preload("uid://d1vp6xosyx57h")
const WOODSIX = preload("uid://bpcigy6ukhwbf")
const WOODSEVEN = preload("uid://b2mu5vr27w5nx")
const WOODEIGHT = preload("uid://e3c0k8ddluvh")
const WOODNINE = preload("uid://cr3mejftlc4m2")

enum UpgradeType { 
	OUTPUT,
	SPEED,
	KNIGHT,
	WIN,
}

enum ActionType {
	IDLE,
	ATTACK,
	BLOCK,
	LOOT,
}

enum ResourceType {
	WOOD,
	MEAT,
	GOLD,
}

var upgrades := {
	UpgradeType.OUTPUT: {
		"wood_cost": 20,
		"meat_cost": 50,
		"gold_cost": 80,
		"cost_mult": 2.0,
		"apply": func():
			@warning_ignore("narrowing_conversion")
			output *= output_multiplier
			output_multiplier -= original_output_correction
			output_multiplier = max(
			output_multiplier,
			MIN_OUTPUT_UPGRADE,
		),
	},
	UpgradeType.SPEED: {
		"wood_cost": 5,
		"meat_cost": 10,
		"gold_cost": 20,
		"cost_mult": 1.5,
		"apply": func():
			animation.speed_scale *= 1.1,
	},
	UpgradeType.KNIGHT: {
		"wood_cost": 250,
		"meat_cost": 600,
		"gold_cost": 750,
		"cost_mult": 3.0,
		"apply": func():
			var amount = knights_per_purchase()
			total_knights += amount
			update_knight_visuals()
			update_output_from_knights(),
	},
	UpgradeType.WIN: {
		"wood_cost": 30000,
		"meat_cost": 45000,
		"gold_cost": 75000,
		"cost_mult": 1.0,
		"apply": func():
			pass,
	},
}

var actions := {
	ActionType.ATTACK: {
		"animation": "attack",
		"resource": "meat",
	},
	ActionType.BLOCK: {
		"animation": "block",
		"resource": "wood",
	},
	ActionType.LOOT: {
		"animation": "loot",
		"resource": "gold",
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
}

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/Label
@onready var spd_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/RichTextLabel
@onready var out_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton/CenterContainer/RichTextLabel
@onready var knight_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/ExtraKnightUpgrade/CenterContainer/RichTextLabel
@onready var win_label: RichTextLabel = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/WinButton/CenterContainer/RichTextLabel
@onready var h_box: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer
@onready var knight: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight
@onready var knight_2: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight2
@onready var knight_3: TextureRect = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight3
@onready var pawn: Sprite2D = $TabContainer/ResourcesTab/PanelContainer/MarginContainer/HBoxContainer/HutSpace/MarginContainer/Pawn
@onready var wood_digits: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/MarginContainer/HBox1/WoodRow/WoodDigits
@onready var meat_digits: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/MarginContainer/HBox1/MeatRow/MeatDigits
@onready var gold_digits: HBoxContainer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/MarginContainer/HBox1/GoldRow/GoldDigits

var wood: int = 0
var meat: int = 0
var gold: int = 0
var slain: int = 1000000000000000

var output: int = 1
var output_multiplier: float = 2
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.0

var pressing = false
var performing = false
var choosing = false
var upgrading = false

var current_upgrade : UpgradeType
var current_action: ActionType

var at_pawn := false

func _ready() -> void:
	animation.play('idle')
	update_text()
	knight.visible = true
	knight_2.visible = false
	knight_3.visible = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if pressing:
		change_action(current_action)
		return
	change_action(ActionType.IDLE)

func update_knight_visuals(): #UPDATE THIS
	knight.visible = total_knights >= 1
	knight_2.visible = total_knights >= 2
	knight_3.visible = total_knights >= 3

func update_output_from_knights():
	output *= total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func update_text():
	var speed = snapped(animation.speed_scale, 0.1)
	win_label.text = "Go to the next phase\nWood Cost: %d\nMeat Cost: %d\nGold Cost: %d" % [
		upgrades[UpgradeType.WIN].wood_cost,
		upgrades[UpgradeType.WIN].meat_cost,
		upgrades[UpgradeType.WIN].gold_cost,
	]
	label.text = "Wood avaiable: %d\nMeat avaiable: %d\nGold avaiable: %d" % [wood, meat, gold]
	out_label.text = "Output\nWood Cost: %d\nMeat Cost: %d\nGold Cost: %d\nOutput: %d" % [
		upgrades[UpgradeType.OUTPUT].wood_cost,
		upgrades[UpgradeType.OUTPUT].meat_cost,
		upgrades[UpgradeType.OUTPUT].gold_cost,
		output
	]
	spd_label.text = "Speed\nWood Cost: %d\nMeat Cost: %d\nGold Cost: %d\nSpeed: %d" % [
		upgrades[UpgradeType.SPEED].wood_cost,
		upgrades[UpgradeType.SPEED].meat_cost,
		upgrades[UpgradeType.SPEED].gold_cost,
		speed
	]
	if total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
	else:
		knight_label.text = "Number of knights\nWood Cost: %d\nMeat Cost: %d\nGold Cost: %d\nOutput: %d" % [
			upgrades[UpgradeType.KNIGHT].wood_cost,
			upgrades[UpgradeType.KNIGHT].meat_cost,
			upgrades[UpgradeType.KNIGHT].gold_cost,
			total_knights
		]

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

	var in_time := 0.4 / upgrade_anim_speed
	var pop_time := 0.1 / upgrade_anim_speed
	var out_time := 0.4 / upgrade_anim_speed
	var win_time := 0.8

	if type == UpgradeType.WIN:
		var tween = get_tree().create_tween()
		while choosing:
			tween.tween_property(
				label_type,
				"theme_override_font_sizes/normal_font_size",
				30,
				win_time
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
				try_buy_upgrade(UpgradeType.WIN)
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
			return out_label
		UpgradeType.KNIGHT:
			return knight_label
		UpgradeType.WIN:
			return win_label
	return null

func try_buy_upgrade(type: UpgradeType) -> void:
	print("[UPGRADE] streak=%d delay=%.2f"
	% [upgrade_streak, current_upgrade_delay])

	if type == UpgradeType.WIN:
		choosing = false
		upgrading = false
		await get_tree().process_frame
		get_tree().change_scene_to_packed(MAIN_2)
		return

	var up = upgrades[type]

	if slain < up.cost:
		return
	if type == UpgradeType.KNIGHT and total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
		return

	slain -= up.cost
	up.apply.call()
	up.cost = int(up.cost * up.cost_mult)
	update_text()

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

func _on_win_button_mouse_entered() -> void:
	on_upgrade_mouse_entered(UpgradeType.WIN)

func _on_win_button_mouse_exited() -> void:
	on_upgrade_mouse_exited()

func _on_attack_button_down() -> void:
	pressing = true
	request_change_action(ActionType.ATTACK)

func _on_attack_button_up() -> void:
	pressing = false

func _on_block_button_down() -> void:
	pressing = true
	request_change_action(ActionType.BLOCK)

func _on_block_button_up() -> void:
	pressing = false

func _on_loot_button_down() -> void:
	pressing = true
	request_change_action(ActionType.LOOT)

func _on_loot_button_up() -> void:
	pressing = false

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
	animation.play("looting")

func _on_tab_container_tab_changed(_tab: int) -> void:
	if at_pawn:
		request_change_action(ActionType.IDLE)
		at_pawn = false
		return
	else:
		animation.play('pawn_idle')
		at_pawn = true
		return

func request_change_action(requested_action: ActionType) -> void:
	if performing:
		return
	if pressing:
		change_action(requested_action)
		return
	change_action(ActionType.IDLE)

func change_action(new_action: ActionType) -> void:
	current_action = new_action
	match current_action:
		ActionType.IDLE:
			animation.play('idle')
		ActionType.ATTACK:
			performing = true
			animation.play('attack')
			await animation.animation_finished
			performing = false
			meat += output
		ActionType.BLOCK:
			performing = true
			animation.play('block')
			await animation.animation_finished
			performing = false
			wood += output
		ActionType.LOOT:
			performing = true
			animation.play('loot')
			await animation.animation_finished
			performing = false
			gold += output
	update_text()

func clear_container(container: Container) -> void:
	for child in container.get_children()
		child.queue_free()

func set_number_icons(
	container: HBoxContainer,
	value: int,
	resource_type: ResourceType
) -> void:
	container.queue_free_children()
	var digit_map = numbers[resource_type] # variável do mapa de números criados
	var chars := str(value) # variação de 0 a 9
	for c in chars: # confere de 0 a 9
		var digit := int(c) # transforma o string em int
		var tex = digit_map[digit] # confere o int acima e confere de acordo com o mapa de números acima
		var icon := TextureRect.new() # varíavel do ícone específico para o número específico
		icon.texture = tex # textura do ícone vira a específica da variável acima
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED # seta o stretch mode
		icon.custom_minimum_size = Vector2(24, 24) # seta o tamanho mínimo
		container.add_child(icon) # this being, the icons will not be added beforehand, they will be called within my scene
