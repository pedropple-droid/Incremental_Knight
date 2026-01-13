extends Control

const original_slain = 0
const original_output_cost = 20
const original_spd_cost = 5
const original_extra_knight_cost = 500
const original_output = 1
const original_spd_scale = 1.0

@onready var main: Control = $"."
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/Label
@onready var speed_upgrade: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton
@onready var output_upgrade: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton
@onready var extra_knight_upgrade: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/ExtraKnightUpgrade
@onready var h_box: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer
@onready var knight: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight
@onready var knight_2: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight2
@onready var knight_3: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/HBoxContainer/Knight3
@onready var win_button: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/WinButton
@onready var sprite1: AnimatedSprite2D = $Game_Over/AnimatedSprite2D
@onready var sprite2: AnimatedSprite2D = $Game_Over/AnimatedSprite2D2
@onready var sprite3: AnimatedSprite2D = $Game_Over/AnimatedSprite2D3

var slain: int = 1000000
var output_cost: int = 20
var spd_cost: int = 5
var extra_knight_cost: int = 500
var quintuple_multiplier: int = 5
var triple_multiplier: int = 3
var double_multiplier: int = 2
var onehalf_multiplier: float = 1.5
var spd_adder: float = 1.1
var output:int = 1
var win_cost: int = 10000
var prestige_level: int = 0
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1

func _ready() -> void:
	animation.play('idle')
	update_text()
	knight_2.visible = false
	knight_3.visible = false

func _on_button_pressed() -> void:
	animation.play("attack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	slain += output
	animation.play("idle")
	update_text()

func _on_output_upgrade_button_pressed() -> void:
	if slain >= output_cost:
		slain -= output_cost
		output_cost *= double_multiplier
		output += 1
		update_text()

func _on_speed_upgrade_button_pressed() -> void:
	if slain >= spd_cost:
		slain -= spd_cost
		spd_cost *= onehalf_multiplier
		animation.speed_scale *= 1.1
		update_text()

func _on_extra_knight_upgrade_pressed() -> void:
	var amount: int = knights_per_purchase()
	if total_knights + amount > max_knights_per_run:
		extra_knight_upgrade.text = "Maxed out!!"
		return
	if slain < extra_knight_cost:
		return
	slain -= extra_knight_cost
	total_knights += amount
	update_knight_visuals()
	update_output_from_knights()
	update_text()

func update_knight_visuals(): #UPDATE THIS
	knight.visible = total_knights >= 1
	knight_2.visible = total_knights >= 2
	knight_3.visible = total_knights >= 3

func update_output_from_knights():
	output = original_output * total_knights

func knights_per_purchase():
	return int(pow(3, knight_set_level))

func update_text():
	var slain_left = win_cost - slain
	var speed : float = snapped(animation.speed_scale, 0.1)
	win_button.text = "Win!! \nCost: "+str(win_cost)+"\n Enemies left: "+ str(slain_left)
	label.text = "Enemies slain: "+str(slain)
	output_upgrade.text = "Output \nCost: "+str(output_cost)+"\n Output: "+str(output)
	speed_upgrade.text = "Speed \nCost: "+str(spd_cost)+"\n Speed Multiplier: "+str(speed)
	if total_knights == 3:
		extra_knight_upgrade.text = "Maxed out!!"
		return
	extra_knight_upgrade.text = "Number of Knights \nCost: "+str(extra_knight_cost)+"\n Knights: "+str(total_knights)

func _on_win_button_pressed() -> void:
	if slain < win_cost:
		return
	prestige_level += 1
	
	reset_run()
	
	if prestige_level == 1:
		knight_set_level = 1
		max_knights_per_run = 3
	elif prestige_level == 2:
		knight_set_level = 2
		max_knights_per_run = 9
	elif prestige_level == 3:
		knight_set_level = 3
		max_knights_per_run = pow(3, knight_set_level)
	elif prestige_level == 4:
		knight_set_level = 4
		max_knights_per_run = pow(4, knight_set_level)
	update_text()

func reset_run():
	slain = original_slain
	total_knights = 1
	output = original_output
	animation.speed_scale = original_spd_scale
	spd_cost = original_spd_cost
	output_cost = original_output_cost
	update_knight_visuals()

func check_big_bang():
	if output >= 1e10:
		big_bang()

func big_bang():
	prestige_level = 0
	knight_set_level = 0
	max_knights_per_run = 3
	reset_run()
