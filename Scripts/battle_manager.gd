extends Node

signal battle_finished

enum BATTLE_POSITION_PARAMS {POSITION, SCALE, ROTATION}
enum ACTION_DATA {FUEL_COST, DESCRIPTION, ACTIONS_ARRAY, AFTER_PLAY}
enum ACTION_ELEMENTS {MOVE_TYPE, VALUE, MOVE_TARGET_AREA, MOVE_INFO}
const SLOW_DOWN = [Vector2(621,478), Vector2(0.27, 0.27),-7]
const OVERTAKE = [Vector2(860, 451), Vector2(0.5,0.5),-3]
const LINE_UP_PLAYER = [Vector2(648,492), Vector2(0.5,0.5),-4]
const LINE_UP_ENEMY = [Vector2(1015,423), Vector2(0.5,0.5),-3]
const BATTLE_SPEED = 1

@onready var player: Node2D = $"../Player"
@onready var enemy: Node2D = $"../Enemy"

@onready var global_timer: Timer = $"../GlobalTimer"
@onready var cassette_database_reference= CassetteDatabase

var rng

var player_sequence_cassettes = []
var enemy_sequence_cassettes = []

func start_battle(which_boss) -> void:
	player.battle_sprite.position = SLOW_DOWN[BATTLE_POSITION_PARAMS.POSITION]
	player.battle_sprite.scale = SLOW_DOWN[BATTLE_POSITION_PARAMS.SCALE]
	player.battle_sprite.rotation_degrees = SLOW_DOWN[BATTLE_POSITION_PARAMS.ROTATION]
	player.battle_sprite.z_index = 0
	
	enemy.battle_sprite.position = OVERTAKE[BATTLE_POSITION_PARAMS.POSITION]
	enemy.battle_sprite.scale = OVERTAKE[BATTLE_POSITION_PARAMS.SCALE]
	enemy.battle_sprite.rotation_degrees = OVERTAKE[BATTLE_POSITION_PARAMS.ROTATION]
	enemy.deck.enemy_deck = CassetteDatabase.boss_decks[which_boss]
	
	await get_tree().create_timer(1).timeout
	for i in range(len(player.hand.player_hand), player.hand.max_hand_cassettes):
		player.deck.draw_cassette()
		await get_tree().create_timer(0.2).timeout
	player.hand.update_hand_positions(player.hand.DEFAULT_CASSETTE_SPEED)
	for i in range(len(enemy.hand.enemy_hand), enemy.hand.max_hand_cassettes):
		enemy.deck.draw_cassette()
	enemy.select_cassettes_for_sequence()

func _on_commit_sequence_pressed() -> void:
	$"../CommitSequence".disabled = true
	var wait_completed = await prepare_participants_sequence_lists()
	wait_completed = await present_mini_cassettes()
	wait_completed = await perform_all_cassettes_actions()
	wait_completed = await clean_up_after_round()
	wait_completed = await wait(BATTLE_SPEED,"After clean_up_after_round")
	draw_cassettes()
	wait_completed = await enemy.select_cassettes_for_sequence()


func prepare_participants_sequence_lists():
	for cassette_slot in player.sequence.get_children():
		player_sequence_cassettes.append(cassette_slot.cassette_in_slot)
	for cassette_slot in enemy.sequence.get_children():
		enemy_sequence_cassettes.append(cassette_slot.cassette_in_slot)
	var wait_completed = await wait(BATTLE_SPEED,"After prepare_participants_sequence_lists")
	
	
func present_mini_cassettes():
	var mini_cassettes = player.mini_cassette_sequence.get_children()
	for index in len(mini_cassettes):
		var current_mini_cassette = mini_cassettes[index]
		current_mini_cassette.visible = true
		var original_cassette = player_sequence_cassettes[len(mini_cassettes)-1-index]
		current_mini_cassette.action_data = original_cassette.get_current_action()
		current_mini_cassette.whose_cassette = "player"
		current_mini_cassette.cassette_name.text = original_cassette.cassette_name
		current_mini_cassette.set_cassette_data(current_mini_cassette.player_icons)
	mini_cassettes[len(mini_cassettes)-1].set_icons_visibility()

	mini_cassettes = enemy.mini_cassette_sequence.get_children()
	for index in len(mini_cassettes):
		var current_mini_cassette = mini_cassettes[index]
		current_mini_cassette.visible = true
		var original_cassette = enemy.sequence.get_children()[len(mini_cassettes)-1-index].cassette_in_slot
		current_mini_cassette.action_data = original_cassette.get_current_action()
		current_mini_cassette.whose_cassette = "enemy"
		current_mini_cassette.cassette_name.text = original_cassette.cassette_name
		current_mini_cassette.set_cassette_data(current_mini_cassette.enemy_icons)
	mini_cassettes[len(mini_cassettes)-1].set_icons_visibility()
	var wait_completed = await wait(BATTLE_SPEED,"After prepare_participants_sequence_lists")


