extends Node

signal battle_finished

enum ACTION_DATA {FUEL_COST, DESCRIPTION, ACTIONS_ARRAY, AFTER_PLAY, ICON}
enum ACTION_ELEMENTS {MOVE_TYPE, VALUE, MOVE_TARGET_AREA, MOVE_INFO}

@onready var player: Node2D = $"../Player"
@onready var enemy: Node2D = $"../Enemy"
@onready var battle_animator = $"../BattleAnimator"

var rng = RandomNumberGenerator.new()

var player_sequence_cassettes = []
var enemy_sequence_cassettes = []

func start_battle(which_boss) -> void:
	await battle_animator.reset_positions_for_battle_start(player, enemy)

	enemy.deck.enemy_deck = Database.get_boss_deck(which_boss)

	await get_tree().create_timer(1).timeout

	draw_initial_hand(player)
	draw_initial_hand(enemy)

	await enemy.ai_controller.select_cassettes_for_sequence()

func draw_initial_hand(actor):
	while actor.hand.player_hand.size() < actor.hand.max_hand_cassettes:
		actor.deck.draw_cassette()
		await get_tree().create_timer(0.2).timeout
	actor.hand.update_hand_positions(actor.hand.DEFAULT_CASSETTE_SPEED)

func _on_commit_sequence_pressed() -> void:
	$"../CommitSequence".disabled = true

	await prepare_participants_sequence_lists()
	await present_mini_cassettes()
	await perform_all_cassettes_actions()
	await clean_up_after_round()
	await wait(1, "After clean_up_after_round")

	draw_cassettes()
	await enemy.ai_controller.select_cassettes_for_sequence()

func prepare_participants_sequence_lists():
	player_sequence_cassettes.clear()
	enemy_sequence_cassettes.clear()

	for slot in player.sequence.get_children():
		player_sequence_cassettes.append(slot.cassette_in_slot)

	for slot in enemy.sequence.get_children():
		enemy_sequence_cassettes.append(slot.cassette_in_slot)

	await wait(1, "After prepare_participants_sequence_lists")

func present_mini_cassettes():
	populate_mini_cassettes(player, player_sequence_cassettes, GlobalEnums.PLAYER)
	populate_mini_cassettes(enemy, enemy_sequence_cassettes, GlobalEnums.ENEMY)
	await wait(1, "After present_mini_cassettes")

func populate_mini_cassettes(actor, cassettes, owner):
	var mini_cassettes = actor.mini_cassette_sequence.get_children()

	for index in range(mini_cassettes.size()):
		var mini_cassette = mini_cassettes[index]
		var original = cassettes[mini_cassettes.size() - 1 - index]

		mini_cassette.visible = true
		mini_cassette.action_data = original.get_current_action()
		mini_cassette.whose_cassette = owner
		mini_cassette.cassette_name.text = original.cassette_name
                mini_cassette.set_cassette_data()


func determine_next_cassette_to_play():
	if player.current_cassette >= 3:
		return GlobalEnums.ENEMY
	elif enemy.current_cassette >= 3:
		return GlobalEnums.PLAYER

	var player_fuel = get_total_fuel_cost(player)
	var enemy_fuel = get_total_fuel_cost(enemy)

	if player_fuel < enemy_fuel:
		return GlobalEnums.PLAYER
	elif enemy_fuel < player_fuel:
		return GlobalEnums.ENEMY
	return GlobalEnums.PLAYER if rng.randi_range(0, 1) == 0 else GlobalEnums.ENEMY

func get_total_fuel_cost(actor) -> int:
	var logic = actor.character_logic
	var current_cassette = actor.sequence.get_children()[actor.current_cassette].cassette_in_slot
	return logic.total_fuel_spent + logic.get_fuel_modifier() + current_cassette.get_current_side_fuel()

func perform_all_cassettes_actions():
	for _i in range(6):
		var next_actor = determine_next_cassette_to_play()
		await perform_cassette_actions(next_actor)
	await wait(1, "All cassettes performed")

func perform_cassette_actions(actor):
	var acting_actor = player if actor == GlobalEnums.PLAYER else enemy
	var target_actor = enemy if actor == GlobalEnums.PLAYER else player
	var logic = acting_actor.character_logic

	var mini_cassette = acting_actor.mini_cassette_sequence.get_children()[2 - acting_actor.current_cassette]
	mini_cassette.highlight_cassette(true)

	if logic.effect_active("next_cassette_wont_work"):
		await battle_animator.play_malfunction_animation(acting_actor)
		logic.remove_status_effect("next_cassette_wont_work")
	else:
		var side_data = acting_actor.sequence.get_children()[acting_actor.current_cassette].cassette_in_slot.get_current_side_data()
		await perform_action(side_data, acting_actor, target_actor)

		logic.update_fuel_spent(side_data[ACTION_DATA.FUEL_COST])

	mini_cassette.highlight_cassette(false)
	acting_actor.current_cassette += 1
	mini_cassette.visible = false

	await wait(1, "After playing cassette")

func perform_action(side_data, character, target):
	for action in side_data[ACTION_DATA.ACTIONS_ARRAY]:
		match action[GlobalEnums.ACTION.MOVE_TYPE]:
			GlobalEnums.ACTION_TYPE.ATTACK:
				await battle_animator.play_attack_animation(character, target, action[ACTION_ELEMENTS.MOVE_INFO])

			GlobalEnums.ACTION_TYPE.MOVE:
				await battle_animator.animate_move_to_position(action[ACTION_ELEMENTS.MOVE_TARGET_AREA])

			GlobalEnums.ACTION_TYPE.SPECIAL:
				await apply_special_effect(action, character, target)

func apply_special_effect(action, character, target):
	var effect_name = action[ACTION_ELEMENTS.MOVE_INFO]
	var effect_data = Database.get_effect(effect_name)

	if effect_data == null:
		push_error("Missing status effect data for: " + effect_name)
		return
#
	#var effect = StatusEffect.new(
		#effect_data[0],
		#map_when_happens_to_duration(effect_data[1]),
		#effect_data[3],
		#effect_name,
		#action[ACTION_ELEMENTS.VALUE]
	#)
#
	#if action[GlobalEnums.SPECIAL.AFFECTED_TARGET] == GlobalEnums.AFFECTED_TARGET.TARGET:
		#target.character_logic.add_status_effect(effect)
	#else:
		#character.character_logic.add_status_effect(effect)
#
	#await battle_animator.play_special_animation(character, effect_data[2])

func map_when_happens_to_duration(when_happens: String) -> int:
	return GlobalEnums.DurationTypes.get(when_happens, GlobalEnums.DurationTypes.THIS_TURN)

func clean_up_after_round():
	player.character_logic.update_turn_effects()
	enemy.character_logic.update_turn_effects()

	for slot in player.sequence.get_children() + enemy.sequence.get_children():
		if slot.cassette_in_slot:
			slot.cassette_in_slot.queue_free()
			slot.cassette_in_slot = null
			slot.set_cover_state(true)

	player_sequence_cassettes.clear()
	enemy_sequence_cassettes.clear()
	player.current_cassette = 0
	enemy.current_cassette = 0

func draw_cassettes():
	draw_initial_hand(player)
	draw_initial_hand(enemy)

func wait(duration: float, description: String):
	await get_tree().create_timer(duration).timeout
	return true
