extends Node2D

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_CASSETTE_SLOT = 2
const COLLISION_MASK_PLAYER_DECK_AREA = 512
const DEFAULT_CASSETTE_SPEED = 0.2

var screen_size
var cassette_being_dragged: Cassette
var is_hovering_on_cassette
var cassette_hovered_on
var draft_active = false

@onready var player: Node = %"Player"
@onready var commit_sequence_button = $"../UI/PlayerUI/CommitSequence"
@onready var ui_animator: Node = $"../UIAnimator"
@onready var drag_layer: Node2D = $"../DragLayer"


func _ready() -> void:
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
		print(cassette.cassette_name + " hovered on, but another one is already hovered on")
		return
	elif !is_hovering_on_cassette and !cassette_being_dragged:
		cassette.z_index = 2
		print(cassette.cassette_name + " hovered on")
		is_hovering_on_cassette = true
		cassette.update_elements()
		cassette.set_state(cassette.STATE.HOVERED_OVER)
		


func _on_cassette_hovered_off(cassette: Cassette) -> void:
	if cassette.state == cassette.STATE.IN_SLOT or cassette_being_dragged != null:
		return
	is_hovering_on_cassette = false
	cassette.set_state(cassette.STATE.IN_HAND)
	cassette.z_index = 0
	var new_cassette_hovered = raycast_check_for_cassette()
	if new_cassette_hovered:
		print(cassette.cassette_name + " hovered off, " + new_cassette_hovered.cassette_name + " hovered on")
		_on_cassette_hovered(new_cassette_hovered)


func start_drag(cassette: Cassette):
	cassette_being_dragged = cassette
	ui_animator.make_cassette_colliders(true)
	player.remove_cassette_from_hand(cassette)
	ui_animator.activate_player_slots()
	cassette.reparent($"../DragLayer")
	cassette.set_state(cassette.STATE.DRAGGING)
	for other_cassette: Cassette in ui_animator.hand.get_children():
		if other_cassette.state == other_cassette.STATE.HOVERED_OVER:
			other_cassette.skip_animation("Hover_over", true)
	


func finish_drag():
	var cassette_slot_found = raycast_check_for_slot() 
	if cassette_slot_found and not cassette_slot_found.cassette_in_slot != null:
		cassette_being_dragged.set_state(cassette_being_dragged.STATE.IN_SLOT)
		cassette_slot_found.add_child(cassette_being_dragged)
		cassette_slot_found.cassette_in_slot = cassette_being_dragged
		cassette_slot_found.update_elements(true, cassette_being_dragged.current_side, cassette_being_dragged.get_current_side_fuel())
		if check_if_commit_sequence_button_should_be_activated():
			commit_sequence_button.disabled = false
	else:
		cassette_being_dragged.set_state(cassette_being_dragged.STATE.IN_HAND)
		player.hand.append(cassette_being_dragged)
		ui_animator.move_cassette_to_hand(cassette_being_dragged)
	cassette_being_dragged = null
	ui_animator.deactivate_player_slots()
	ui_animator.make_cassette_colliders(false)


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
	var should_be_activated = true
	for slot in player.sequence.get_children():
		if slot.cassette_in_slot == null:
			return false
	return should_be_activated


func _raycast_point(pos: Vector2, collision_mask: int) -> Array:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = pos
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	parameters.canvas_instance_id = 0
	return space_state.intersect_point(parameters)
