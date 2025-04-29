extends Node


const CASSETTE_SCENE = "res://Scenes/cassette.tscn"
# Signals to notify others of changes
signal deck_changed(new_deck)  # deck or hand changed
signal selection_changed       # selected cassettes changed
signal slots_changed           # slot cassettes changed
signal cassette_created(cassette)

# Core cassette containers
var deck: Array = []            # Full deck of cassettes
var discard: Array = []         # Discarded cassettes
var lost: Array = []            # Completely lost cassettes
var hand: Array = []            # Cassettes currently in the player's (logical) hand

@onready var cassette_manager: Node2D = %CassetteManager

var slot_cassettes: Array = [null, null, null]
var health: int = 20
var selected_cassettes: Array = []

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
	new_cassette.side_a_data = Database.cassettes["cassettes"][cassette_name]["side_a"]
	new_cassette.side_b_data = Database.cassettes["cassettes"][cassette_name]["side_b"]
	new_cassette.cassette_name = cassette_name
	new_cassette.current_side = "A"
	new_cassette.whose_cassette = GlobalEnums.PLAYER
	cassette_manager.connect_cassette_signals(new_cassette)
	return new_cassette

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


# --- Slot Logic ---
func put_cassette_in_slot(cassette, slot_index: int) -> void:
	# Validate slot_index
	if slot_index < 0 or slot_index >= slot_cassettes.size():
		return

	# If slot is occupied, return old cassette to hand (or discard) depending on your design
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
		# Move it back to hand (or discard/lost) as you desire
		hand.append(cassette)
		slot_cassettes[slot_index] = null
		emit_signal("slots_changed")


# --- Selection Logic (if you still use selected_cassettes) ---
func has_selected_required_cassettes() -> bool:
	# Example requirement: exactly 3
	return selected_cassettes.size() == 3

func select_cassette(cassette):
	if cassette in hand and not has_selected_required_cassettes():
		hand.erase(cassette)
		selected_cassettes.append(cassette)
		emit_signal("selection_changed")

func deselect_cassette(cassette):
	if cassette in selected_cassettes:
		selected_cassettes.erase(cassette)
		hand.append(cassette)
		emit_signal("selection_changed")

func get_chosen_cassettes() -> Array:
	return selected_cassettes

func remove_cassette_from_hand(cassette):
	hand.remove_at(hand.find(cassette))
