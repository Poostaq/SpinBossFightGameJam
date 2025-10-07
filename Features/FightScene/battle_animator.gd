extends Node


@onready var player: Node = $"../Player"
@onready var enemy: Enemy = $"../Enemy"
@onready var player_ui: Control = $"../UI/PlayerUI"
@onready var enemy_ui: Control = $"../UI/EnemyUI"
@onready var hand: Node2D = $"../UI/PlayerUI/Hand"
@onready var sequence: Node2D = $"../UI/PlayerUI/Sequence"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var enemy_sequence = $"../UI/EnemyUI/Sequence"

@onready var player_mini_cassette1 = $"../UI/PlayerUI/MiniCassetteSequence/FirstCassette"
@onready var player_mini_cassette2 = $"../UI/PlayerUI/MiniCassetteSequence/SecondCassette"
@onready var player_mini_cassette3 = $"../UI/PlayerUI/MiniCassetteSequence/ThirdCassette"

@onready var player_mini_cassettes = [player_mini_cassette1, player_mini_cassette2, player_mini_cassette3]

@onready var enemy_mini_cassette1 = $"../UI/EnemyUI/MiniCassetteSequence/FirstCassette"
@onready var enemy_mini_cassette2 = $"../UI/EnemyUI/MiniCassetteSequence/SecondCassette"
@onready var enemy_mini_cassette3 = $"../UI/EnemyUI/MiniCassetteSequence/ThirdCassette"

@onready var enemy_mini_cassettes = [enemy_mini_cassette1, enemy_mini_cassette2, enemy_mini_cassette3]

@onready var player_fuel_counter = $"../UI/FuelUI/PlayerFuelMeter/FuelAmount"
@onready var enemy_fuel_counter = $"../UI/FuelUI/EnemyFuelMeter/FuelAmount"

@onready var player_battle_sprite = $"../CarLayer/PlayerCar"
@onready var enemy_battle_sprite = $"../CarLayer/EnemyCar"

@onready var player_fuel_gauge_needle = $"../UI/FuelUI/PlayerFuelMeter/Needle"
@onready var enemy_fuel_gauge_needle = $"../UI/FuelUI/EnemyFuelMeter/Needle"

const DEFAULT_CASSETTE_SPEED = 0.2
const SLOT_POSITIONS = [
						Vector2(773,1085),
						Vector2(775,1040),
						Vector2(777,995),
						Vector2(779,950),
						Vector2(781,905),
						Vector2(1185,1085),
						Vector2(1183,1040),
						Vector2(1181,995),
						Vector2(1179,950),
						Vector2(1177,905)]
const CASSETTE_SCALES_IN_SLOTS = [
								  Vector2(0.79,0.79),
								  Vector2(0.78,0.78),
								  Vector2(0.77,0.77),
								  Vector2(0.76,0.76),
								  Vector2(0.75,0.75),
								  Vector2(0.79,0.79),
								  Vector2(0.78,0.78),
								  Vector2(0.77,0.77),
								  Vector2(0.76,0.76),
								  Vector2(0.75,0.75)]

const BATTLE_POSITIONS = {
	"slow_down": {
		"player": [Vector2(621,478), Vector2(0.27, 0.27), -7],
		"enemy": [Vector2(860, 451), Vector2(0.5, 0.5), -3]
	},
	"overtake": {
		"player": [Vector2(860, 451), Vector2(0.5, 0.5), -3],
		"enemy": [Vector2(621,478), Vector2(0.27, 0.27), -7]
	},
	"line_up": {
		"player": [Vector2(648,492), Vector2(0.5, 0.5), -4],
		"enemy": [Vector2(1015,423), Vector2(0.5, 0.5), -3]
	}
}

const PLAYER_FUEL_COMPARISON_POSITION = Vector2(820.0, 450.0)
const ENEMY_FUEL_COMPARISON_POSITION = Vector2(1120.0, 450.0)

func battle_ui_preparation() -> void:
	animation_player.play("ShowCockpit")
	await animation_player.animation_finished
	animation_player.play("ShowPortraits")
	await animation_player.animation_finished
	animation_player.play("ShowCars")
	await animation_player.animation_finished
	# animation_player.play("ShowFuelCounter")
	# await animation_player.animation_finished
	animation_player.play("ShowCassettes")
	await animation_player.animation_finished

	
