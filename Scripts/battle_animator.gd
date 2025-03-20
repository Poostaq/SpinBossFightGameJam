extends Node


signal presentation_finished

@onready var player: Node2D = $"../Player"
@onready var enemy: Node2D = $"../Enemy"

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



func present_cassettes(player_cassettes, enemy_cassettes):
	# Here you can place logic to show mini-cassettes on UI.
	# For now, we just finish immediately.
	# If you previously had a populate_mini_cassettes() or tween logic, call it here.

	print("[UIAnimator] Presenting cassettes... (placeholder)")
	# After animating or showing cassettes, emit presentation_finished.
	presentation_finished.emit()





















## We'll create a new UIAnimator code that merges your old battle UI animation script
## with the present_cassettes approach.
#
#extends Node
#
#signal presentation_finished
#
#@onready var player: Node2D = $"../Player"  # direct references to the nodes
#@onready var enemy: Node2D = $"../Enemy"
#
## Positions & scaling used for move animations
#const BATTLE_POSITIONS = {
	#"slow_down": {
		#"player": [Vector2(621,478), Vector2(0.27, 0.27), -7],
		#"enemy": [Vector2(860, 451), Vector2(0.5, 0.5), -3]
	#},
	#"overtake": {
		#"player": [Vector2(860, 451), Vector2(0.5, 0.5), -3],
		#"enemy": [Vector2(621,478), Vector2(0.27, 0.27), -7]
	#},
	#"line_up": {
		#"player": [Vector2(648,492), Vector2(0.5, 0.5), -4],
		#"enemy": [Vector2(1015,423), Vector2(0.5, 0.5), -3]
	#}
#}
#
#func present_cassettes(player_cassettes, enemy_cassettes):
	## Here you can place logic to show mini-cassettes on UI.
	## For now, we just finish immediately.
	## If you previously had a populate_mini_cassettes() or tween logic, call it here.
#
	#print("[UIAnimator] Presenting cassettes... (placeholder)")
	## After animating or showing cassettes, emit presentation_finished.
	#presentation_finished.emit()
#
#func animate_move_to_position(position_key: String, speed := 2.0) -> void:
	#var tweener = create_tween()
	#var player_data = BATTLE_POSITIONS[position_key]["player"]
	#var enemy_data = BATTLE_POSITIONS[position_key]["enemy"]
#
	#tweener.tween_property(player.battle_sprite, "position", player_data[0], speed)
	#tweener.parallel().tween_property(player.battle_sprite, "scale", player_data[1], speed)
	#tweener.parallel().tween_property(player.battle_sprite, "rotation_degrees", player_data[2], speed)
	#tweener.parallel().tween_property(player.battle_sprite, "z_index", position_key == "overtake" ? 1 : 0, speed)
#
	#tweener.parallel().tween_property(enemy.battle_sprite, "position", enemy_data[0], speed)
	#tweener.parallel().tween_property(enemy.battle_sprite, "scale", enemy_data[1], speed)
	#tweener.parallel().tween_property(enemy.battle_sprite, "rotation_degrees", enemy_data[2], speed)
	#tweener.parallel().tween_property(enemy.battle_sprite, "z_index", position_key == "overtake" ? 0 : 1, speed)
#
	#await tweener.finished
#
#func play_attack_animation(attacker, target, animation_type: String) -> void:
	#var animation_suffix = _get_position_suffix(target.battle_position)
	#var full_animation_name = animation_type + "_" + animation_suffix
	#attacker.animation_player.play(full_animation_name)
#
#func play_malfunction_animation(actor) -> void:
	#actor.animation_player.play("malfunction")
#
#func play_special_animation(actor, effect_name: String) -> void:
	#actor.animation_player.play("special_" + effect_name)
#
#func _get_position_suffix(battle_position):
	#match battle_position:
		#GlobalEnums.BATTLE_POSITIONS.SLOW_DOWN:
			#return "back"
		#GlobalEnums.BATTLE_POSITIONS.LINE_UP:
			#return "side"
		#GlobalEnums.BATTLE_POSITIONS.OVERTAKE:
			#return "front"
		#_:
			#return "unknown"
