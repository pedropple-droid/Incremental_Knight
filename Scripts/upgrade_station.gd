class_name UpgradeStation

extends Node

enum UpgradeType { 
	TOTAL,
	OUTPUT,
	SPEED,
	TOUGHNESS,
	KNIGHT,
}

var game_state: GameState
var visual_station: VisualStation
var action_station: ActionStation
var current_upgrade : UpgradeType

var upgrades := {
	UpgradeType.OUTPUT: {
		"wood_cost": 75,
		"meat_cost": 125,
		"gold_cost": 200,
		"cost_mult": 2.0,
		"apply": func():
			@warning_ignore("narrowing_conversion")
			game_state.output_floor *= game_state.output_multiplier
			game_state.output_multiplier -= game_state.original_output_correction
			game_state.output_multiplier = max(
			game_state.output_multiplier,
			game_state.MIN_OUTPUT_UPGRADE,
		),
	},
	UpgradeType.SPEED: {
		"wood_cost": 4,
		"meat_cost": 5,
		"gold_cost": 10,
		"cost_mult": 1.5,
		"apply": func():
			visual_station.animation.speed_scale *= 1.1,
	},
	UpgradeType.TOUGHNESS: {
		"wood_cost": 20,
		"meat_cost": 30,
		"gold_cost": 40,
		"cost_mult": 2.0,
		"apply": func():
			game_state.toughness_level += 1
			game_state.timer_speed_multiplier *= 0.9,
	},
	UpgradeType.KNIGHT: {
		"wood_cost": 4000,
		"meat_cost": 5500,
		"gold_cost": 8500,
		"cost_mult": 2.5,
		"apply": func():
			var amount = knights_per_purchase()
			game_state.total_knights += amount
			visual_station.update_knight_visuals()
			update_output_from_knights(),
	},
}

func setup(state: GameState, visu_station: VisualStation, act_station: ActionStation):
	game_state = state
	visual_station = visu_station
	action_station = act_station

func can_buy(type: UpgradeType) -> bool:
	var up = upgrades[type]
	if game_state.wood < up["wood_cost"]:
		return false
	if game_state.meat < up["meat_cost"]:
		return false
	if game_state.gold < up["gold_cost"]:
		return false
	if type == UpgradeType.KNIGHT and game_state.total_knights >= game_state.max_knights_per_run:
		return false
	return true

func try_buy_upgrade(type: UpgradeType) -> void:
	var up = upgrades[type]

	if type == UpgradeType.KNIGHT and game_state.total_knights >= game_state.max_knights_per_run:
		visual_station.knight_label.text = "Maxed out!!"
		return

	game_state.upgrade_streak += 1

	if game_state.upgrade_streak >= game_state.STREAK_THRESHOLD:
		game_state.current_upgrade_delay = max(
			game_state.MIN_UPGRADE_DELAY,
			game_state.current_upgrade_delay * 0.85
		)

		game_state.upgrade_anim_speed = min(
			3.0,
			game_state.upgrade_anim_speed * 1.15
		)

	game_state.wood -= up.wood_cost
	game_state.meat -= up.meat_cost
	game_state.gold -= up.gold_cost
	up.apply.call()
	up.wood_cost = int(up.wood_cost * up.cost_mult)
	up.meat_cost = int(up.meat_cost * up.cost_mult)
	up.gold_cost = int(up.gold_cost * up.cost_mult)

	update_upgrade_cost(type)
	visual_station.update_floating_totals()

func on_upgrade_mouse_entered(type: UpgradeType):
	if game_state.upgrading:
		return
	current_upgrade = type
	game_state.choosing = true
	start_upgrade_loop()

func on_upgrade_mouse_exited():
	game_state.choosing = false
	game_state.upgrade_streak = 0
	game_state.current_upgrade_delay = game_state.BASE_UPGRADE_DELAY
	game_state.upgrade_anim_speed = game_state.BASE_UPGRADE_DELAY

func start_upgrade_loop():
	while game_state.choosing:
		game_state.upgrading = true
		if can_buy(current_upgrade):
			await do_upgrade_feedback(current_upgrade)
			await get_tree().create_timer(game_state.current_upgrade_delay).timeout
		else:
			await get_tree().process_frame
	game_state.upgrading = false

