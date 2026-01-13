extends Control

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

var slain: int = 0
var output_cost: int = 20
var spd_cost: int = 5
var extra_knight_cost: int = 500
var double_multiplier: int = 2
var onehalf_multiplier: float = 1.5
var spd_adder: float = 1.1
var output:int = 1
var knights: int = 1
var win_cost: int = 10000


func _ready() -> void:
	animation.play('idle')
	update_text()
	win_button.text = "Win!! \nCost: "+str(win_cost)+"\n enemies left: "+str(win_cost - slain)

func _on_button_pressed() -> void:
	animation.play("attack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	slain += output
	label.text = "Enemies slain: "+str(slain)
	animation.play("idle")

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
	if knights == 3:
		extra_knight_upgrade.text = "Maxed out!!"
		return
	if slain >= extra_knight_cost:
		slain -= extra_knight_cost
		extra_knight_cost *= 5
		if knights == 1:
			knight_2.visible = true
			output *= 2.5
			animation.speed_scale *= 1.5
		elif knights == 2:
			knight_3.visible = true
			output *= 2
			animation.speed_scale *= 2
		knights += 1
	update_text()

func update_text():
	var speed : float = snapped(animation.speed_scale, 0.1)
	label.text = "Enemies slain: "+str(slain)
	output_upgrade.text = "Output \nCost: "+str(output_cost)+"\n Output: "+str(output)
	speed_upgrade.text = "Speed \nCost: "+str(spd_cost)+"\n Speed Multiplier: "+str(speed)
	if knights == 3:
		extra_knight_upgrade.text = "Maxed out!!"
		return
	extra_knight_upgrade.text = "Number of Knights \nCost: "+str(extra_knight_cost)+"\n Knights: "+str(knights)

func _on_win_button_pressed() -> void:
	if slain >= win_cost:
		animation.play("run off")
		await animation.animation_finished
		main.queue_free()
