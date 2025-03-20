extends Node2D

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_CASSETTE_SLOT = 2
const COLLISION_MASK_PLAYER_DECK_AREA = 512
const DEFAULT_CASSETTE_SPEED = 0.2

var screen_size
var cassette_being_dragged
var is_hovering_on_cassette
var cassette_hovered_on
var draft_active = false

@onready var player: Node2D = $"../Player"
@onready var commit_sequence_button = $"../CommitSequence"
@onready var audio_stream_player: AudioStreamPlayer = $"../SfxPlayer"
@onready var game_manager: Node2D = $"../GameManager"


func _ready() -> void:
	screen_size = get_viewport_rect().size
	var cassettes = player.hand.get_children()
	for cassette in cassettes:
		connect_cassette_signals(cassette)
	$"../InputManager".left_mouse_button_released.connect(on_left_click_released)



func _process(_delta: float) -> void:
	if game_manager.current_screen == game_manager.SCREEN.BATTLE:
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
	var highest_z_cassette = cassettes[0].collider.get_parent().get_parent()
	var highest_z_index = highest_z_cassette.z_index
	for i in range (1, cassettes.size()):
		var current_cassette = cassettes[i].collider.get_parent().get_parent()
		if current_cassette.z_index > highest_z_index:
			highest_z_cassette = current_cassette
			highest_z_index = current_cassette.z_index
	print(highest_z_cassette.cassette_name+ " was highest Z found cassette")
	return highest_z_cassette


func connect_cassette_signals(cassette):
	cassette.hovered.connect(_on_cassette_hovered)
	cassette.hovered_off.connect(_on_cassette_hovered_off)


func _on_cassette_hovered(cassette) -> void:
	if cassette_hovered_on != null and cassette_hovered_on != cassette:
		print(cassette.cassette_name + " hovered on, but " + cassette_hovered_on.cassette_name + " is already hovered on")
		return
	elif !is_hovering_on_cassette or !cassette_being_dragged:
		print(cassette.cassette_name + " hovered on")
		is_hovering_on_cassette = true
		cassette_hovered_on = cassette
		cassette.update_elements()
		cassette.flip_tooltip.visible = true
		cassette.animation_player.play("Hover_over")
		await get_tree().create_timer(0.1).timeout
		cassette.z_index = 2
		


func _on_cassette_hovered_off(cassette) -> void:
	if cassette.cassette_slot_cassette_is_in or cassette_being_dragged != null:
		return
	is_hovering_on_cassette = false
	cassette.animation_player.play_backwards("Hover_over")
	cassette_hovered_on = null
	cassette.z_index = 0
	var new_cassette_hovered = raycast_check_for_cassette()
	if new_cassette_hovered:
		cassette_hovered_on = new_cassette_hovered
		new_cassette_hovered.set_side(new_cassette_hovered.current_side)
		new_cassette_hovered.update_elements()
		is_hovering_on_cassette = true
		cassette_hovered_on.animation_player.play("Hover_over")
		cassette_hovered_on.z_index = 2
		cassette_hovered_on.flip_tooltip.visible = true


func start_drag(cassette):
	cassette_being_dragged = cassette
	cassette.reparent($"../DragLayer")
	cassette.animation_player.play_backwards("Hover_over")
	print("Should play SwitchToTopSide")
	cassette.animation_player.play("RESET")
	for slot in player.sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("Active")


func finish_drag():
	cassette_being_dragged.scale = cassette_being_dragged.ENLARGED_CASSETTE_SIZE
	var cassette_slot_found = raycast_check_for_slot() 
	if cassette_slot_found and not cassette_slot_found.cassette_in_slot != null:
		cassette_being_dragged.scale = cassette_being_dragged.REGULAR_CASSETTE_SIZE
		cassette_being_dragged.cassette_slot_cassette_is_in = cassette_slot_found
		cassette_being_dragged.flip_tooltip.visible = false
		player.hand.remove_cassette_from_hand(cassette_being_dragged)
		cassette_slot_found.add_child(cassette_being_dragged)
		cassette_being_dragged.position = Vector2(0,0)
		cassette_being_dragged.get_node('Node2D/Area2D/CollisionShape2D').disabled = true
		cassette_slot_found.cassette_in_slot = cassette_being_dragged
		cassette_slot_found.update_elements(true, cassette_being_dragged.current_side, cassette_being_dragged.get_current_side_fuel())
		if check_if_commit_sequence_button_should_be_activated():
			commit_sequence_button.disabled = false
	else:
		cassette_being_dragged.animation_player.play("SwitchToFront")
		player.hand.add_cassette_to_hand(cassette_being_dragged, DEFAULT_CASSETTE_SPEED)
	cassette_being_dragged = null
	for slot in player.sequence.get_children():
		if !slot.cassette_in_slot:
			slot.animation_player.play("RESET")


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
	return space_state.intersect_point(parameters)
