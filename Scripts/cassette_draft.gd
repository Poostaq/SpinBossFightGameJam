extends Node2D

const DECKBUILDER_CASSETTE = preload("res://Scenes/deckbuilder_cassette.tscn")
const REGULAR_CASSETTE_SCALE = Vector2(1,1)
const ENLARGED_CASSETTE_SCALE = Vector2(1.1,1.1)
const SPEED = 0.1

var available_cassettes
var bonus_cassettes

@onready var player_cassettes: Node2D = $PlayerDeck/Cassettes
@onready var available_cassettes_column: Node2D = $PlayerAvailableCassettes/AvailableCassettesColumn
@onready var available_cassettes_column_2: Node2D = $PlayerAvailableCassettes/AvailableCassettesColumn2
@onready var reward_cassettes: Node2D = $PlayerRewardCassettes
@onready var deckbuilder_cassette_preview: Node2D = $DeckbuilderCassettePreview
@onready var cassette_count: Label = $PlayerDeck/CassetteCount
@onready var proceed_with_deck: Button = $ProceedWithDeck

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#prepare_cassette_draft()

func prepare_cassette_draft():
	available_cassettes = CassetteDatabase.player_base_available_cards
	for cassette in available_cassettes:
		var new_cassette_object = DECKBUILDER_CASSETTE.instantiate()
		new_cassette_object.cassette_data = CassetteDatabase.CASSETTES[cassette]
		add_to_available_cassettes(new_cassette_object)
		new_cassette_object.label.text = cassette
		new_cassette_object.name = cassette
		new_cassette_object.cassette_hovered.connect(fill_tooltip_with_cassette_data.bind())
		new_cassette_object.cassette_hovered_off.connect(hide_cassette_preview.bind())
	
	
func clean_up_draft():
	for cassette in player_cassettes.get_children():
		cassette.queue_free()
	for cassette in available_cassettes_column.get_children():
		cassette.queue_free()
	for cassette in available_cassettes_column_2.get_children():
		cassette.queue_free()
	for cassette in reward_cassettes.get_children():
		cassette.queue_free()

func add_to_available_cassettes(cassette):
	if len(available_cassettes_column.get_children()) < 10:
		available_cassettes_column.add_child(cassette)
	else:
		available_cassettes_column_2.add_child(cassette)
	update_available_cassettes_column_positions()

func add_to_reward_cassettes(cassette):
	reward_cassettes.add_child(cassette)
	update_reward_cassettes_column_positions()

func remove_from_available_cassettes(cassette):
	if cassette in available_cassettes_column.get_children():
		available_cassettes_column.remove_child(cassette)
		update_available_cassettes_column_positions()
	if cassette in available_cassettes_column_2.get_children():
		available_cassettes_column_2.remove_child(cassette)
		update_available_cassettes_column_positions()
	

func update_available_cassettes_column_positions():
	if len(available_cassettes_column.get_children()) < 10:
		if len(available_cassettes_column_2.get_children()) > 0:
			var first_cassette = available_cassettes_column_2.get_child(0)
			available_cassettes_column_2.remove_child(first_cassette)
			available_cassettes_column.add_child(first_cassette)
	for i in range(len(available_cassettes_column.get_children())):
		var cassette = available_cassettes_column.get_child(i)
		cassette.animate_cassette_to_position(Vector2(250,(30+(i*75))),SPEED)
	for i in range(len(available_cassettes_column_2.get_children())):
		var cassette = available_cassettes_column_2.get_child(i)
		cassette.animate_cassette_to_position(Vector2(250,(30+(i*75))),SPEED)

func update_player_cassettes_column_positions():
	for i in range(len(player_cassettes.get_children())):
		var cassette = player_cassettes.get_child(i)
		cassette.position = Vector2(250,(30+(i*75)))

func update_reward_cassettes_column_positions():
	for i in range(len(reward_cassettes.get_children())):
		var cassette = reward_cassettes.get_child(i)
		cassette.animate_cassette_to_position(Vector2(250,(30+(i*75))),SPEED)

func get_player_deck_cassette_names():
	var return_list = []
	for cassette in player_cassettes.get_children():
		return_list.append(cassette.cassette_data[0])

func fill_tooltip_with_cassette_data(cassette_data):
	deckbuilder_cassette_preview.set_preview_data(cassette_data)
	deckbuilder_cassette_preview.visible = true

func hide_cassette_preview():
	deckbuilder_cassette_preview.visible = false
	
	
func update_player_cassette_count():
	var count = player_cassettes.get_child_count()
	cassette_count.text = "Your Tapes "+str(count)+"/10"
	
	
func check_if_select_deck_button_activate():
	if player_cassettes.get_child_count() == 10:
		proceed_with_deck.disabled = false
	else:
		proceed_with_deck.disabled = true
	