func animate_move_to_position(position_key: String, whose_cassette: int, speed := 2.0) -> void:
	print("Animating move to position: %s for %s" % [position_key, whose_cassette])

	if whose_cassette == GlobalEnums.ENEMY:
		position_key = get_opposite_position(position_key)

	var current_player_position = player.battle_position
	var current_enemy_position = enemy.battle_position

	var target_player_position = GlobalEnums.BATTLE_POSITIONS[position_key.to_upper()]
	var target_enemy_position = GlobalEnums.BATTLE_POSITIONS[get_opposite_position(position_key).to_upper()]

	if current_player_position == target_player_position and current_enemy_position == target_enemy_position:
		print("Player and enemy are already in correct positions. Skipping movement.")
		return

	var intermediate_positions = []
	if current_player_position == GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN and position_key == "overtake":
		intermediate_positions = ["line_up", "overtake"]
	elif current_player_position == GlobalEnums.BATTLE_POSITIONS.OVERTAKE and position_key == "slow_down":
		intermediate_positions = ["line_up", "slow_down"]
	else:
		intermediate_positions = [position_key]

	var tweener: Tween
	for intermediate_position in intermediate_positions:
		tweener = create_tween()
		var player_data = BATTLE_POSITIONS[intermediate_position]["player"]
		var enemy_data = BATTLE_POSITIONS[intermediate_position]["enemy"]

		tweener.tween_property(player_battle_sprite, "position", player_data[0], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(player_battle_sprite, "scale", player_data[1], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(player_battle_sprite, "rotation_degrees", player_data[2], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(player_battle_sprite, "z_index", 1 if intermediate_position in ["overtake", "line_up"] else 0, speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)

		tweener.parallel().tween_property(enemy_battle_sprite, "position", enemy_data[0], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(enemy_battle_sprite, "scale", enemy_data[1], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(enemy_battle_sprite, "rotation_degrees", enemy_data[2], speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(enemy_battle_sprite, "z_index", 0 if intermediate_position in ["overtake", "line_up"] else 1, speed / SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		await tweener.finished


func get_opposite_position(position: String) -> String:
	match position:
		"slow_down":
			return "overtake"
		"overtake":
			return "slow_down"
		"line_up":
			return "line_up"
		_:
			return position

func play_attack_animation(attacker, target, animation_type: String) -> void:
	var animation_suffix = _get_position_suffix(target.battle_position)
	var full_animation_name = animation_type + "_" + animation_suffix
	attacker.animation_player.play(full_animation_name)

func _get_position_suffix(battle_position):
	match battle_position:
		GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			return "back"
		GlobalEnums.BATTLE_POSITIONS.LINE_UP:
			return "side"
		GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
			return "front"
		_:
			return "unknown"


func activate_player_slots():
	for slot in sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("Active")

func deactivate_player_slots():
	for slot in sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("RESET")

func reset_player_slots():
	for slot in sequence.get_children():
		slot.animation_player.play("RESET")


func close_player_slots():
	for slot in sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("CloseSlot")

func close_enemy_slots():
	for slot in enemy.sequence.get_children():
		slot.cassette_in_slot.play_animation("Cassette_vanish")
	for slot in enemy.sequence.get_children():
		slot.set_cover_state(true)
		
func close_slots():
	for slot in sequence.get_children():
		slot.cassette_in_slot.play_animation("Cassette_vanish")
	for slot in sequence.get_children():
		slot.reset_cover_modulate()
	for slot in sequence.get_children():
		slot.animation_player.play("CloseSlot")


func present_mini_cassettes():
	await present_participant_mini_cassettes(sequence, player_mini_cassettes)
	await present_participant_mini_cassettes(enemy_sequence, enemy_mini_cassettes)

	
func present_participant_mini_cassettes(sequence_node: Node2D, mini_cassette_nodes: Array) -> void:
	var slots = sequence_node.get_children()
	for i in range(slots.size()):
		var cassette = slots[i].cassette_in_slot
		if cassette:
			var mini_cassette = mini_cassette_nodes[i]
			mini_cassette.set_cassette_data(cassette)
			mini_cassette.visible = true
			await mini_cassette.highlight_cassette(false)
			if i == 0:
				mini_cassette.show_icons()

func compare_mini_cassette_fuel(
	player_minicassette: MiniCassette,
	enemy_minicassette: MiniCassette,
	who_wins: int,
	player_fuel_original_pos: Vector2,
	enemy_fuel_original_pos: Vector2
	):
	var player_cassette_fuel = player_minicassette.fuel_icon
	var enemy_cassette_fuel = enemy_minicassette.fuel_icon

	await get_tree().create_timer(0.8 / SettingsManager.battle_speed).timeout

	if not SettingsManager.get_setting("skip_fuel_comparison"):
		await move_mini_cassettes_fuel_to_middle(player_cassette_fuel, enemy_cassette_fuel)
		await get_tree().create_timer(0.8 / SettingsManager.battle_speed).timeout
		await move_fuel_counters_for_summation(player_cassette_fuel, enemy_cassette_fuel)
	await add_fuel_to_counters(player_cassette_fuel, enemy_cassette_fuel)

	await get_tree().create_timer(0.8 / SettingsManager.battle_speed).timeout

	var loser_cassette_fuel = enemy_cassette_fuel if who_wins == GlobalEnums.PLAYER else player_cassette_fuel
	var loser_position = enemy_fuel_original_pos if who_wins == GlobalEnums.PLAYER else player_fuel_original_pos
	var winner_fuel_counter = player_fuel_counter if who_wins == GlobalEnums.PLAYER else enemy_fuel_counter
	var loser_fuel_counter = enemy_fuel_counter if who_wins == GlobalEnums.PLAYER else player_fuel_counter
	var loser_minicassette = enemy_minicassette if who_wins == GlobalEnums.PLAYER else player_minicassette
	var loser_vector = Vector2(40, 0) if who_wins == GlobalEnums.PLAYER else Vector2(-40, 0)
	var loser_needle = enemy_fuel_gauge_needle if who_wins == GlobalEnums.PLAYER else player_fuel_gauge_needle

	await show_winner_and_loser_mini_cassettes(winner_fuel_counter, loser_fuel_counter)
	await remove_fuel_from_loser_counter(loser_fuel_counter, loser_cassette_fuel, loser_needle)
	if not SettingsManager.get_setting("skip_fuel_comparison"):
		await return_loser_fuel_to_original_position(loser_cassette_fuel, loser_position)
	await restore_cassette_to_original_scale(loser_minicassette, loser_vector)


func restore_and_hide_winning_minicassette(
	winner_minicassette: MiniCassette, 
	who_wins: int, 
	player_fuel_original_pos: Vector2,
	enemy_fuel_original_pos: Vector2
		):
	var winner_cassette_fuel = winner_minicassette.fuel_icon
	var winner_position = player_fuel_original_pos if who_wins == GlobalEnums.PLAYER else enemy_fuel_original_pos
	var winner_vector = -(get_enlarge_vector(who_wins))
	await restore_cassette_to_original_scale(winner_minicassette, winner_vector)

	if not SettingsManager.get_setting("skip_fuel_comparison"):
		winner_cassette_fuel.global_position = winner_position
	await get_tree().create_timer(1 / SettingsManager.battle_speed).timeout
	winner_minicassette.hide_icons()
	await winner_minicassette.highlight_cassette(true)


func enlarge_one_cassette(minicassette: MiniCassette, whose_cassette: int):
	var move_vector = get_enlarge_vector(whose_cassette)

	var tweener = create_tween()
	tweener.tween_property(minicassette, "scale", minicassette.scale + Vector2(0.2, 0.2), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(minicassette, "position", minicassette.position + move_vector, 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished

func enlarge_cassettes_for_comparison(player_minicassette: MiniCassette, enemy_minicassette: MiniCassette):
	var tweener = create_tween()
	tweener.tween_property(player_minicassette, "scale", player_minicassette.scale + Vector2(0.2, 0.2), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(player_minicassette, "position", player_minicassette.position + Vector2(40,0), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(enemy_minicassette, "scale", enemy_minicassette.scale + Vector2(0.2, 0.2,), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(enemy_minicassette, "position", enemy_minicassette.position + Vector2(-40,0), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished


func move_mini_cassettes_fuel_to_middle(player_fuel: Sprite2D, enemy_fuel: Sprite2D):
	var tweener = create_tween()
	player_fuel.z_index += 10
	enemy_fuel.z_index += 10
	tweener.tween_property(player_fuel, "global_position", PLAYER_FUEL_COMPARISON_POSITION, 0.6/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(enemy_fuel, "global_position", ENEMY_FUEL_COMPARISON_POSITION, 0.6/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished


func move_fuel_counters_for_summation(player_fuel: Sprite2D, enemy_fuel: Sprite2D):
	var tweener = create_tween()
	tweener.tween_property(player_fuel, "global_position", player_fuel_counter.global_position + Vector2(45, 45), 0.4).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(player_fuel, "modulate", Color(1,1,1,0), 0.4).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(enemy_fuel, "global_position", enemy_fuel_counter.global_position + Vector2(45, 45), 0.4).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(enemy_fuel, "modulate", Color(1,1,1,0), 0.4).set_trans(Tween.TRANS_SINE)
	await tweener.finished
	player_fuel.z_index -= 10
	enemy_fuel.z_index -= 10


func add_fuel_to_counters(player_cassette_fuel, enemy_cassette_fuel):
	var player_fuel_amount = player_cassette_fuel.get_node("Label")
	var enemy_fuel_amount = enemy_cassette_fuel.get_node("Label")

	var bigger_value = max(int(player_fuel_amount.text), int(enemy_fuel_amount.text))
	for i in range(bigger_value):
		if i < int(player_fuel_amount.text):
			player_fuel_counter.text = str(int(player_fuel_counter.text)+1)
			rotate_fuel_gauge(player_fuel_gauge_needle,1)
		if i < int(enemy_fuel_amount.text):
			enemy_fuel_counter.text = str(int(enemy_fuel_counter.text)+1)
			rotate_fuel_gauge(enemy_fuel_gauge_needle,1)
		await get_tree().create_timer(0.1/SettingsManager.battle_speed).timeout	


func show_winner_and_loser_mini_cassettes(winner: Label, loser: Label):
	var tweener = create_tween()
	tweener.tween_property(winner, "scale", winner.scale + Vector2(0.05, 0.05), 0.55/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(loser, "scale", loser.scale - Vector2(0.05, 0.05), 0.55/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(winner, "self_modulate", Color(1,1,1,1), 0.55/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(loser, "self_modulate", Color(1,1,1,0.05), 0.55/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished
	await get_tree().create_timer(0.2/SettingsManager.battle_speed).timeout

	tweener = create_tween()
	tweener.tween_property(winner, "scale", winner.scale - Vector2(0.05, 0.05), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(loser, "scale", loser.scale + Vector2(0.05, 0.05), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(winner, "self_modulate", Color(1,1,1,0.3), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(loser, "self_modulate", Color(1,1,1,0.3), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished


func remove_fuel_from_loser_counter(loser_counter: Label, loser_fuel: Sprite2D, loser_needle: TextureRect):
	print("Removing fuel from loser counter")
	var loser_counter_amount = int(loser_fuel.get_node("Label").text)
	var fuel_spent_label = loser_counter as Label
	for i in range(loser_counter_amount):
		fuel_spent_label.text = str(int(fuel_spent_label.text) - 1)
		rotate_fuel_gauge(loser_needle,-1)
		await get_tree().create_timer(0.1/SettingsManager.battle_speed).timeout


func return_loser_fuel_to_original_position(loser: Sprite2D, original_global_pos: Vector2):
	print("Returning loser fuel to original position")
	var tweener = create_tween()
	loser.z_index += 10
	tweener.tween_property(loser, "global_position", original_global_pos, 0.6).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(loser, "modulate", Color(1,1,1,1),0.3).set_trans(Tween.TRANS_SINE)

	await tweener.finished
	loser.z_index -= 10


func restore_cassette_to_original_scale(minicassette: MiniCassette, moving_vector: Vector2):
	print("Restoring loser cassette to original scale")
	var tweener = create_tween()
	tweener.tween_property(minicassette, "scale", minicassette.scale - Vector2(0.2, 0.2), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(minicassette, "position", minicassette.position + moving_vector, 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished


func animate_next_cassette(minicassette: MiniCassette, whose_cassette: int):

	var cassette_fuel = minicassette.fuel_icon
	var move_target: Vector2
	var fuel_counter: Label
	var moving_vector: Vector2
	var original_position = minicassette.global_position
	var needle: TextureRect

	if whose_cassette == GlobalEnums.PLAYER:
		move_target = PLAYER_FUEL_COMPARISON_POSITION
		fuel_counter = player_fuel_counter
		moving_vector = Vector2(40,0)
		needle = player_fuel_gauge_needle
	else:
		move_target = ENEMY_FUEL_COMPARISON_POSITION
		fuel_counter = enemy_fuel_counter
		moving_vector = Vector2(-40,0)
		needle = enemy_fuel_gauge_needle


	var tweener = create_tween()
	tweener.tween_property(minicassette, "scale", minicassette.scale + Vector2(0.2, 0.2), 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(minicassette, "position", minicassette.position + moving_vector, 0.3/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
	await tweener.finished

	if not SettingsManager.get_setting("skip_fuel_comparison"):	
		cassette_fuel.z_index += 10

		tweener = create_tween()
		tweener.tween_property(cassette_fuel, "global_position", move_target, 0.6/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		await tweener.finished

		cassette_fuel.z_index -= 10

		tweener = create_tween()
		tweener.tween_property(cassette_fuel, "global_position", fuel_counter.global_position, 0.4/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		tweener.parallel().tween_property(cassette_fuel, "modulate", Color(1,1,1,0), 0.4/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
		await tweener.finished

	var fuel_amount = minicassette.fuel_icon.get_node("Label")
	
	for i in range(int(fuel_amount.text)):
		fuel_counter.text = str(int(fuel_counter.text)+1)
		rotate_fuel_gauge(needle,1)
		await get_tree().create_timer(0.1/SettingsManager.battle_speed).timeout
	
	if not SettingsManager.get_setting("skip_fuel_comparison"):	
		cassette_fuel.global_position = original_position
	await restore_cassette_to_original_scale(minicassette, -moving_vector)
	minicassette.hide_icons()
	await minicassette.highlight_cassette(true)

func animate_life_gauge_change(target: Node, new_value: int):
	var portrait_area = target.get_node("PortraitArea")
	var life_gauge = portrait_area.get_node("LifeGauge")
	var tweener = create_tween()
	tweener.tween_property(life_gauge, "value", new_value, 0.5).set_trans(Tween.TRANS_SINE)
	await tweener.finished


func clean_up_fuel_counters():
	for i in range(player_fuel_counter.text.to_int()):
		player_fuel_counter.text = str(int(player_fuel_counter.text) - 1)
		rotate_fuel_gauge(player_fuel_gauge_needle,-1)
		await get_tree().create_timer(0.1/SettingsManager.battle_speed).timeout
	for i in range(enemy_fuel_counter.text.to_int()):
		enemy_fuel_counter.text = str(int(enemy_fuel_counter.text) - 1)
		rotate_fuel_gauge(enemy_fuel_gauge_needle,-1)
		await get_tree().create_timer(0.1/SettingsManager.battle_speed).timeout


func get_enlarge_vector(whose_cassette: int) -> Vector2:
	if whose_cassette == GlobalEnums.PLAYER:
		return Vector2(40, 0)
	else:
		return Vector2(-40, 0)


func rotate_fuel_gauge(needle: TextureRect, angle_points: float):
	print("Rotation degrees before: %s" % needle.rotation_degrees)
	if needle.rotation_degrees+(angle_points * 6) > 0.1:
		return
	if needle.rotation_degrees+(angle_points * 6) < -90.1:
		return
	print("Rotating fuel gauge by %s points" % angle_points)
	var tweener = create_tween()
	tweener.tween_property(needle, "rotation_degrees", needle.rotation_degrees + (angle_points * 6), 0.1/SettingsManager.battle_speed).set_trans(Tween.TRANS_SINE)
