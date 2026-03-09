class_name ActionStation

extends Node

enum ActionType {
	IDLE,
	ATTACK,
	BLOCK,
	FORAGE,
}

var game_state: GameState
var visual_station: VisualStation
var upgrade_station: UpgradeStation
var last_action: ActionType = ActionType.IDLE
var current_action: ActionType

var actions := {
	ActionType.ATTACK: {
		"animation": "attack",
		"resource": "gold",
	},
	ActionType.FORAGE: {
		"animation": "forage",
		"resource": "meat",
	},
	ActionType.BLOCK: {
		"animation": "block",
		"resource": "wood",
	},
}

func setup(state: GameState, up_station: UpgradeStation, visu_station: VisualStation):
	game_state = state
	upgrade_station = up_station
	visual_station = visu_station
