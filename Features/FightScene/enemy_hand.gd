extends Node

var max_hand_cassettes = 5
var enemy_hand = []
const DEFAULT_CASSETTE_SPEED = 0.2


func animate_cassette_to_position(cassette, new_position, speed=DEFAULT_CASSETTE_SPEED, new_rotation=0):
	cassette.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(cassette, "position", new_position, speed)
	tween.tween_property(cassette, "rotation", new_rotation, speed)

func remove_cassette_from_hand(cassette):
	if cassette in enemy_hand:
		enemy_hand.erase(cassette)
		self.remove_child(cassette)
