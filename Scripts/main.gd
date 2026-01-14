extends Control

const original_output_correction = 0.1
const win_cost: int = 60000

@onready var main: Control = $"."
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

var slain: int = 10000
var output_cost: int = 20
var spd_cost: int = 5
var extra_knight_cost: int = 500
var quintuple_multiplier: int = 5
var triple_multiplier: int = 3
var double_multiplier: int = 2
var onehalf_multiplier: float = 1.5
var output_multiplier: float = 2
var spd_adder: float = 1.1
var output:int = 1
var knight_set_level: int = 0
var max_knights_per_run: int = 3
var total_knights: int = 1
var pressing = false
var choosing = false
var upgrading := false

func _ready() -> void:
	animation.play('idle')
	update_text()
	knight_2.visible = false
	knight_3.visible = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	slain += output
	if pressing:
		animation.play('attack')
		update_text()
		return
	animation.play("idle")
	update_text()

func _on_output_upgrade_button_pressed() -> void:
	if slain >= output_cost:
		slain -= output_cost
		output_cost *= double_multiplier
		output *= output_multiplier
		output_multiplier -= original_output_correction
		update_text()

func _on_extra_knight_upgrade_pressed() -> void:
	var amount: int = knights_per_purchase()
	if total_knights + amount > max_knights_per_run:
		knight_label.text = "Maxed out!!"
		return
	if slain < extra_knight_cost:
		return
	slain -= extra_knight_cost
	total_knights += amount
	extra_knight_cost *= triple_multiplier
	update_knight_visuals()
	update_output_from_knights()
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
	var speed : float = snapped(animation.speed_scale, 0.1)
	win_label.text = "Win!! \nCost: "+str(win_cost)+"\n Enemies left: "+ str(slain_left)
	label.text = "Enemies slain: "+str(slain)
	out_label.text = "Output \nCost: "+str(output_cost)+"\n Output: "+str(output)
	spd_label.text = "Speed \nCost: "+str(spd_cost)+"\n Speed Multiplier: "+str(speed)
	if total_knights == 3:
		knight_label.text = "Maxed out!!"
		return
	knight_label.text = "Number of Knights \nCost: "+str(extra_knight_cost)+"\n Knights: "+str(total_knights)

func _on_win_button_pressed() -> void:
	if slain >= win_cost:
		get_tree().change_scene_to_file("res://scenes/main_2.tscn")

func _on_button_button_down() -> void:
	pressing = true
	animation.play("attack")

func _on_button_button_up() -> void:
	pressing = false

func _on_speed_upgrade_button_mouse_entered() -> void:
	if upgrading:
		return
	choosing = true
	upgrading = true
	start_upgrade_loop()

func _on_speed_upgrade_button_mouse_exited() -> void:
	choosing = false

func start_upgrade_loop():
	while choosing:
		if slain >= spd_cost:
			await do_speed_upgrade()
		else:
			await get_tree().process_frame
	upgrading = false

func do_speed_upgrade():
	var tween := get_tree().create_tween()
	tween.tween_property(spd_label, "theme_override_font_sizes/normal_font_size", 14, 0.4).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(spd_label, "theme_override_colors/default_color", Color(0.327, 0.327, 0.327, 1.0), 0.5)
	await tween.finished
	tween = get_tree().create_tween()
	if not choosing:
		tween.tween_property(spd_label, "theme_override_colors/default_color", Color(0.875, 0.875, 0.875, 1.0), 0.2)
		tween.parallel().tween_property(spd_label, "theme_override_font_sizes/normal_font_size", 16, 0.2)
		return
	slain -= spd_cost
	spd_cost = int(spd_cost * onehalf_multiplier)
	animation.speed_scale *= 1.1
	update_text()
	tween.tween_property(spd_label, "theme_override_colors/default_color", Color(0.875, 0.875, 0.875, 1.0), 0.1)
	tween.chain().tween_property(spd_label, "theme_override_font_sizes/normal_font_size", 24, 0.1)
	tween.parallel().tween_property(spd_label, "theme_override_constants/outline_size", 4, 0.1 )
	tween.chain().tween_property(spd_label, "theme_override_font_sizes/normal_font_size", 16, 0.4)
	tween.parallel().tween_property(spd_label, "theme_override_constants/outline_size", 0, 0.4 )
	await tween.finished


func _on_output_upgrade_button_mouse_entered() -> void:
	pass # Replace with function body.


func _on_output_upgrade_button_mouse_exited() -> void:
	pass # Replace with function body.


func _on_extra_knight_upgrade_mouse_entered() -> void:
	pass # Replace with function body.


func _on_extra_knight_upgrade_mouse_exited() -> void:
	pass # Replace with function body.


func _on_win_button_mouse_entered() -> void:
	pass # Replace with function body.


func _on_win_button_mouse_exited() -> void:
	pass # Replace with function body.
