extends Node2D

const CARD_SCENE_PATH = "res://Scenes/cassette.tscn"
const CASSETTE_DRAW_SPEED = 0.1

var player_deck_cassettes = ["EMP","EMP","Quick Attack","Emergency Brake","Regular Attack","Regular Attack","Nitro","Heavy Attack","Shoot'em up","Ram",]

@onready var deck_cassettes = []
@onready var cassettes = $Cassettes
@onready var cassette_manager: Node2D = %CassetteManager
@onready var cassette_database_reference= CassetteDatabase
@onready var player_discard: Node2D = $"../Discard"
@onready var player_hand: Node2D = $"../Hand"


func _ready() -> void:
	player_deck_cassettes = CassetteDatabase.hound_deck
	player_deck_cassettes.shuffle()
	create_deck_cassettes(player_deck_cassettes)


func draw_cassette(new_position=null):
	if len(deck_cassettes) == 0:
		for i in len(player_discard.discarded_cassettes):
			var cassette = player_discard.discarded_cassettes[0]
			deck_cassettes.append(cassette)
			player_discard.discarded_cassettes.erase(cassette)
			player_discard.remove_child(cassette)
			cassettes.add_child(cassette)
			cassette.z_index = 0
			cassette.visible = true
			cassette.scale = cassette.REGULAR_CASSETTE_SIZE
		deck_cassettes.shuffle()
	var cassette_drawn = deck_cassettes[0]
	deck_cassettes.erase(cassette_drawn)
	var retain_position = Vector2(0,0)
	if new_position:
		retain_position = self.position
	else:
		retain_position = cassette_drawn.global_position
	cassettes.remove_child(cassette_drawn)
	player_hand.add_child(cassette_drawn)
	cassette_drawn.position = retain_position
	player_hand.add_cassette_to_hand(cassette_drawn, CASSETTE_DRAW_SPEED)
	cassette_drawn.get_node('Node2D/Area2D/CollisionShape2D').disabled = false

func create_deck_cassettes(deck_cassette_names):
	for cassette_name in deck_cassette_names:
		create_cassette(cassette_name)
	update_deck_positions(CASSETTE_DRAW_SPEED)

func create_cassette(cassette_name):
	var cassette_data = cassette_database_reference.CASSETTES[cassette_name]
	var cassette_scene = preload(CARD_SCENE_PATH)
	var new_cassette = cassette_scene.instantiate()
	new_cassette.scale = new_cassette.REGULAR_CASSETTE_SIZE
	cassettes.add_child(new_cassette)
	new_cassette.name = cassette_data[0]
	new_cassette.side_a_data = cassette_data[1]
	new_cassette.side_b_data = cassette_data[2]
	new_cassette.cassette_name = cassette_data[0]
	new_cassette.current_side = "A"
	new_cassette.update_elements()
	new_cassette.whose_cassette = "player"
	new_cassette.get_node("Node2D/Area2D").visible = false
	cassette_manager.connect_cassette_signals(new_cassette)
	deck_cassettes.append(new_cassette)
	new_cassette.state(new_cassette.STATE.IN_DECK)

	
func update_deck_positions(speed):
	for i in range(deck_cassettes.size()):
		var new_position = calculate_new_position(i)
		var cassette = deck_cassettes[i]
		cassette.animate_cassette_to_position(new_position, speed, 90)
		
func calculate_new_position(index):
	var total_width = 0
	for cassette in deck_cassettes:
		total_width -= cassette.TOP_Y
	var final_x = 0
	var position_in_width = 0
	for i in range(deck_cassettes.size()-1,index,-1):
		position_in_width -= deck_cassettes[i].TOP_Y
	position_in_width -= deck_cassettes[index].TOP_Y
	final_x += total_width-position_in_width
	return Vector2(final_x, 0)
