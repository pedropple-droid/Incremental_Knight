extends Node

class_name DataHandler

const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const DIGIT_BASE_SIZE := 6
const DIGIT_SCALE := 0.5
const original_output_correction = 0.08
const MIN_OUTPUT_UPGRADE := 1.15
const TOTAL := -1

var in_time := 0.5 / upgrade_anim_speed
var pop_time := 0.2 / upgrade_anim_speed
var out_time := 0.5 / upgrade_anim_speed
var gold: int = 10000
var meat: int = 100000
var wood: int = 1000000
var time_left := 120.0
var knight_set_level := 0
var toughness_level := 0
var timer_speed_multiplier: float = 1.0
var max_knights_per_run: int = 3
var total_knights: int = 1
var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.5
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var heat := 1.8
var output_multiplier := 2.0
var output_floor := 1.0
var output := 1.0
