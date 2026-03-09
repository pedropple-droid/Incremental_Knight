# 🔴🟠🟢🔵⚪
# [QOL]
# ---------------------------------------------------------------
# [UPGRADE PANELS]
# ---------------------------------------------------------------
# [ACTION PANELS]
# ---------------------------------------------------------------
# [VISUAL PANEL]
# ---------------------------------------------------------------
# [TOUGHNESS TIMER]
# ---------------------------------------------------------------
# [QTE]🔵
# qte not working
#  ---------------------------------------------------------------
# [GAME FEEL]
#  ---------------------------------------------------------------

extends Control

const MAIN_2 = preload("uid://ey2i670agjff")

@onready var game_state: GameState
@onready var visual_station: VisualStation = $VisualStation
@onready var upgrade_station: UpgradeStation = $UpgradeStation
@onready var action_station: ActionStation = $ActionStation
@onready var timer_label: Label = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/TimerLabel
@onready var countdown_timer: Timer = $TabContainer/MarginContainer/PanelContainer/MarginContainer/HBOrganizer/VisualSpace/MarginTimer/Timer

var buttons: Array

var start_button_position: Vector2

var current_button: Button

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var at_pawn := false

var current_cursor: VisualStation.CursorState

var output_tween: Tween

func _ready() -> void:
	await get_tree().process_frame

	game_state = GameState.new()
	upgrade_station.setup(game_state, visual_station, action_station)
	visual_station.setup(game_state, upgrade_station, action_station)
	action_station.setup(game_state, upgrade_station, visual_station)

	buttons = [visual_station.attack, visual_station.block, visual_station.forage]
	perform_action(action_station.ActionType.IDLE)
	current_cursor = visual_station.CursorState.NORMAL
	visual_station.knight.visible = true
	visual_station.knight_2.visible = false
	visual_station.knight_3.visible = false

	start_qte_loop()
	visual_station.nullify_all()

func _process(delta):
	if game_state.time_left > 0:
		game_state.time_left -= delta * game_state.timer_speed_multiplier
		timer_label.text = format_time(game_state.time_left)
	# Input.set_custom_mouse_cursor(CURSOR_04, Input.CURSOR_ARROW, Vector2 (0, 0))
	update_cursor_logic()
	for type in visual_station.upgrade_patches.keys():
		visual_station.update_upgrade_patch(type)
	game_state.time_left = max(game_state.time_left - delta * game_state.timer_speed_multiplier, 0)
	timer_label.text = format_time(game_state.time_left)

func format_time(seconds: float) -> String:
	var s := int(seconds)
	@warning_ignore("integer_division")
	var mins := s / 60
	var secs := s % 60
	return "%02d:%02d" % [mins, secs]

func update_cursor_logic():
	if visual_station.sticky_button != null:
		current_cursor = VisualStation.CursorState.STICKY

	elif game_state.hovering:
		current_cursor = VisualStation.CursorState.HOVER

	else:
		current_cursor = VisualStation.CursorState.NORMAL

	visual_station.apply_cursor(current_cursor)

func start_action_loop():
	match action_station.current_action:
		action_station.ActionType.ATTACK:
			current_button = visual_station.attack
		action_station.ActionType.BLOCK:
			current_button = visual_station.block
		action_station.ActionType.FORAGE:
			current_button = visual_station.forage
		action_station.ActionType.IDLE:
			current_button = null

	if game_state.action_loop_running:
		return

	game_state.action_loop_running = true

	while game_state.pressing:
		await perform_action(action_station.current_action)

	game_state.action_loop_running = false
	perform_action(action_station.ActionType.IDLE)

func perform_action(action):
	game_state.performing = true

	match action:
		action_station.ActionType.ATTACK:
			visual_station.animation.play("attack")
			game_state.gold += max(game_state.output_floor, game_state.output)
		action_station.ActionType.BLOCK:
			visual_station.animation.play("block")
			game_state.wood += max(game_state.output_floor, game_state.output)
		action_station.ActionType.FORAGE:
			visual_station.animation.play("forage")
			game_state.meat += max(game_state.output_floor, game_state.output)
		_:
			visual_station.animation.play("idle")
	await visual_station.animation.animation_finished
	game_state.performing = false
	visual_station.update_floating_totals()

func start_qte_loop():
	var random_interval = rng.randf_range(2.0, 4.0)
	await get_tree().create_timer(random_interval).timeout
	awarn_qte()

func awarn_qte():
	var random_choice = buttons.pick_random()
	tween_chosen_action(random_choice)

func tween_chosen_action(action):
	var tween = get_tree().create_tween()
	var qte_check := 1.5
	
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

	if chosen_button == current_button:
		tween.tween_property(
			chosen_button,
			"modulate",
			Color(0.0, 1.544, 0.0, 1.0),
			qte_check
		)
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
	start_qte_loop()

func successful_qte():
	game_state.output += game_state.output_floor * 5
	output_tween = get_tree().create_tween()
	output_tween.tween_property(
		game_state,
		"output",
		game_state.output_floor,
		10.0
	).set_delay(1.5)\
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_IN_OUT)
	print("DEBUG", game_state.output, game_state.output_floor)

func _on_attack_mouse_entered() -> void:
	game_state.hovering = true
	visual_station.declare_hovered_action(visual_station.attack)

func _on_attack_mouse_exited() -> void:
	game_state.hovering = false
	visual_station.declare_hovered_action(visual_station.attack)

func _on_forage_mouse_entered() -> void:
	game_state.hovering = true
	visual_station.declare_hovered_action(visual_station.forage)

func _on_forage_mouse_exited() -> void:
	game_state.hovering = false
	visual_station.declare_hovered_action(visual_station.forage)

func _on_block_mouse_entered() -> void:
	game_state.hovering = true
	visual_station.declare_hovered_action(visual_station.block)

func _on_block_mouse_exited() -> void:
	game_state.hovering = false
	visual_station.declare_hovered_action(visual_station.block)

func _on_attack_pressed() -> void:
	visual_station.sticky_button = visual_station.attack
	switch_action(action_station.ActionType.ATTACK)

func _on_forage_pressed() -> void:
	visual_station.sticky_button = visual_station.forage
	switch_action(action_station.ActionType.FORAGE)

func _on_block_pressed() -> void:
	visual_station.sticky_button = visual_station.block
	switch_action(action_station.ActionType.BLOCK)

func switch_action(new_action: ActionStation.ActionType) -> void:
	if action_station.current_action == new_action and game_state.pressing:
		game_state.pressing = false
		action_station.current_action = action_station.ActionType.IDLE
		visual_station.check_nine_patch_for_action(new_action)
		return
	if game_state.pressing:
		game_state.pressing = false
		visual_station.check_nine_patch_for_action(action_station.current_action)
	game_state.pressing = true
	action_station.last_action = action_station.current_action
	action_station.current_action = new_action
	visual_station.check_nine_patch_for_action(action_station.current_action)
	start_action_loop()


func _on_speed_upgrade_button_pressed() -> void:
	upgrade_station.try_buy_upgrade(upgrade_station.UpgradeType.SPEED)


func _on_toughness_button_pressed() -> void:
	upgrade_station.try_buy_upgrade(upgrade_station.UpgradeType.TOUGHNESS)


func _on_output_upgrade_button_pressed() -> void:
	upgrade_station.try_buy_upgrade(upgrade_station.UpgradeType.OUTPUT)
