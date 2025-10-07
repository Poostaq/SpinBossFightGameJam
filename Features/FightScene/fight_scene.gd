extends Node

@onready var player: Node = %Player
@onready var enemy: Node = $"Enemy"
@onready var ui_animator = $"UIAnimator"

@onready var player_ui = $"UI/PlayerUI"
@onready var enemy_ui = $"UI/EnemyUI"
@onready var cassette_manager: Node2D = %CassetteManager
@onready var eject_button = $"UI/PlayerUI/EjectButton"
@onready var commit_button = $"UI/PlayerUI/CommitSequence"
@onready var player_effects_area = $UI/PlayerUI/StatusEffectsArea
@onready var enemy_effects_area = $UI/EnemyUI/StatusEffectsArea
@onready var status_effect_manager = $StatusEffectManager




func _ready():
	print("Starting the fight")
	player.prepare_hand()	
	enemy.prepare_hand("hound")
	await ui_animator.battle_ui_preparation()
	start_selection_phase()

func start_selection_phase():
	cassette_manager.set_disabled_for_all_cassettes_in_hand(false)
	enemy.select_cassettes_for_sequence()
	disable_eject_button(false)


func disable_commit_button(disabled: bool):
	commit_button.disabled = disabled


func disable_eject_button(disabled: bool):
	eject_button.disabled = disabled


func _on_commit_sequence_pressed() -> void:
	print("[BattleManager] Commit pressed!")
	ui_animator.close_slots()
	ui_animator.close_enemy_slots()
	cassette_manager.set_disabled_for_all_cassettes_in_hand(true)
	disable_commit_button(true)
	disable_eject_button(true)
	start_acting_phase()


func start_acting_phase():
	await ui_animator.present_mini_cassettes()
	await get_tree().create_timer(0.8).timeout

	var current_player_cassette = 0
	var current_enemy_cassette = 0

	for i in range(6):
		if current_player_cassette == 3 and current_enemy_cassette != 3:
			var minicassette = ui_animator.enemy_mini_cassettes[current_enemy_cassette]
			await ui_animator.animate_next_cassette(minicassette, GlobalEnums.ENEMY)
			await perform_cassette_actions(minicassette, GlobalEnums.ENEMY)
			current_enemy_cassette += 1
		elif current_enemy_cassette == 3 and current_player_cassette != 3:
			var minicassette = ui_animator.player_mini_cassettes[current_player_cassette]
			await ui_animator.animate_next_cassette(minicassette, GlobalEnums.PLAYER)
			await perform_cassette_actions(minicassette, GlobalEnums.PLAYER)
			current_player_cassette += 1
		else:
			var player_minicassette = ui_animator.player_mini_cassettes[current_player_cassette]
			var enemy_minicassette = ui_animator.enemy_mini_cassettes[current_enemy_cassette]
			var winner = get_winner_for_next_cassette_comparison(player_minicassette, enemy_minicassette)
			await ui_animator.enlarge_cassettes_for_comparison(player_minicassette, enemy_minicassette)

			var player_fuel_original_pos = player_minicassette.fuel_icon.global_position
			var enemy_fuel_original_pos = enemy_minicassette.fuel_icon.global_position

			await ui_animator.compare_mini_cassette_fuel(
				player_minicassette,
				enemy_minicassette,
				winner,
				player_fuel_original_pos,
				enemy_fuel_original_pos
			)

			var winner_minicassette = player_minicassette if winner == GlobalEnums.PLAYER else enemy_minicassette
			await perform_cassette_actions(winner_minicassette, winner)
			await ui_animator.restore_and_hide_winning_minicassette(
				winner_minicassette,
				winner,
				player_fuel_original_pos,
				enemy_fuel_original_pos
			)

			if winner == GlobalEnums.PLAYER:
				player.fuel_spent_this_turn += player_minicassette.fuel_label.text.to_int()
				current_player_cassette += 1
				if current_player_cassette < 3:
					ui_animator.player_mini_cassettes[current_player_cassette].show_icons()
			else:
				enemy.fuel_spent_this_turn += enemy_minicassette.fuel_label.text.to_int()
				current_enemy_cassette += 1
				if current_enemy_cassette < 3:
					ui_animator.enemy_mini_cassettes[current_enemy_cassette].show_icons()

			await get_tree().create_timer(0.8 / SettingsManager.battle_speed).timeout
	await get_tree().create_timer(1.0 / SettingsManager.battle_speed).timeout
	clean_up_after_turn()


