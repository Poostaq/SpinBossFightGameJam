extends Node2D


const HAND_Y_START_POSITION = 940
const HAND_X_POSITION = 760
const DEFAULT_CASSETTE_SPEED = 0.2
const SLOT_POSITIONS = [Vector2(773,1085),
							Vector2(775,1040),
						Vector2(777,995),
						Vector2(779,950),
						Vector2(781,905)]
const CASSETTE_SCALES_IN_SLOTS = [Vector2(0.79,0.79),
								  Vector2(0.78,0.78),
								  Vector2(0.77,0.77),
								  Vector2(0.76,0.76),
								  Vector2(0.75,0.75)]


@onready var cassette_manager: Node2D = %CassetteManager

var max_hand_cassettes = 5
var player_hand = []
	

func add_cassette_to_hand(cassette, speed):
	if cassette not in player_hand:
		player_hand.append(cassette)
		cassette.z_index = 0
		update_hand_positions(speed)
		cassette.get_node("Node2D/Area2D").visible = true
		
	else:
		cassette.animate_cassette_to_position(cassette.position_in_hand,
											  DEFAULT_CASSETTE_SPEED)

func remove_cassette_from_hand(cassette):
	if cassette in player_hand:
		player_hand.erase(cassette)
		update_hand_positions(DEFAULT_CASSETTE_SPEED)
		self.remove_child(cassette)

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		var cassette = player_hand[i]
		cassette.position_in_hand = SLOT_POSITIONS[player_hand.size()-1-i]
		cassette.scale_in_hand = CASSETTE_SCALES_IN_SLOTS[player_hand.size()-1-i]
		cassette.animate_cassette_to_position(cassette.position_in_hand,speed)
