extends Node


signal ui_ready_for_battle

@onready var player: Node = $"../Player"
@onready var enemy: Enemy = $"../Enemy"
@onready var player_ui: Control = $"../UI/PlayerUI"
@onready var hand: Node2D = $"../UI/PlayerUI/Hand"
@onready var sequence: Node2D = $"../UI/PlayerUI/Sequence"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

const DEFAULT_CASSETTE_SPEED = 0.2
const SLOT_POSITIONS = [
						Vector2(1185,1085),
						Vector2(1183,1040),
						Vector2(1181,995),
						Vector2(1179,950),
						Vector2(1177,905),
						Vector2(773,1085),
						Vector2(775,1040),
						Vector2(777,995),
						Vector2(779,950),
						Vector2(781,905)]
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
	player.cassette_created.connect(move_cassette_to_hand)
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



#func present_cassettes(player_cassettes, enemy_cassettes):
	## Here you can place logic to show mini-cassettes on UI.
	## For now, we just finish immediately.
	## If you previously had a populate_mini_cassettes() or tween logic, call it here.
#
	#print("[UIAnimator] Presenting cassettes... (placeholder)")
	## After animating or showing cassettes, emit presentation_finished.
	#presentation_finished.emit()


func move_cassette_to_hand(cassette):
	if cassette not in hand.get_children():
		if cassette.get_parent() == null:
			hand.add_child(cassette)
		else:
			cassette.reparent(hand)
		
		cassette.update_elements()
		update_hand_positions(DEFAULT_CASSETTE_SPEED)
	else:
		cassette.animate_cassette_to_position(cassette.position_in_hand, DEFAULT_CASSETTE_SPEED)

func update_hand_positions(speed):
	for i in range(player.hand.size()):
		var cassette = player.hand[i]
		cassette.position_in_hand = SLOT_POSITIONS[player.hand.size()-1-i]
		cassette.scale_in_hand = CASSETTE_SCALES_IN_SLOTS[player.hand.size()-1-i]
		cassette.animate_cassette_to_position(cassette.position_in_hand,speed)
#TODO POPRAWIĆ UŁOŻENIE KASET NA RĘCE

func activate_player_slots():
	for slot in sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("Active")

func deactivate_player_slots():
	for slot in sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("RESET")
	
func make_cassette_colliders(disabled: bool) -> void:
	for cassette in hand.get_children():
		cassette.collision_shape_2d.disabled = disabled

func prepare_screen():
	pass


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
