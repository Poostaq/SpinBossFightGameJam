extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.3
var player_deck = ["Hegemon", "New Yorker", "New Yorker", "Not Your Business", "Hegemon", "New Yorker", "New Yorker", "Not Your Business", "Hegemon", "New Yorker"]

@onready var cards_left_label = $RichTextLabel
@onready var card_database_reference = preload("res://Scripts/card_database.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	cards_left_label.text = str(player_deck.size())

func draw_card():
	var card_drawn = player_deck[0]
	var card_data = card_database_reference.CARDS[card_drawn]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		cards_left_label.visible = false
		
	
	cards_left_label.text = str(player_deck.size())
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	var card_image_path = "res://Images/"+card_data[2]
	new_card.name = "Card"
	new_card.get_node("Attack").text = str(card_data[0])
	new_card.get_node("Health").text = str(card_data[1])
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.card_type = card_data[3]
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	$"../CardManager".connect_card_signals(new_card)
	new_card.get_node("AnimationPlayer").play("card_flip")
	print("draw card")
