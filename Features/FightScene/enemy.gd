extends Node
class_name Enemy

const CASSETTE_SCENE = "res://Features/FightScene/EnemyCassette/enemy_cassette.tscn"
# Signals to notify others of changes
signal deck_changed(new_deck)  # deck or hand changed
signal slots_changed()         # slot cassettes changed
signal cassette_created

# Core cassette containers
var deck: Array = []           # Full deck of cassettes
var discard: Array = []        # Discarded cassettes
var lost: Array = []           # Completely lost cassettes
var hand: Array = []           # Cassettes currently in the enemy's (logical) hand
@onready var sequence: Node2D = $"../UI/EnemyUI/Sequence"

@onready var cassette_manager: Node2D = %CassetteManager

var slot_cassettes: Array = [null, null, null]

var health: int = 20

var rng

func _ready():
	rng = RandomNumberGenerator.new()
	pass

func discard_cassette(cassette):
	if cassette in hand:
		hand.erase(cassette)
	discard.append(cassette)
	emit_signal("deck_changed", deck)

func lose_cassette(cassette):
	if cassette in hand:
		hand.erase(cassette)
	lost.append(cassette)
	emit_signal("deck_changed", deck)


func remove_cassette_from_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_cassettes.size():
		return

	var cassette = slot_cassettes[slot_index]
	if cassette != null:
		# Move it back to hand (or discard/lost) if desired
		hand.append(cassette)
		slot_cassettes[slot_index] = null
		emit_signal("slots_changed")


func prepare_hand(enemy_name):
	var enemy_cassettes = Database.boss_decks[enemy_name]
	for cassette in enemy_cassettes:
		var new_cassette = create_cassette(cassette)
		hand.append(new_cassette)
		cassette_created.emit()

func create_cassette(cassette_name):
	var cassette_scene = preload(CASSETTE_SCENE)
	var new_cassette = cassette_scene.instantiate()
	new_cassette.scale = new_cassette.REGULAR_CASSETTE_SIZE
	new_cassette.name = cassette_name
	new_cassette.side_a_data = Database.cassettes["cassettes"][cassette_name]["side_a"]
	new_cassette.side_b_data = Database.cassettes["cassettes"][cassette_name]["side_b"]
	new_cassette.cassette_name = cassette_name
	new_cassette.current_side = "A"
	new_cassette.whose_cassette = GlobalEnums.PLAYER
	cassette_manager.connect_cassette_signals(new_cassette)
	new_cassette.state = new_cassette.STATE.IN_HAND
	return new_cassette

func remove_cassette_from_hand(cassette):
	hand.remove_at(hand.find(cassette))

func select_cassettes_for_sequence():
	for i in range(0, 3):
		var selected_cassette_index = rng.randi_range(0, len(hand)-1)
		var selected_cassette = hand[selected_cassette_index]
		var side = rng.randi_range(0,1)
		if side == 0:
			selected_cassette.current_side = "A"
		else:
			selected_cassette.current_side = "B"
		var current_slot = sequence.get_children()[i]
		remove_cassette_from_hand(selected_cassette)
		current_slot.add_child(selected_cassette)
		current_slot.set_cover_state(false)
		current_slot.cassette_in_slot = selected_cassette
		selected_cassette.animate_cassette_to_position(Vector2(0,0))
                var side_data = selected_cassette.get_current_side_data()
                current_slot.fill_icons(side_data)
                await get_tree().create_timer(0.5).timeout
	return true
