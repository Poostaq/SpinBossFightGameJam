extends Node
class_name Enemy

const CASSETTE_SCENE = "res://Scenes/enemy_cassette.tscn"
# Signals to notify others of changes
signal deck_changed(new_deck)  # deck or hand changed
signal slots_changed()         # slot cassettes changed
signal cassette_created

# Core cassette containers
var deck: Array = []           # Full deck of cassettes
var discard: Array = []        # Discarded cassettes
var lost: Array = []           # Completely lost cassettes
var hand: Array = []           # Cassettes currently in the enemy's (logical) hand

@onready var cassette_manager: Node2D = %CassetteManager

var slot_cassettes: Array = [null, null, null]

var health: int = 20

func _ready():
	# Shuffle or do any initial deck setup here
	pass

#
# --- Deck/Hand Logic ---
#
func draw_cassette():
	if deck.size() > 0:
		var cassette = deck.pop_back()
		hand.append(cassette)
		emit_signal("deck_changed", deck)

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

#
# --- Slot Logic ---
#
func put_cassette_in_slot(cassette, slot_index: int) -> void:
	# Validate slot_index
	if slot_index < 0 or slot_index >= slot_cassettes.size():
		return

	# If slot is occupied, return old cassette to hand
	if slot_cassettes[slot_index] != null:
		hand.append(slot_cassettes[slot_index])

	# Remove cassette from the hand if present
	if cassette in hand:
		hand.erase(cassette)

	# Place cassette in the slot
	slot_cassettes[slot_index] = cassette

	emit_signal("slots_changed")

func remove_cassette_from_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slot_cassettes.size():
		return

	var cassette = slot_cassettes[slot_index]
	if cassette != null:
		# Move it back to hand (or discard/lost) if desired
		hand.append(cassette)
		slot_cassettes[slot_index] = null
		emit_signal("slots_changed")

func select_cassettes():
	pass


func prepare_hand(enemy_name):
	var enemy_cassettes = Database.player_deck[enemy_name]
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
