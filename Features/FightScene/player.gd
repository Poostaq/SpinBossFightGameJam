extends Node


const CASSETTE_SCENE = "res://Features/FightScene/Cassette/cassette_v2.tscn"
signal cassette_created(cassette)


var deck: Array = []
var discard: Array = []
var lost: Array = []
var hand: Array = []

@onready var cassette_manager: Node2D = %CassetteManager

var health: int = 20
var fuel_spent_this_turn: int = 0
var battle_position: int = GlobalEnums.BATTLE_POSITIONS.LINE_UP

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
	var cassette_info = Database.cassettes["cassettes"][cassette_name]	
	new_cassette.setup_player_cassette(cassette_name, cassette_info)
	cassette_manager.connect_cassette_signals(new_cassette)
	return new_cassette


func remove_cassette_from_hand(cassette):
	hand.remove_at(hand.find(cassette))


func add_cassette_to_hand(cassette):
	hand.append(cassette)
