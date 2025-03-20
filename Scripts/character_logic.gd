# CharacterLogic.gd  
# Handles all data-related operations for status effects, shared by both Player and Enemy.
extends Node

const BattlePositions = GlobalEnums.BATTLE_POSITIONS
const DurationType = GlobalEnums.DurationType
const StatusEffectDurations = {
	DurationType.NEXT_TURN: "during_next_turn",
	DurationType.NEXT_CARD: "during_next_cassette",
	DurationType.NEXT_ACTION: "during_next_action",
	DurationType.NEXT_ATTACK: "during_next_attack",
	DurationType.PERMANENT: "permanent",
	DurationType.THIS_TURN: "this_turn"
}

signal status_effect_added(effect: StatusEffect)
signal status_effect_removed(effect: StatusEffect)

var battle_position = BattlePositions.LINE_UP
var life: int = 20
var total_fuel_spent: int = 0

var status_effects = {}

func _ready():
	for key in StatusEffectDurations.values():
		status_effects[key] = []

func add_status_effect(effect: StatusEffect):
	var key = get_duration_key(effect.duration_type)
	if status_effects.has(key):
		status_effects[key].append(effect)
		status_effect_added.emit(effect)

func remove_status_effect(identifier: String):
	for effect_list in status_effects.values():
		for i in range(effect_list.size()):
			if effect_list[i].effect_identifier == identifier:
				var removed_effect = effect_list[i]
				effect_list.remove(i)
				status_effect_removed.emit(removed_effect)
				return

func effect_active(identifier: String) -> bool:
	for effect_list in status_effects.values():
		for effect in effect_list:
			if effect.effect_identifier == identifier:
				return true
	return false

func update_fuel_spent(value: int):
	total_fuel_spent += value

func update_turn_effects():
	move_effects(DurationType.NEXT_TURN, DurationType.THIS_TURN)
	remove_expired_effects(DurationType.THIS_TURN)

func move_effects(from_duration: int, to_duration: int):
	var from_key = get_duration_key(from_duration)
	var to_key = get_duration_key(to_duration)
	if status_effects.has(from_key) and status_effects.has(to_key):
		var effects_to_move = status_effects[from_key].duplicate()
		status_effects[from_key].clear()
		status_effects[to_key] += effects_to_move

func remove_expired_effects(duration: int):
	var key = get_duration_key(duration)
	if status_effects.has(key):
		for effect in status_effects[key]:
			status_effect_removed.emit(effect)
		status_effects[key].clear()

func get_modifier(identifiers: Array, multiplier: int = 1) -> int:
	var modifier = 0
	for effect_list in status_effects.values():
		for effect in effect_list:
			if effect.effect_identifier in identifiers:
				modifier += effect.value * multiplier
	return modifier

func get_attacker_damage_modifier() -> int:
	return get_modifier(["buff_all_attacks", "buff_all_attacks_2", "buff_next_attack"])

func get_target_damage_modifier() -> int:
	var position_effects = {
		BattlePositions.OVERTAKE: ["this_turn_damage_reduction_back_3"],
		BattlePositions.LINE_UP: ["this_turn_damage_reduction_side_2", "this_turn_damage_reduction_side_3"],
		BattlePositions.SLOW_DOWN: ["this_turn_damage_reduction_front_2", "this_turn_damage_reduction_front_3"]
	}

	var base_modifier = get_modifier(position_effects.get(battle_position, []), -1)
	var additional_modifier = get_modifier(["next_attack_damage_reduction_any_side_2", "next_attack_damage_reduction_any_side_4"], -1)
	return base_modifier + additional_modifier

func get_fuel_modifier() -> int:
	return get_modifier(["next_card_target_costs_more_fuel", "next_turn_enemy_actions_cost_more_fuel"]) - get_modifier(["this_turn_cassettes_cost_less"])

func get_duration_key(duration: int) -> String:
	return StatusEffectDurations.get(duration, "this_turn")
