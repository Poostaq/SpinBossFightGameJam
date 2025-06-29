extends Node2D

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_CASSETTE_SLOT = 2
const COLLISION_MASK_PLAYER_DECK_AREA = 512
const DEFAULT_CASSETTE_SPEED = 0.2
const SLOT_POSITIONS = [
						Vector2(773,1100),
						Vector2(775,1055),
						Vector2(777,1010),
						Vector2(779,965),
						Vector2(781,920),
						Vector2(1185,1100),
						Vector2(1183,1055),
						Vector2(1181,1010),
						Vector2(1179,965),
						Vector2(1177,920)]
const CASSETTE_SCALES_IN_SLOTS = [
								  Vector2(0.79,0.79),
								  Vector2(0.78,0.78),
								  Vector2(0.77,0.77),
								  Vector2(0.76,0.76),
								  Vector2(0.75,0.75),
								  Vector2(0.79,0.79),
								  Vector2(0.78,0.78),
								  Vector2(0.77,0.77),
								  Vector2(0.76,0.76),
								  Vector2(0.75,0.75)]
var screen_size
var cassette_being_dragged: Cassette
var is_hovering_on_cassette
var cassette_hovered_on
var draft_active = false

@onready var player: Node = %"Player"
@onready var commit_sequence_button = $"../UI/PlayerUI/CommitSequence"
@onready var ui_animator: Node = $"../UIAnimator"
@onready var drag_layer: Node2D = $"../DragLayer"
@onready var hand: Node2D = $"../UI/PlayerUI/Hand"


func _ready() -> void:
	player.cassette_created.connect(move_cassette_to_hand)
	screen_size = get_viewport_rect().size
	$"../InputManager".left_mouse_button_released.connect(on_left_click_released)



func _process(_delta: float) -> void:
	if cassette_being_dragged:
		var mouse_pos = get_global_mouse_position()
		cassette_being_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))


func raycast_check_for_cassette():
	var hits = _raycast_point(get_global_mouse_position(), COLLISION_MASK_CASSETTE)
	if hits.size() > 0:
		return get_cassette_with_highest_z_index(hits)
	return null


func get_cassette_with_highest_z_index(cassettes):
	var highest_z_cassette = cassettes[0].collider.get_parent()
	var highest_z_index = highest_z_cassette.z_index
	for i in range (1, cassettes.size()):
		var current_cassette = cassettes[i].collider.get_parent()
		if current_cassette.z_index > highest_z_index:
			highest_z_cassette = current_cassette
			highest_z_index = current_cassette.z_index
	return highest_z_cassette


func connect_cassette_signals(cassette: Cassette):
	cassette.hovered.connect(_on_cassette_hovered)
	cassette.hovered_off.connect(_on_cassette_hovered_off)


func _on_cassette_hovered(cassette: Cassette) -> void:
	if is_hovering_on_cassette:
		return
	elif !is_hovering_on_cassette and !cassette_being_dragged:
		is_hovering_on_cassette = true
		cassette.update_elements()
		cassette.set_state(cassette.STATE.HOVERED_OVER)
		


func _on_cassette_hovered_off(cassette: Cassette) -> void:
	if cassette.state == cassette.STATE.IN_SLOT or cassette_being_dragged != null:
		return
	is_hovering_on_cassette = false
	cassette.set_state(cassette.STATE.IN_HAND)
	var new_cassette_hovered = raycast_check_for_cassette()
	
	if new_cassette_hovered:
		_on_cassette_hovered(new_cassette_hovered)


func start_drag(cassette: Cassette):
	cassette_being_dragged = cassette
	deactivate_cassettes(true)
	player.remove_cassette_from_hand(cassette)
	ui_animator.activate_player_slots()
	cassette.reparent($"../DragLayer")
	cassette.set_state(cassette.STATE.DRAGGING)
	for other_cassette: Cassette in hand.get_children():
		if other_cassette.state == other_cassette.STATE.HOVERED_OVER:
			other_cassette.set_state(other_cassette.STATE.IN_HAND)
	

func finish_drag():
	var cassette_slot_found = raycast_check_for_slot() 
	if cassette_slot_found and not cassette_slot_found.cassette_in_slot != null:
		cassette_being_dragged.set_state(cassette_being_dragged.STATE.IN_SLOT)
		cassette_slot_found.add_child(cassette_being_dragged)
		cassette_slot_found.cassette_in_slot = cassette_being_dragged
		cassette_slot_found.update_elements()
		update_hand_positions(DEFAULT_CASSETTE_SPEED)
		update_hand_positions(DEFAULT_CASSETTE_SPEED)
		if check_if_commit_sequence_button_should_be_activated():
			commit_sequence_button.disabled = false
	else:
		cassette_being_dragged.set_state(cassette_being_dragged.STATE.IN_HAND)
		player.hand.append(cassette_being_dragged)
		move_cassette_to_hand(cassette_being_dragged)
	cassette_being_dragged = null
	await ui_animator.deactivate_player_slots()
	deactivate_cassettes(false)


func raycast_check_for_slot():
	var result = _raycast_point(get_global_mouse_position(), COLLISION_MASK_CASSETTE_SLOT)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func on_left_click_released():
	if cassette_being_dragged:
		finish_drag()


func switch_sides(cassette):
	if cassette.current_side == "A":
		cassette.current_side = "B"
		cassette.switch_sides("B")
	else:
		cassette.current_side = "A"
		cassette.switch_sides("A")


func check_if_commit_sequence_button_should_be_activated():
	for slot in player.sequence.get_children():
		if slot.cassette_in_slot == null:
			return false
	return true


func _raycast_point(pos: Vector2, collision_mask: int) -> Array:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = pos
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	parameters.canvas_instance_id = 0
	return space_state.intersect_point(parameters)


func move_cassette_to_hand(cassette):
	if cassette not in hand.get_children():
		if cassette.get_parent() == null:
			hand.add_child(cassette)
			print("ADDED CASSETTE TO HAND")
		else:
			cassette.reparent(hand, true)
			print("CHANGED PARENT FOR CASSETTE TO HAND")
		
		cassette.update_elements()
		update_hand_positions(DEFAULT_CASSETTE_SPEED)
	else:
		cassette.animate_cassette_to_position(cassette.position_in_hand)
		
func update_hand_positions(speed):
	for i in range(player.hand.size()):
		var cassette = player.hand[i]
		cassette.position_in_hand = SLOT_POSITIONS[player.hand.size()-1-i]
		cassette.scale_in_hand = CASSETTE_SCALES_IN_SLOTS[player.hand.size()-1-i]
		cassette.animate_cassette_to_position(cassette.position_in_hand,speed)


func deactivate_cassettes(disabled: bool) -> void:
	for cassette in hand.get_children():
		cassette.collision_shape_2d.disabled = disabled

func _on_eject_button_pressed() -> void:
	for slot in player.sequence.get_children():
		if slot.cassette_in_slot:
			player.add_cassette_to_hand(slot.cassette_in_slot)
			move_cassette_to_hand(slot.cassette_in_slot)
			slot.cassette_in_slot.set_state(slot.cassette_in_slot.STATE.IN_HAND)
			slot.cassette_in_slot = null
			slot.set_cover_state(true)
			slot.update_elements()
			slot.animation_player.play("RESET")
