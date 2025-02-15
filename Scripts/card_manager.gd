extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2
const ENLARGED_CARD_SIZE = Vector2(0.75,0.75)
const REGULAR_CARD_SIZE = Vector2(0.6,0.6)
const SMALLER_CARD_SIZE = Vector2(0.5,0.5)
const DEFAULT_CARD_SPEED = 0.1

var screen_size
var card_being_dragged
var is_hovering_on_card
@onready var player_hand_reference = $"../PlayerHand"

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var cards = self.get_children()
	for card in cards:
		connect_card_signals(card)
	$"../InputManager".left_mouse_button_released.connect(on_left_click_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))


func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range (1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card

func connect_card_signals(card):
	card.hovered.connect(_on_card_hovered)
	card.hovered_off.connect(_on_card_hovered_off)


func _on_card_hovered(card) -> void:
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)


func _on_card_hovered_off(card) -> void:
	if card.card_slot_card_is_in and card_being_dragged:
		return
	highlight_card(card, false)
	var new_card_hovered = raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else:
		is_hovering_on_card = false

func highlight_card(card, hovered):
	if hovered:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "scale", ENLARGED_CARD_SIZE, 0.08)
		card.z_index = 2
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "scale", REGULAR_CARD_SIZE, 0.08)
		card.z_index = 1

func start_drag(card):
	card_being_dragged = card
	card_being_dragged.scale = REGULAR_CARD_SIZE
	
func finish_drag():
	card_being_dragged.scale = ENLARGED_CARD_SIZE
	var card_slot_found = raycast_check_for_slot() 
	if card_slot_found and not card_slot_found.card_in_slot:
		card_being_dragged.scale = SMALLER_CARD_SIZE
		card_being_dragged.z_index = -1
		card_being_dragged.card_slot_card_is_in = card_slot_found
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node('Area2D/CollisionShape2D').disabled = true
		card_slot_found.card_in_slot = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_SPEED)
	card_being_dragged = null


func raycast_check_for_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func on_left_click_released():
	if card_being_dragged:
		finish_drag()
	print("card Manager left mouse released")
