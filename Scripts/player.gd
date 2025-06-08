extends Node


const CASSETTE_SCENE = "res://Scenes/cassette_v2.tscn"
signal cassette_created(cassette)

# Core cassette containers
var deck: Array = []            # Full deck of cassettes
var discard: Array = []         # Discarded cassettes
var lost: Array = []            # Completely lost cassettes
var hand: Array = []            # Cassettes currently in the player's (logical) hand

@onready var cassette_manager: Node2D = %CassetteManager
@onready var sequence: Node2D = $"../UI/PlayerUI/Sequence"

var health: int = 20
func _ready():
	   # Shuffle or do any initial deck setup here
	   pass

func prepare_hand():
	var player_cassettes = Database.player_deck["player_deck"]
	for cassette in player_cassettes:
		var new_cassette = create_cassette(cassette)
		hand.append(new_cassette)
		cassette_created.emit(new_cassette)
		new_cassette.set_state(new_cassette.STATE.IN_HAND)


func create_cassette(cassette_name):
	   var cassette_scene = preload(CASSETTE_SCENE)
	   var new_cassette = cassette_scene.instantiate()
	   new_cassette.scale = new_cassette.REGULAR_CASSETTE_SIZE
	   new_cassette.name = cassette_name
	   var cassette_info = Database.cassettes["cassettes"][cassette_name]
	   new_cassette.side_a_data = cassette_info["side_a"]
	   new_cassette.side_b_data = cassette_info["side_b"]
	   if "image_a" in cassette_info:
			   new_cassette.image_a = cassette_info["image_a"]
			   new_cassette.image_b = cassette_info["image_b"]
	   new_cassette.cassette_name = cassette_name
	   new_cassette.current_side = "A"
	   new_cassette.whose_cassette = GlobalEnums.PLAYER
	   cassette_manager.connect_cassette_signals(new_cassette)
	   return new_cassette

func remove_cassette_from_hand(cassette):
	hand.remove_at(hand.find(cassette))

func add_cassette_to_hand(cassette):
	hand.append(cassette)