func determine_next_cassette_to_play():
	var whose_cassette = ""
	if player.current_cassette == 3:
		whose_cassette = "enemy"
	elif enemy.current_cassette == 3:
		whose_cassette = "player"
	else:
		var next_player_casssette = player_sequence_cassettes[player.current_cassette]
		var next_enemy_casssette = enemy_sequence_cassettes[enemy.current_cassette]
		if next_player_casssette.get_current_side_fuel()+player.total_fuel_spent+player.get_fuel_modifier() < \
		next_enemy_casssette.get_current_side_fuel()+enemy.total_fuel_spent+enemy.get_fuel_modifier():
			whose_cassette = "player"
		elif next_player_casssette.get_current_side_fuel()+player.total_fuel_spent+player.get_fuel_modifier() > \
		next_enemy_casssette.get_current_side_fuel()+enemy.total_fuel_spent+enemy.get_fuel_modifier():
			whose_cassette = "enemy"
		else:
			var coin_result = toss_a_coin()
			if coin_result == 0:
				whose_cassette = "player"
			else:
				whose_cassette = "enemy"
	return whose_cassette


func perform_all_cassettes_actions():
	var amount_of_actions = len(player.sequence.get_children())+len(enemy.sequence.get_children())
	for x in range(0,amount_of_actions):
		var next_cassette_owner = determine_next_cassette_to_play()
		var wait_perform_completed = await perform_cassette_actions(next_cassette_owner)
	var wait_completed = await wait(BATTLE_SPEED, "all cassettes performed")
	if wait_completed:
		return true
		

func toss_a_coin(): #To your Witcher
	var roll = RandomNumberGenerator.new()
	roll.randomize()
	return roll.randi_range(0,1)

func perform_cassette_actions(actor):
	var played_cassette
	var acting_actor
	var target
	if actor == "player":
		played_cassette = player_sequence_cassettes[player.current_cassette]
		acting_actor = player
		target = enemy
		
	else:
		played_cassette = enemy_sequence_cassettes[enemy.current_cassette]
		acting_actor = enemy
		target = player
	var minicassettes = acting_actor.mini_cassette_sequence.get_children()
	var minicassette = minicassettes[len(minicassettes)-1-acting_actor.current_cassette]
	minicassette.highlight_cassette(true)
	if acting_actor.is_next_cassette_wont_work():
		minicassette.animation_player.play("malfunction")
		await wait(1,"waiting for malfunction to finish")
		acting_actor.remove_debuff("next_cassette_wont_work")
	else:
		var action = played_cassette.get_current_action()
		await perform_action(action,acting_actor,target)
	minicassette.highlight_cassette(false)
	if played_cassette.get_current_action()[played_cassette.CASSETTE_SIDE_DATA.AFTER_PLAY] == "discard":
		acting_actor.discard.discarded_cassettes.append(played_cassette)
	if acting_actor.current_cassette < 2:
		acting_actor.mini_cassette_sequence.get_children()[len(minicassettes)-1-acting_actor.current_cassette-1].set_icons_visibility()
	acting_actor.current_cassette += 1
	acting_actor.update_total_fuel_spent(played_cassette.get_current_side_fuel())
	minicassette.visible = false
	var wait_completed = await wait(BATTLE_SPEED, "After playing cassette")
	return true


