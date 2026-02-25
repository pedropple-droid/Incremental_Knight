class_name GameState

extends Resource

const original_output_correction = 0.08
const BASE_UPGRADE_DELAY := 1
const MIN_UPGRADE_DELAY := 0.01
const STREAK_THRESHOLD := 1
const MIN_OUTPUT_UPGRADE := 1.15
const DIGIT_BASE_SIZE := 6
const DIGIT_SCALE := 0.5

var gold: int = 10
var meat: int = 10
var wood: int = 10

var heat := 1.8

var time_left := 120.0
var output_floor := 1.0
var output := 1.0
var output_multiplier := 2.0
var knight_set_level := 0
var toughness_level := 0
var timer_speed_multiplier: float = 1.0
var max_knights_per_run: int = 3
var total_knights: int = 1

var current_upgrade_delay := BASE_UPGRADE_DELAY
var upgrade_streak := 0
var upgrade_anim_speed := 1.5
