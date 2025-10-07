class_name StatusEffectManager
extends Node

@onready var player_effects_area = $"../UI/PlayerUI/StatusEffectsArea"
@onready var enemy_effects_area = $"../UI/EnemyUI/StatusEffectsArea"
@onready var player_node = $"../Player"
@onready var enemy_node = $"../Enemy"

var active_effects: Dictionary = {
	GlobalEnums.PLAYER: {
		"this_turn": [],
		"next_turn": [],
		"permanent": [],
		"next_cassette": [],
		"next_attack": []
	},
	GlobalEnums.ENEMY: {
		"this_turn": [],
		"next_turn": [],
		"permanent": [],
		"next_cassette": [],
		"next_attack": []
	}
}

func update_turn_based_status_effects():
	for target in [GlobalEnums.PLAYER, GlobalEnums.ENEMY]:
		for status_effect_node in active_effects[target]["this_turn"]:
			active_effects[target]["this_turn"].remove_at(active_effects[target]["this_turn"].find(status_effect_node)) 
			status_effect_node.queue_free()
		active_effects[target]["this_turn"] = active_effects[target]["next_turn"]
		active_effects[target]["next_turn"] = []

func create_status_effect_element(cassette_action: Dictionary, status_effect_data: Array, effect_target: int) -> void:
	var effect_name = cassette_action.get("effect_name", "")
	if effect_name == "":
		print("Invalid or missing effect name:", effect_name)
		return
	var parent_node = player_effects_area if effect_target == GlobalEnums.PLAYER else enemy_effects_area
	var description_template = status_effect_data[2]
	var value = cassette_action.get("value", 0)
	var description = description_template
	if description_template.find("%s") != -1:
		description = description_template % str(int(value))

	var status_effect = StatusEffect.new()
	status_effect.effect_name = effect_name
	status_effect.icon_name = status_effect_data[0]
	status_effect.description = description
	status_effect.when_active = status_effect_data[1]
	status_effect.value = value
	status_effect.affected_target = cassette_action.get("affected_target", 0)

	var effect_icon_scene = load("res://Features/FightScene/StatusEffects/StatusEffectIcon.tscn")
	var effect_icon_instance = effect_icon_scene.instantiate()
	effect_icon_instance.setup(status_effect)
	add_status_effect(effect_target, effect_icon_instance)
	parent_node.add_child(effect_icon_instance)

func add_status_effect(target: int, status_effect: Node) -> void:
	match status_effect.effect_data.when_active:
		"this_turn":
			active_effects[target]["this_turn"].append(status_effect)
		"next_turn":
			active_effects[target]["next_turn"].append(status_effect)
		"permanent":
			active_effects[target]["permanent"].append(status_effect)
		"next_cassette":
			active_effects[target]["next_cassette"].append(status_effect)
		"next_attack":
			active_effects[target]["next_attack"].append(status_effect)
		_:
			print("Unknown effect timing:", status_effect.effect_data.when_active)
	print("Added effect", status_effect.effect_data.effect_name, "to", target, "under", status_effect.effect_data.when_active)

func get_attack_modifier_for_actor(actor: int) -> float:
	var modifier = 0
	var actor_node = player_node if actor == GlobalEnums.PLAYER else enemy_node
	var possible_effects = active_effects[actor]["this_turn"] + active_effects[actor]["permanent"] + active_effects[actor]["next_attack"] + active_effects[actor]["next_cassette"]
	for effect in possible_effects:
		match effect.effect_data.effect_name:
			"permanent_buff_all_attacks":
				modifier += effect.effect_data.value
			"buff_next_attack":
				modifier += effect.effect_data.value
				find_and_remove_next_cassette_effect(effect, actor)
			"permanent_buff_all_attacks_front":
				if actor_node.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
					modifier += effect.effect_data.value
	var enemy_possible_effects = active_effects[1-actor]["this_turn"] + active_effects[1-actor]["permanent"] + active_effects[1-actor]["next_attack"] + active_effects[1-actor]["next_cassette"]
	for effect in enemy_possible_effects:
		match effect.effect_data.effect_name:
			"this_turn_damage_reduction":
				modifier -= effect.effect_data.value
			"next_attack_damage_reduction":
				modifier -= effect.effect_data.value
				find_and_remove_next_cassette_effect(effect, actor)
	return modifier

func remove_modifiers_after_attack(actor: int) -> void:
	for effect_icon in active_effects[actor]["next_attack"]:
		if effect_icon.effect_data.effect_name == "buff_next_attack":
			active_effects[actor]["next_attack"].remove_at(active_effects[actor]["next_attack"].find(effect_icon))
			effect_icon.queue_free()

func check_if_next_cassette_wont_work(actor: int) -> bool:
	var possible_effects = active_effects[actor]["this_turn"] + active_effects[actor]["permanent"] + active_effects[actor]["next_cassette"]
	for effect in possible_effects:
		if effect.effect_data.effect_name == "next_cassette_wont_work":
			find_and_remove_next_cassette_effect(effect, actor)
			effect.queue_free()
			return true
	return false

func can_move(target_position_key: String, actor: int) -> bool:
	var actor_node = player_node if actor == GlobalEnums.PLAYER else enemy_node
	var possible_effects = active_effects[actor]["this_turn"] + active_effects[actor]["permanent"] + active_effects[actor]["next_cassette"]
	for effect in possible_effects:
		match effect.effect_data.effect_name:
			"next_turn_target_debuff_no_position_change":
				return false
			"less_movement_to_back":
				if target_position_key == "SLOW_DOWN" and actor_node.battle_position == GlobalEnums.BATTLE_POSITIONS.LINE_UP:
					return false
	return true

func reduce_from_slow_down_to_line_up(actor: int) -> bool:
	var possible_effects = active_effects[actor]["this_turn"] + active_effects[actor]["permanent"] + active_effects[actor]["next_cassette"]
	for effect in possible_effects:
		if effect.effect_data.effect_name == "less_movement_to_back":
			return true
	return false

func can_attack(actor: int) -> bool:
	# var actor_node = player_node if actor == GlobalEnums.PLAYER else enemy_node
	var possible_effects = active_effects[actor]["this_turn"] + active_effects[actor]["permanent"] + active_effects[actor]["next_cassette"]
	for effect in possible_effects:
		if effect.effect_data.effect_name == "this_turn_next_attack_or_debuff_wont_work":
			active_effects[actor]["this_turn"].remove_at(active_effects[actor]["this_turn"].find(effect))
			effect.queue_free()
			return false
	return true

func find_and_remove_next_cassette_effect(effect_to_remove: Node, actor: int) -> void:
	for effect_type in active_effects[actor].values():
		var index = effect_type.find(effect_to_remove)
		if index != -1:
			effect_type.remove_at(index)
			return

func can_resist_attack(actor: int) -> bool:
	var defender_node = player_node if actor == GlobalEnums.PLAYER else enemy_node
	var defender = GlobalEnums.PLAYER if actor == GlobalEnums.ENEMY else GlobalEnums.ENEMY

	var possible_effects = active_effects[defender]["this_turn"] + active_effects[defender]["permanent"] + active_effects[defender]["next_cassette"]
	for effect in possible_effects:
		match effect.effect_data.effect_name:
			"this_turn_avoid_side_attacks":
				if defender_node.battle_position == GlobalEnums.BATTLE_POSITIONS.LINE_UP:
					return true
			"this_turn_avoid_front_attacks":
				if defender_node.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
					return true
	return false
