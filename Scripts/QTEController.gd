extends Node
class_name QTEController

signal qte_started(button: Button)
signal qte_success(button: Button)
signal qte_fail(button: Button)

@export var min_interval := 2.0
@export var max_interval := 4.0
@export var warn_time := 1.2
@export var check_time := 0.2

var rng := RandomNumberGenerator.new()
var buttons: Array[Button] = []
var current_button: Button = null
var running := false

func setup(action_buttons: Array[Button]) -> void:
	buttons = action_buttons

func start() -> void:
	if running:
		return
	running = true
	_loop()

func stop() -> void:
	running = false

func _loop() -> void:
	while running:
		var wait := rng.randf_range(min_interval, max_interval)
		await get_tree().create_timer(wait).timeout
		_run_qte()

func _run_qte() -> void:
	if buttons.is_empty():
		return

	current_button = buttons.pick_random()
	qte_started.emit(current_button)

	await get_tree().create_timer(warn_time).timeout

	# Check phase
	var chosen := current_button
	await get_tree().create_timer(check_time).timeout

	if chosen == current_button:
		qte_success.emit(chosen)
	else:
		qte_fail.emit(chosen)
