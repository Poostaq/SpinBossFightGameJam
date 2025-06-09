extends Node2D


const CARD_SCENE_PATH = "res://Features/FightScene/EnemyCassette/enemy_cassette.tscn"


var enemy_deck = ["Regular Attack","Regular Attack","Regular Attack","Regular Attack","Quick Attack","Quick Attack","Quick Attack","Heavy Attack","Heavy Attack","Heavy Attack",]

@onready var deck_cassettes = []
@onready var cassette_manager: Node2D = %CassetteManager
@onready var enemy_discard: Node2D = $"../Discard"
@onready var enemy_hand: Node = $"../Hand"

@onready var cassette_database_reference = Database


func create_deck_cassettes(deck_cassette_names):
	for cassette_name in deck_cassette_names:
		create_cassette(cassette_name)

func create_cassette(cassette_name):
	var cassette_data = cassette_database_reference.CASSETTES[cassette_name]
	var cassette_scene = preload(CARD_SCENE_PATH)
	var new_cassette = cassette_scene.instantiate()
	new_cassette.scale = Vector2(1,1)
	self.add_child(new_cassette)
	new_cassette.visible = false
	new_cassette.position = Vector2(1920, 100)
	new_cassette.scale = new_cassette.SMALLER_CASSETTE_SIZE
	new_cassette.name = cassette_data[0]
	new_cassette.side_a_data = cassette_data[1]
	new_cassette.side_b_data = cassette_data[2]
	new_cassette.cassette_name = cassette_data[0]
	new_cassette.current_side = "A"
	new_cassette.whose_cassette = GlobalEnums.ENEMY
	cassette_manager.connect_cassette_signals(new_cassette)
	deck_cassettes.append(new_cassette)

func draw_cassette():
	if len(deck_cassettes) == 0:
		for i in len(enemy_discard.discarded_cassettes):
			var cassette = enemy_discard.discarded_cassettes[0]
			deck_cassettes.append(cassette)
			enemy_discard.discarded_cassettes.erase(cassette)
			enemy_discard.remove_child(cassette)
			self.add_child(cassette)
	var cassette_drawn = deck_cassettes[0]
	deck_cassettes.erase(cassette_drawn)
	self.remove_child(cassette_drawn)
	enemy_hand.add_child(cassette_drawn)
	enemy_hand.enemy_hand.insert(0, cassette_drawn)
