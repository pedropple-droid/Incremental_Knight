extends Control

const original_output_correction = 0.08
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15

enum UpgradeType { 
	OUTPUT_2,
	SPEED_2,
	KNIGHT_2,
	WIN_2,
}

var upgrades := {
	UpgradeType.OUTPUT_2: {
		"cost": 30,
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
	UpgradeType.SPEED_2: {
		"cost": 12,
		"cost_mult": 1.5,
		"apply": func():
			animation_2.speed_scale *= 1.1,
	},
	UpgradeType.KNIGHT_2: {
		"cost": 50000,
		"cost_mult": 3.0,
		"apply": func():
			var amount = knights_per_purchase()
			total_knights += amount
			update_knight_visuals()
			update_output_from_knights(),
	},
	UpgradeType.WIN_2: {
		"cost": 1000000,
		"cost_mult": 1.0,
		"apply": func():
			pass,
	},
}


@onready var animation_2: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/Label
@onready var spd_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton/CenterContainer/RichTextLabel
@onready var out_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton/CenterContainer/RichTextLabel
@onready var knight_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/ExtraKnightUpgrade/CenterContainer/RichTextLabel
@onready var win_label: RichTextLabel = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/WinButton/CenterContainer/RichTextLabel
@onready var row_1: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/VBoxContainer/row1
@onready var row_2: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/VBoxContainer/row2
@onready var row_3: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/VBoxContainer/row3

var wood: int = 0
var meat: int = 0
var gold: int = 0
var output: int = 3
var output_multiplier: float = 2
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.0

var pressing = false
var choosing = false
var upgrading = false
var current_upgrade : UpgradeType

func _ready() -> void:
	animation_2.play('idle_2')
	update_text()
	row_2.visible = false
	row_3.visible = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if pressing:
		animation_2.play('attack_2')
		update_text()
		return
	animation_2.play("idle_2")
	update_text()

func update_knight_visuals(): #UPDATE THIS
	row_1.visible = total_knights >= 1
	row_2.visible = total_knights >= 2
	row_3.visible = total_knights >= 3

func update_output_from_knights():
	output *= total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func update_text():
	var speed = snapped(animation_2.speed_scale, 0.1)


	out_label.text = "Output\nCost: %d\nOutput: %d" % [
		upgrades[UpgradeType.OUTPUT_2].cost,
		output
	]

	spd_label.text = "Speed\nCost: %d\nSpeed Multiplier: %s" % [
		upgrades[UpgradeType.SPEED_2].cost,
		speed
	]

	if total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
	else:
		knight_label.text = "Number of Knights\nCost: %d\nKnights: %d" % [
			upgrades[UpgradeType.KNIGHT_2].cost,
			total_knights
		]

func _on_button_button_down() -> void:
	pressing = true
	animation_2.play("attack_2")

func _on_button_button_up() -> void:
	pressing = false

func on_upgrade_mouse_entered(type: UpgradeType):
	print("[HOVER] entered | choosing=%s upgrading=%s current=%s"
	% [choosing, upgrading, current_upgrade])
	if upgrading:
		upgrading = false
	current_upgrade = type
	choosing = true
	upgrading = true
	start_upgrade_loop()

func on_upgrade_mouse_exited():
	choosing = false
	upgrade_streak = 0
	current_upgrade_delay = BASE_UPGRADE_DELAY
	upgrade_anim_speed = BASE_UPGRADE_DELAY
	await get_tree().create_timer(0.1).timeout

func start_upgrade_loop():
	while choosing:
		if can_buy(current_upgrade):
			await do_upgrade_feedback(current_upgrade)
			await get_tree().create_timer(current_upgrade_delay).timeout
		else:
			await get_tree().process_frame
	upgrading = false

func can_buy(type: UpgradeType) -> bool:
	if type == UpgradeType.KNIGHT_2 and total_knights >= max_knights_per_run:
		return false
	return true

func do_upgrade_feedback(type: UpgradeType):
	var label_type := get_label_from_upgrade(type)

	var in_time := 0.4 / upgrade_anim_speed
	var pop_time := 0.1 / upgrade_anim_speed
	var out_time := 0.4 / upgrade_anim_speed
	var win_time := 0.8
	var tween = get_tree().create_tween()

	if type == UpgradeType.WIN_2:
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
				try_buy_upgrade(UpgradeType.WIN_2)
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

	tween = get_tree().create_tween()
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
		UpgradeType.SPEED_2:
			return spd_label
		UpgradeType.OUTPUT_2:
			return out_label
		UpgradeType.KNIGHT_2:
			return knight_label
		UpgradeType.WIN_2:
			return win_label
	return null

func try_buy_upgrade(type: UpgradeType) -> void:
	print("[UPGRADE] streak=%d delay=%.2f"
	% [upgrade_streak, current_upgrade_delay])

	if type == UpgradeType.WIN_2:
		choosing = false
		upgrading = false
		await get_tree().process_frame
		pass
		return

	var up = upgrades[type]

	if type == UpgradeType.KNIGHT_2 and total_knights >= max_knights_per_run:
		knight_label.text = "Maxed out!!"
		return

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
	on_upgrade_mouse_entered(UpgradeType.SPEED_2)

func _on_speed_upgrade_button_mouse_exited():
	on_upgrade_mouse_exited()

func _on_output_upgrade_button_mouse_entered():
	on_upgrade_mouse_entered(UpgradeType.OUTPUT_2)

func _on_output_upgrade_button_mouse_exited():
	on_upgrade_mouse_exited()

func _on_extra_knight_upgrade_mouse_entered() -> void:
	on_upgrade_mouse_entered(UpgradeType.KNIGHT_2)

func _on_extra_knight_upgrade_mouse_exited() -> void:
	on_upgrade_mouse_exited()

func _on_win_button_mouse_entered() -> void:
	on_upgrade_mouse_entered(UpgradeType.WIN_2)

func _on_win_button_mouse_exited() -> void:
	
	on_upgrade_mouse_exited()