func perform_action(action_data, character, target):
	for action in action_data[ACTION_DATA.ACTIONS_ARRAY]:
		# action = [MOVE_TYPE, VALUE, MOVE_TARGET_AREA, (optional)MOVE_INFO]
		if action[ACTION_ELEMENTS.MOVE_TYPE] == "attack":
			if !check_if_in_correct_position(action[ACTION_ELEMENTS.MOVE_TARGET_AREA],target) or \
			target.is_buff_avoids_attacks(action[ACTION_ELEMENTS.MOVE_TARGET_AREA]) or \
			character.is_next_attack_wont_work(action[ACTION_ELEMENTS.MOVE_TARGET_AREA]):
				character.animation_player.play(get_attack_animation_name(action[ACTION_ELEMENTS.MOVE_INFO],target)+"_miss")
				await wait(2,"waiting for attack_miss to finish")
			else:
				var animation_name = get_attack_animation_name(action[ACTION_ELEMENTS.MOVE_INFO],target)
				character.animation_player.play(animation_name)
				await wait(2,"waiting for ram_side to finish")
				var attacker_modifier = character.get_attacker_damage_modifier()
				var target_modifier = target.get_target_damage_modifier()
				var damage_dealt = action[ACTION_ELEMENTS.VALUE] + attacker_modifier + target_modifier
				if damage_dealt < 0:
					damage_dealt = 0
				target.life -= int(action[ACTION_ELEMENTS.VALUE])
				var tween = get_tree().create_tween()
				tween.tween_property(target.get_node("PortraitArea/LifeGauge"), 'value', target.life, 0.5)
				await tween.finished
				target.get_node("PortraitArea/Label").text = "HP: " + str(target.life)
			character.remove_de_buffs_from_list(character.next_attack_buffs)
		if action[ACTION_ELEMENTS.MOVE_TYPE] == "move":
			if character.is_move_action_wont_work():
				character.animation_player.play("getting_debuff")
			else:
				if action[ACTION_ELEMENTS.MOVE_TARGET_AREA] == "slow_down":
					if character == player:
						await slow_down()
					else:
						await overtake()
				elif action[ACTION_ELEMENTS.MOVE_TARGET_AREA] == "line_up":
					line_up()
				elif action[ACTION_ELEMENTS.MOVE_TARGET_AREA] == "overtake":
					if character == player:
						await overtake()
					else:
						await slow_down()
		if action[ACTION_ELEMENTS.MOVE_TYPE] == "defence":
			pass
		if action[ACTION_ELEMENTS.MOVE_TYPE] == "special":
			match action[ACTION_ELEMENTS.MOVE_INFO]:
				"next_cassette_wont_work",\
				"next_turn_target_debuff_no_position_change",\
				"this_turn_target_attacks_behind_wont_work",\
				"next_card_target_costs_more_fuel",\
				"next_turn_enemy_actions_cost_more_fuel":
					if check_if_in_correct_position(action[ACTION_ELEMENTS.MOVE_TARGET_AREA],target):
						target.animation_player.play("getting_debuff")
						target.add_debuff(CassetteDatabase.DEBUFFS[action[ACTION_ELEMENTS.MOVE_INFO]])
				"this_turn_you_avoid_side_attacks",\
				"buff_all_attacks",\
				"buff_all_attacks_2",\
				"buff_next_attack",\
				"this_turn_attacks_in_front_wont_work",\
				"next_turn_first_action_cost_less_if_you_start_in_slow_down",\
				"next_cassette_cost_less",\
				"next_turn_cassettes_cost_less_if_you_stay_in_slow_down",\
				"this_turn_cassettes_cost_less",\
				"this_turn_damage_reduction_back_3",\
				"this_turn_damage_reduction_front_2",\
				"this_turn_damage_reduction_front_3",\
				"this_turn_damage_reduction_side_2",\
				"this_turn_damage_reduction_side_3",\
				"next_attack_damage_reduction_any_side_2",\
				"next_attack_damage_reduction_any_side_4":
					character.animation_player.play("getting_buff")
					character.add_buff(CassetteDatabase.BUFFS[action[ACTION_ELEMENTS.MOVE_INFO]])
				"attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides":
					var animation_name = get_attack_animation_name("shoot",target)
					character.animation_player.play(animation_name)
					await wait(2,"waiting for ram_side to finish")
					var attacker_modifier = character.get_attacker_damage_modifier()
					var target_modifier = target.get_target_damage_modifier()
					var damage_dealt = action[ACTION_ELEMENTS.VALUE] + attacker_modifier + target_modifier + character.total_fuel_spent
					if damage_dealt < 0:
						damage_dealt = 0
					target.life -= int(action[ACTION_ELEMENTS.VALUE])
					var tween = get_tree().create_tween()
					tween.tween_property(target.get_node("PortraitArea/LifeGauge"), 'value', target.life, 0.5)
					await tween.finished
					target.get_node("PortraitArea/Label").text = "HP: " + str(target.life)
	if character.life < 0 or target.life < 0:
		battle_finished.emit()
	return true

func check_if_in_correct_position(position_name,target):
	match target.battle_position:
		GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			if "back" in position_name or position_name == "all_sides":
				return true
		GlobalEnums.BATTLE_POSITIONS.LINE_UP:
			if "side" in position_name or position_name == "all_sides":
				return true
		GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
			if "front" in position_name or position_name == "all_sides":
				return true
	return false
			
		
