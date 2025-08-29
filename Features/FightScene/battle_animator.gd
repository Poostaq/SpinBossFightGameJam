extends Node


signal ui_ready_for_battle

@onready var player: Node = $"../Player"
@onready var enemy: Enemy = $"../Enemy"
@onready var player_ui: Control = $"../UI/PlayerUI"
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


func _ready() -> void:
	animation_player.play("ShowCockpit")


func animate_move_to_position(position_key: String, speed := 2.0) -> void:
	var tweener = create_tween()
	var player_data = BATTLE_POSITIONS[position_key]["player"]
	var enemy_data = BATTLE_POSITIONS[position_key]["enemy"]
	
	tweener.tween_property(player.battle_sprite, "position", player_data[0], speed)
	tweener.parallel().tween_property(player.battle_sprite, "scale", player_data[1], speed)
	tweener.parallel().tween_property(player.battle_sprite, "rotation_degrees", player_data[2], speed)
	tweener.parallel().tween_property(player.battle_sprite, "z_index", 1 if position_key == "overtake" else 0, speed)

	tweener.parallel().tween_property(enemy.battle_sprite, "position", enemy_data[0], speed)
	tweener.parallel().tween_property(enemy.battle_sprite, "scale", enemy_data[1], speed)
	tweener.parallel().tween_property(enemy.battle_sprite, "rotation_degrees", enemy_data[2], speed)
	tweener.parallel().tween_property(enemy.battle_sprite, "z_index", 0 if position_key == "overtake" else 1, speed)

	await tweener.finished

func play_attack_animation(attacker, target, animation_type: String) -> void:
	var animation_suffix = _get_position_suffix(target.battle_position)
	var full_animation_name = animation_type + "_" + animation_suffix
	attacker.animation_player.play(full_animation_name)

func play_malfunction_animation(actor) -> void:
	actor.animation_player.play("malfunction")

func play_special_animation(actor, effect_name: String) -> void:
	actor.animation_player.play("special_" + effect_name)

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

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"ShowCars":
			animation_player.play("ShowFuelCounter")
		"ShowCockpit":
			animation_player.play("ShowPortraits")
		"ShowPortraits":
			animation_player.play("ShowCars")
		"ShowFuelCounter":
			animation_player.play("ShowCassettes")
		"ShowCassettes":
			ui_ready_for_battle.emit()

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
	present_participant_mini_cassettes(sequence, player_mini_cassettes)
	present_participant_mini_cassettes(enemy_sequence, enemy_mini_cassettes)

	
func present_participant_mini_cassettes(sequence_node: Node2D, mini_cassette_nodes: Array) -> void:
	var slots = sequence_node.get_children()
	for i in range(slots.size()):
		var cassette = slots[i].cassette_in_slot
		if cassette:
			var mini_cassette = mini_cassette_nodes[i]
			mini_cassette.set_cassette_data(cassette)
			mini_cassette.visible = true
			mini_cassette.highlight_cassette(false)
			if i == 0:
				mini_cassette.show_icons()
