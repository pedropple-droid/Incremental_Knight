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
@onready var upgrade_controller: UpgradeController = UpgradeController.new()
@onready var visual_controller: VisualController = VisualController.new()
@onready var data_handler: DataHandler = DataHandler.new()


func _ready() -> void:
	await get_tree().process_frame
	visual_controller.nullify_all()

	animation.animation_finished.connect(_on_animation_finished)

	add_child(qte)
	qte.qte_started.connect(_on_qte_started)
	qte.qte_success.connect(_on_qte_success)
	qte.qte_fail.connect(_on_qte_fail)
	qte.start()

	add_child(action_controller)
	action_controller.action_changed.connect(_on_action_changed)

	add_child(upgrade_controller)
	add_child(visual_controller)
	add_child(data_handler)

	update_all_upgrade_costs()
	visual_controller.update_floating_totals()
	setup_timer()


func _process(delta):
	for type in visual_controller.upgrade_patches.keys():
		visual_controller.update_upgrade_patch(type)
	data_handler.time_left = max(data_handler.time_left - delta * data_handler.timer_speed_multiplier, 0)
	timer_label.text = format_time(data_handler.time_left)


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
	visual_controller.attack_chosen.visible = action == ActionController.ActionType.ATTACK
	visual_controller.forage_chosen.visible = action == ActionController.ActionType.FORAGE
	visual_controller.block_chosen.visible = action == ActionController.ActionType.BLOCK


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


func _on_animation_finished(anim_name: StringName) -> void:
	action_controller.animation_finished()

# =========== UPGRADE ============


func update_all_upgrade_costs() -> void:
	for type in upgrade_controller.upgrades.keys():
		data_handler.update_upgrade_cost(type)

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
