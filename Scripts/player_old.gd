extends Node2D

const DEBUFF_SCENE_PATH = "res://Scenes/StatusEffectIcon.tscn"

#enum BATTLE_POSITIONS {SLOW_DOWN, LINE_UP, OVERTAKE}
enum DE_BUFF {DEBUFF_NAME, ICON_NAME, WHEN_ACTIVE, ANIMATION_TO_PLAY, DESCRIPTION, VALUE}

var battle_position =  GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN
var life = 20
var current_cassette = 0
var total_fuel_spent = 0
var next_turn_debuffs = []
var this_turn_debuffs = []
var next_cassette_debuffs = []
var next_attack_debuffs = []
var permanent_debuffs = []
var next_turn_buffs = []
var this_turn_buffs = []
var next_cassette_buffs = []
var next_attack_buffs = []
var permanent_buffs = []
var debuffs = [this_turn_debuffs, next_cassette_debuffs, permanent_debuffs, next_attack_debuffs]
var buffs = [this_turn_buffs, next_cassette_buffs, permanent_buffs, next_attack_buffs]
var new_buffs = []
var new_debuffs = []


@onready var deck: Node2D = $Deck
@onready var portrait_area: Node2D = $PortraitArea
@onready var sequence: Node2D = $Sequence
@onready var hand: Node2D = $Hand
@onready var discard: Node2D = $Discard
@onready var lost: Node2D = $Lost
@onready var battle_sprite: Node2D = $BattleSprite
@onready var life_label: Label = $PortraitArea/Label
@onready var life_gauge: TextureProgressBar = $PortraitArea/LifeGauge
@onready var mini_cassette_sequence: Node2D = $MiniCassetteSequence
@onready var animation_player: AnimationPlayer = $BattleSprite/AnimationPlayer
@onready var buff_debuff_area: GridContainer = $BuffDebuffArea
@onready var total_fuel_spent_label: Label = $"../FuelSpent/Sprite2D/FuelSpent"


func add_debuff(debuff_data):
	var icon_scene = preload(DEBUFF_SCENE_PATH)
	var debuff_object = icon_scene.instantiate()
	debuff_object.de_buff_data = debuff_data
	buff_debuff_area.add_child(debuff_object)
	debuff_object.name = debuff_data[DE_BUFF.DEBUFF_NAME]
	match debuff_object.de_buff_data[DE_BUFF.WHEN_ACTIVE]:
		"next_cassette":
			next_cassette_debuffs.append(debuff_object)
		"next_turn":
			next_turn_debuffs.append(debuff_object)
		"this_turn":
			this_turn_debuffs.append(debuff_object)
		"next_attack":
			next_attack_debuffs.append(debuff_object)
	debuff_object.set_icon()
	debuff_object.set_tooltip()

func add_buff(buff_data):
	var icon_scene = preload(DEBUFF_SCENE_PATH)
	var buff_object = icon_scene.instantiate()
	buff_object.de_buff_data = buff_data
	buff_debuff_area.add_child(buff_object)
	match buff_object.de_buff_data[DE_BUFF.WHEN_ACTIVE]:
		"next_cassette":
			next_cassette_buffs.append(buff_object)
		"next_turn":
			next_turn_buffs.append(buff_object)
		"this_turn":
			this_turn_buffs.append(buff_object)
		"next_attack":
			next_attack_buffs.append(buff_object)
	buff_object.set_icon()
	buff_object.set_tooltip()


func remove_debuff(debuff_name):
	for debuff_list in debuffs:
		for debuff in debuff_list:
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == debuff_name:
				buff_debuff_area.remove_child(debuff)
				debuff_list.erase(debuff)
				debuff.queue_free()


func remove_de_buffs_from_list(list_element):
	for de_buff in list_element:
		buff_debuff_area.remove_child(de_buff)
		list_element.erase(de_buff)
		de_buff.queue_free()


func update_total_fuel_spent(new_cassette_value):
	total_fuel_spent += new_cassette_value
	total_fuel_spent_label.text = str(total_fuel_spent)


func is_next_cassette_wont_work():
	for debuff_list in debuffs:
		for debuff in debuff_list:
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_cassette_wont_work":
				return true
	return false


func is_next_attack_wont_work(attack_target_area):
	for debuff_list in debuffs:
		for debuff in debuff_list:
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_target_attacks_behind_wont_work":
				if attack_target_area == "back":
					return true
	return false


func is_move_action_wont_work():
	for debuff_list in debuffs:
		for debuff in debuff_list:
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_turn_target_debuff_no_position_change":
				return true
	return false


func is_buff_avoids_attacks(attack_target_area):
	for buff_list in buffs:
		for buff in buff_list:
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_you_avoid_side_attacks":
				if attack_target_area == "side":
					return true
	return false


func update_current_turn_debuffs():
	for debuff in this_turn_debuffs:
		this_turn_debuffs.erase(debuff)
		debuff.queue_free()
	for debuff in next_turn_debuffs:
		next_turn_debuffs.erase(debuff)
		this_turn_debuffs.append(debuff)
	for buff in next_turn_buffs:
		next_turn_buffs.erase(buff)
		if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_turn_first_action_cost_less_if_you_start_in_slow_down" and battle_position ==  GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			var new_buff = add_buff(CassetteDatabase.BUFFS["next_cassette_cost_less"])
			this_turn_buffs.append(new_buff)
		elif buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_turn_cassettes_cost_less_if_you_stay_in_slow_down" and battle_position ==  GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			var new_buff = add_buff(CassetteDatabase.BUFFS["this_turn_cassettes_cost_less"])
			this_turn_buffs.append(new_buff)
		else:
			this_turn_buffs.append(buff)
			


func get_attacker_damage_modifier():
	var current_modifier = 0
	for buff_list in buffs:
		for buff in buff_list:
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "buff_all_attacks" or \
			buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "buff_all_attacks_2" or \
			buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "buff_next_attack":
				current_modifier += buff.de_buff_data[DE_BUFF.VALUE]
	return current_modifier


func get_target_damage_modifier():
	var current_modifier = 0
	for debuff_list in debuffs:
		for debuff in debuff_list:
			pass
	for buff_list in buffs:
		for buff in buff_list:
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_damage_reduction_back_3":
				if battle_position ==  GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
					current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_damage_reduction_side_3":
				if battle_position ==  GlobalEnums.BATTLE_POSITIONS.LINE_UP:
					current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_damage_reduction_side_2":
				if battle_position ==  GlobalEnums.BATTLE_POSITIONS.LINE_UP:
					current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_damage_reduction_front_2":
				if battle_position ==  GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
					current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_damage_reduction_front_3":
				if battle_position ==  GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
					current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_attack_damage_reduction_any_side_2":
				current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_attack_damage_reduction_any_side_4":
				current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
	return current_modifier


func get_fuel_modifier():
	var current_modifier = 0
	for debuff_list in debuffs:
		for debuff in debuff_list:
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_card_target_costs_more_fuel":
				current_modifier += debuff.de_buff_data[DE_BUFF.VALUE]
			if debuff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "next_turn_enemy_actions_cost_more_fuel":
				current_modifier += debuff.de_buff_data[DE_BUFF.VALUE]
	for buff_list in buffs:
		for buff in buff_list:
			if buff.de_buff_data[DE_BUFF.DEBUFF_NAME] == "this_turn_cassettes_cost_less":
				current_modifier -= buff.de_buff_data[DE_BUFF.VALUE]
	return current_modifier
