extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MiningSpace/MarginContainer/VBoxContainer/Label
@onready var speed_upgrade: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/SpeedUpgradeButton
@onready var output_upgrade: Button = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Upgrades/MarginContainer/VBoxContainer/OutputUpgradeButton

var slain: int = 0
var output_cost: int = 20
var spd_cost: int = 5
var double_multiplier: int = 2
var onehalf_multiplier: float = 1.5
var spd_adder: float = 1.1
var output:int = 1

func _ready() -> void:
	animation.play('idle')
	update_text()

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

func update_text():
	var speed : float = snapped(animation.speed_scale, 0.1)
	label.text = "Enemies slain: "+str(slain)
	output_upgrade.text = "Output \nCost: "+str(output_cost)+"\n Output: "+str(output)
	speed_upgrade.text = "Speed \nCost: "+str(spd_cost)+"\n Speed Multiplier: "+str(speed)