func do_upgrade_feedback(type: UpgradeType):
	var label_type := get_label_from_upgrade(type)
	var in_time := 0.5 / game_state.upgrade_anim_speed
	var pop_time := 0.2 / game_state.upgrade_anim_speed
	var out_time := 0.5 / game_state.upgrade_anim_speed
	var tween = get_tree().create_tween()

	tween.tween_property(
		label_type,
		"theme_override_font_sizes/font_size",
		14,
		in_time
	)
	await tween.finished

	if not game_state.choosing:
		tween = get_tree().create_tween()
		tween.tween_property(
			label_type,
			"theme_override_font_sizes/font_size",
			16,
			0.1
		)
		await tween.finished
		return

	try_buy_upgrade(type)

	tween = get_tree().create_tween()
	tween.tween_property(
		label_type,
		"theme_override_font_sizes/font_size",
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
		"theme_override_font_sizes/font_size",
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

func get_label_from_upgrade(type: UpgradeType) -> Label:
	match type:
		UpgradeType.SPEED:
			return visual_station.spd_label
		UpgradeType.OUTPUT:
			return visual_station.output_label
		UpgradeType.KNIGHT:
			return visual_station.knight_label
		UpgradeType.TOUGHNESS:
			return visual_station.toughness_label
	return null

func _on_speed_upgrade_button_mouse_entered():
	game_state.hovering = true
	on_upgrade_mouse_entered(UpgradeType.SPEED)
	visual_station.declare_hovered_upgrade(visual_station.speed_btt, visual_station.speed_9p_rect, visual_station.speed_chosen)

func _on_speed_upgrade_button_mouse_exited():
	game_state.hovering = false
	on_upgrade_mouse_exited()
	visual_station.declare_hovered_upgrade(visual_station.speed_btt, visual_station.speed_9p_rect, visual_station.speed_chosen)

func _on_output_upgrade_button_mouse_entered():
	game_state.hovering = true
	on_upgrade_mouse_entered(UpgradeType.OUTPUT)
	visual_station.declare_hovered_upgrade(visual_station.output_btt, visual_station.output_9p_rect, visual_station.output_chosen)

func _on_output_upgrade_button_mouse_exited():
	game_state.hovering = false
	on_upgrade_mouse_exited()
	visual_station.declare_hovered_upgrade(visual_station.output_btt, visual_station.output_9p_rect, visual_station.output_chosen)

func _on_extra_knight_upgrade_mouse_entered() -> void:
	game_state.hovering = true
	on_upgrade_mouse_entered(UpgradeType.KNIGHT)
	visual_station.declare_hovered_upgrade(visual_station.knight_btt, visual_station.e_knight_9p_rect, visual_station.knight_chosen)

func _on_extra_knight_upgrade_mouse_exited() -> void:
	game_state.hovering = false
	on_upgrade_mouse_exited()
	visual_station.declare_hovered_upgrade(visual_station.knight_btt, visual_station.e_knight_9p_rect, visual_station.knight_chosen)

func _on_toughness_button_mouse_entered() -> void:
	game_state.hovering = true
	on_upgrade_mouse_entered(UpgradeType.TOUGHNESS)
	visual_station.declare_hovered_upgrade(visual_station.toughness_btt, visual_station.toughness_9p_rect, visual_station.toughness_chosen)

func _on_toughness_button_mouse_exited() -> void:
	game_state.hovering = false
	on_upgrade_mouse_exited()
	visual_station.declare_hovered_upgrade(visual_station.toughness_btt, visual_station.toughness_9p_rect, visual_station.toughness_chosen)

func update_all_upgrade_costs() -> void:
	for type in upgrades.keys():
		update_upgrade_cost(type)

func update_upgrade_cost(type: UpgradeType) -> void:
	var up = upgrades[type]
	var containers = visual_station.upgrade_digit_containers[type]
	visual_station.set_crossroad(up, containers)

func update_output_from_knights():
	game_state.output *= game_state.total_knights

func knights_per_purchase():
	return int(pow(3, game_state.knight_set_level))
