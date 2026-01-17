extends Control

const MAIN_2 = preload("uid://ey2i670agjff")

const original_output_correction = 0.08
const win_cost: int = 60000
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15

enum UpgradeType { 
	OUTPUT,
	SPEED,
	KNIGHT,
	WIN,
}

var upgrades := {
	UpgradeType.OUTPUT: {
		"cost": 20,
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
		"cost": 5,
		"cost_mult": 1.5,
		"apply": func():
			animation.speed_scale *= 1.1,
	},
	UpgradeType.KNIGHT: {
		"cost": 500,
		"cost_mult": 3.0,
		"apply": func():
			var amount = knights_per_purchase()
			total_knights += amount
			update_knight_visuals()
			update_output_from_knights(),
	},
	UpgradeType.WIN: {
		"cost": 60000,
		"cost_mult": 1.0,
		"apply": func():
			pass,
	},
}


@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/Label
@onready var spd_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/RichTextLabel
@onready var out_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton/CenterContainer/RichTextLabel
@onready var knight_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/ExtraKnightUpgrade/CenterContainer/RichTextLabel
@onready var win_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/WinButton/CenterContainer/RichTextLabel
@onready var h_box: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer
@onready var knight: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight
@onready var knight_2: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight2
@onready var knight_3: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight3

var slain: int = 11111111111111110
var output: int = 1
var output_multiplier: float = 2
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.0

var pressing = false
var choosing = false
var upgrading := false
var current_upgrade : UpgradeType

func _ready() -> void:
	animation.play('idle')
	update_text()
	knight_2.visible = false
	knight_3.visible = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	slain += output
	if pressing:
		animation.play('attack')
		update_text()
		return
	animation.play("idle")
	update_text()

func update_knight_visuals(): #UPDATE THIS
	knight.visible = total_knights >= 1
	knight_2.visible = total_knights >= 2
	knight_3.visible = total_knights >= 3

func update_output_from_knights():
	output *= total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func update_text():
	var slain_left = win_cost - slain
	var speed = snapped(animation.speed_scale, 0.1)

	win_label.text = "Go to the next phase...?\nCost: %d\nEnemies left: %d" % [win_cost, max(slain_left, 0)]
	label.text = "Enemies slain: %d" % slain

	out_label.text = "Output\nCost: %d\nOutput: %d" % [
		upgrades[UpgradeType.OUTPUT].cost,
		output
	]

	spd_label.text = "Speed\nCost: %d\nSpeed Multiplier: %s" % [
		upgrades[UpgradeType.SPEED].cost,
		speed
	]

	if total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
	else:
		knight_label.text = "Number of Knights\nCost: %d\nKnights: %d" % [
			upgrades[UpgradeType.KNIGHT].cost,
			total_knights
		]

func _on_button_button_down() -> void:
	pressing = true
	animation.play("attack")

func _on_button_button_up() -> void:
	pressing = false

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
	if slain < up.cost:
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