func clean_up_after_round():
	for cassette_slot in player.sequence.get_children():
		var current_cassette = cassette_slot.cassette_in_slot
		cassette_slot.remove_child(current_cassette)
		if cassette_slot.cassette_in_slot.get_current_action()[current_cassette.CASSETTE_SIDE_DATA.AFTER_PLAY] == "discard":
			player.discard.add_child(current_cassette)
			current_cassette.visible = false
		else:
			player.lost.add_child(current_cassette)
			current_cassette.visible = false
		cassette_slot.cassette_in_slot = null
		cassette_slot.set_cover_state(true)
		cassette_slot.update_elements(false,"", "")
		
	for cassette_slot in enemy.sequence.get_children():
		cassette_slot.remove_child(cassette_slot.cassette_in_slot)
		if cassette_slot.cassette_in_slot.get_current_action()[cassette_slot.cassette_in_slot.CASSETTE_SIDE_DATA.AFTER_PLAY] == "discard":
			enemy.discard.add_child(cassette_slot.cassette_in_slot)
		else:
			enemy.lost.add_child(cassette_slot.cassette_in_slot)
		cassette_slot.cassette_in_slot = null
		cassette_slot.set_cover_state(true)
	for cassette in player.mini_cassette_sequence.get_children():
		cassette.visible = false
		cassette.action_data = []
		cassette.whose_cassette = null
	for cassette in enemy.mini_cassette_sequence.get_children():
		cassette.visible = false
		cassette.action_data = []
		cassette.whose_cassette = null
	player_sequence_cassettes = []
	enemy_sequence_cassettes = []
	player.current_cassette = 0
	player.total_fuel_spent = 0
	player.total_fuel_spent_label.text = str(0)
	player.update_current_turn_debuffs()
	enemy.current_cassette = 0
	enemy.total_fuel_spent = 0
	enemy.total_fuel_spent_label.text = str(0)
	enemy.update_current_turn_debuffs()
	return true



func draw_cassettes():
	for i in range(len(player.hand.get_children()),5):
		player.deck.draw_cassette()
		player.deck.update_deck_positions(player.deck.CASSETTE_DRAW_SPEED)
	for i in range(len(enemy.hand.get_children()),5):
		enemy.deck.draw_cassette()


func slow_down():
	var speed = 2
	if player.battle_position == GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
		speed = 1.5
		await line_up(speed)
	var tweener = create_tween()
	tweener.tween_property(player.battle_sprite, "position", SLOW_DOWN[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "scale", SLOW_DOWN[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "rotation_degrees", SLOW_DOWN[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "z_index", 0, speed).set_trans(Tween.TRANS_CUBIC)
	tweener.parallel().tween_property(enemy.battle_sprite, "position", OVERTAKE[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "scale", OVERTAKE[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "rotation_degrees", OVERTAKE[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	player.battle_position = GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN
	enemy.battle_position = GlobalEnums.BATTLE_POSITIONS.OVERTAKE
	await wait(speed, "waiting for slow down")
	return true

func overtake():
	var speed = 2
	if player.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
		speed = 1.5
		await line_up(speed)
	var tweener = create_tween()
	tweener.tween_property(player.battle_sprite, "position", OVERTAKE[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "scale", OVERTAKE[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "rotation_degrees", OVERTAKE[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "z_index", 1, speed).set_trans(Tween.TRANS_CUBIC)
	tweener.parallel().tween_property(enemy.battle_sprite, "position", SLOW_DOWN[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "scale", SLOW_DOWN[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "rotation_degrees", SLOW_DOWN[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	
	player.battle_position = GlobalEnums.BATTLE_POSITIONS.OVERTAKE
	enemy.battle_position = GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN
	await wait(speed, "waiting for overtake")
	return true

func line_up(speed=2):
	var tweener = create_tween()
	tweener.tween_property(player.battle_sprite, "position", LINE_UP_PLAYER[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "scale", LINE_UP_PLAYER[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "rotation_degrees", LINE_UP_PLAYER[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(player.battle_sprite, "z_index", 1, speed).set_trans(Tween.TRANS_CUBIC)
	tweener.parallel().tween_property(enemy.battle_sprite, "position", LINE_UP_ENEMY[BATTLE_POSITION_PARAMS.POSITION], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "scale", LINE_UP_ENEMY[BATTLE_POSITION_PARAMS.SCALE], speed).set_trans(Tween.TRANS_QUART)
	tweener.parallel().tween_property(enemy.battle_sprite, "rotation_degrees", LINE_UP_ENEMY[BATTLE_POSITION_PARAMS.ROTATION], speed).set_trans(Tween.TRANS_QUART)
	player.battle_position = GlobalEnums.BATTLE_POSITIONS.LINE_UP
	enemy.battle_position = GlobalEnums.BATTLE_POSITIONS.LINE_UP
	await wait(speed, "waiting for lineup")
	return true



func wait(duration, wait_name):
	print("BEFORE WAITING 2 SECONDS AFTER: "+ wait_name)
	await get_tree().create_timer(duration).timeout
	print("2 SECONDS PASSED AFTER: "+ wait_name)
	return true
	

func get_attack_animation_name(move_type, target):
	if target.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
		return move_type+"_back"
	if target.battle_position == GlobalEnums.BATTLE_POSITIONS.LINE_UP:
		return move_type+"_side"
	if target.battle_position == GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
		return move_type+"_front"