func get_winner_for_next_cassette_comparison(player_cassette: Node, enemy_cassette: Node) -> int:
	var player_fuel_amount = int(player_cassette.fuel_label.text)
	var enemy_fuel_amount = int(enemy_cassette.fuel_label.text)
	var player_counter_amount = player.fuel_spent_this_turn
	var enemy_counter_amount = enemy.fuel_spent_this_turn
	if player_fuel_amount+player_counter_amount < enemy_fuel_amount+enemy_counter_amount:
		return GlobalEnums.PLAYER
	elif enemy_fuel_amount+enemy_counter_amount < player_fuel_amount+player_counter_amount:
		return GlobalEnums.ENEMY
	else:
		return GlobalEnums.PLAYER


func perform_cassette_actions(cassette: Node, whose_cassette: int) -> void:
	var actor_node = player if whose_cassette == GlobalEnums.PLAYER else enemy
	var target_node = enemy if whose_cassette == GlobalEnums.PLAYER else player
	print("Performing actions for cassette %s" % [cassette.original_cassette.cassette_name])
	var side_data = cassette.original_cassette.get_current_side_data()
	var actor_car = $"CarLayer/PlayerCar" if whose_cassette == GlobalEnums.PLAYER else $"CarLayer/EnemyCar"
	if not status_effect_manager.check_if_next_cassette_wont_work(whose_cassette):
		for action in side_data["actions"]:
			match int(action["action_type"]):
				GlobalEnums.ACTION_TYPE.ATTACK:
					var animation_name = action["animation_name"]
					var target_areas = action["target_area"].split(",")
					var attack_value = action.get("value", 0)
					var attack_modifier = status_effect_manager.get_attack_modifier_for_actor(whose_cassette)

					var correct_position_found = false
					var correct_target_area = ""

					for target_area in target_areas:
						match target_area:
							"back":
								if actor_node.battle_position == GlobalEnums.BATTLE_POSITIONS.OVERTAKE and target_node.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
									correct_position_found = true
									correct_target_area = target_area
									break
							"side":
								if actor_node.battle_position == GlobalEnums.BATTLE_POSITIONS.LINE_UP and target_node.battle_position == GlobalEnums.BATTLE_POSITIONS.LINE_UP:
									correct_position_found = true
									correct_target_area = target_area
									break
							"front":
								if actor_node.battle_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN and target_node.battle_position == GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
									correct_position_found = true
									correct_target_area = target_area
									break
							"all sides":
								correct_position_found = true
								match actor_node.battle_position:
									GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
										correct_target_area = "front"
									GlobalEnums.BATTLE_POSITIONS.LINE_UP:
										correct_target_area = "side"
									GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
										correct_target_area = "back"
								break

					var animation_player = actor_car.get_node("AnimationPlayer")

					if correct_position_found:
						print("Attack + modifier: ", attack_value+attack_modifier)
						if status_effect_manager.can_resist_attack(whose_cassette):
							animation_player.play("%s_%s_miss" % [animation_name, target_areas[0]])
						else:
							if attack_value+attack_modifier > 0:
								animation_player.play("%s_%s" % [animation_name, correct_target_area])
							else:
								animation_player.play("%s_%s" % [animation_name, correct_target_area])
					else:
						animation_player.play("%s_%s_miss" % [animation_name, target_areas[0]])
	
					await animation_player.animation_finished

					# Reduce target health if the attack hit
					if correct_position_found:
						if attack_value+attack_modifier > 0:

							target_node.health -= max(attack_value+attack_modifier, 0)
							print("Target health reduced by %d. New health: %d" % [attack_value+attack_modifier, target_node.health])

							var target_ui = enemy_ui if whose_cassette == GlobalEnums.PLAYER else player_ui
							print(target_ui)
							ui_animator.animate_life_gauge_change(target_ui, target_node.health)
							target_ui.get_node("PortraitArea/Label").text = "HP: " + str(target_node.health)
						else:
							print("Attack value after modifiers is 0 or less; no damage dealt.")
					status_effect_manager.remove_modifiers_after_attack(whose_cassette)

				GlobalEnums.ACTION_TYPE.MOVE:
					var position_key = action["target_area"]
					var actor = player if whose_cassette == GlobalEnums.PLAYER else enemy
					var other_participant = enemy if whose_cassette == GlobalEnums.PLAYER else player
					if not status_effect_manager.can_move(position_key, whose_cassette):
						print("Cannot move to position:", position_key, "from", GlobalEnums.BATTLE_POSITIONS.keys()[actor.battle_position])
						continue
					if status_effect_manager.reduce_from_slow_down_to_line_up(whose_cassette):
						if position_key == "slow_down":
							position_key = "line_up"
							print("Effect changed movement from Slow Down to Line Up")
					await ui_animator.animate_move_to_position(position_key, whose_cassette)
					actor.battle_position = GlobalEnums.BATTLE_POSITIONS[position_key.to_upper()]
					other_participant.battle_position = get_opposite_position(GlobalEnums.BATTLE_POSITIONS[position_key.to_upper()])

				GlobalEnums.ACTION_TYPE.SPECIAL:
					if action.get("effect_name", "") == "attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides":
						var bonus_damage = actor_node.fuel_spent_this_turn
						var total_damage = action.get("value", 0) + bonus_damage
						target_node.health -= total_damage
						print("Special attack deals %d damage (including %d bonus damage from spent fuel). New health: %d" % [total_damage, bonus_damage, target_node.health])
						var target_ui = enemy_ui if whose_cassette == GlobalEnums.PLAYER else player_ui
						ui_animator.animate_life_gauge_change(target_ui, target_node.health)
						target_ui.get_node("PortraitArea/Label").text = "HP: " + str(target_node.health)
					else:
						var enemy_enum = GlobalEnums.ENEMY if whose_cassette == GlobalEnums.PLAYER else GlobalEnums.PLAYER
						var target = whose_cassette if action.get("affected_target", 0) == GlobalEnums.AFFECTED_TARGET.ACTING_ACTOR else enemy_enum
						var effect_name = action.get("effect_name", "")
						var effect_data = Database.get_effect(effect_name)
						if not effect_data:
							print("Failed to fetch status effect data for:", effect_name)
							continue
						status_effect_manager.create_status_effect_element(action, effect_data, target)
		

func get_opposite_position(position: int) -> int:
	match position:
		GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
			return GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN
		GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			return GlobalEnums.BATTLE_POSITIONS.OVERTAKE
		GlobalEnums.BATTLE_POSITIONS.LINE_UP:
			return GlobalEnums.BATTLE_POSITIONS.LINE_UP
		_:
			return position


func _on_DEBUG_Overtake_pressed():
	ui_animator.animate_move_to_position("overtake", GlobalEnums.PLAYER)


func _on_DEBUG_LineUp_pressed():
	ui_animator.animate_move_to_position("line_up", GlobalEnums.PLAYER)


func _on_DEBUG_Slow_Down_pressed():
	ui_animator.animate_move_to_position("slow_down", GlobalEnums.PLAYER)


func clean_up_after_turn():
	clean_up_cassettes_from_slots()
	status_effect_manager.update_turn_based_status_effects()
	ui_animator.clean_up_fuel_counters()
	if player.hand.size() < 3:
		cassette_manager.shuffle_discard_into_hand()
	start_selection_phase()
	

func clean_up_cassettes_from_slots():
	cassette_manager.clear_slots_after_turn()
	enemy.clear_slots_after_turn()
