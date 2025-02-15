extends Node2D

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_CASSETTE_SLOT = 2
const COLLISION_MASK_PLAYER_DECK_AREA = 512
const DEFAULT_CASSETTE_SPEED = 0.2

var screen_size
var cassette_being_dragged
var cassette_deckbuild_being_dragged
var is_hovering_on_cassette
var cassette_hovered_on

@onready var player: Node2D = $"../Player"
@onready var preview_cassette = $"../PreviewCassette"
@onready var commit_sequence_button = $"../CommitSequence"
@onready var audio_stream_player: AudioStreamPlayer = $"../SfxPlayer"
@onready var cassette_draft: Node2D = $"../CassetteDraft"


func _ready() -> void:
	screen_size = get_viewport_rect().size
	var cassettes = player.hand.get_children()
	for cassette in cassettes:
		connect_cassette_signals(cassette)
	$"../InputManager".left_mouse_button_released.connect(on_left_click_released)



func _process(_delta: float) -> void:
	if cassette_being_dragged:
		var mouse_pos = get_global_mouse_position()
		cassette_being_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))
	if cassette_deckbuild_being_dragged:
		var mouse_pos = get_global_mouse_position()
		cassette_deckbuild_being_dragged.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))


func raycast_check_for_cassette():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CASSETTE
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		print(result)
		return get_cassette_with_highest_z_index(result)
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
	elif !is_hovering_on_cassette:
		print(cassette.cassette_name + " hovered on")
		is_hovering_on_cassette = true
		cassette_hovered_on = cassette
		preview_cassette.set_preview_side(cassette.current_side)
		fill_preview_casette(cassette)
		preview_cassette.visible = true
		cassette_hovered_on.flip_tooltip.visible = true
		cassette_hovered_on.animation_player.play("Hover_over")
		cassette_hovered_on.z_index = 80
		


func _on_cassette_hovered_off(cassette) -> void:
	if cassette.cassette_slot_cassette_is_in or cassette_being_dragged != null:
		return
	
	cassette_hovered_on.flip_tooltip.visible = false
	cassette_hovered_on.animation_player.play_backwards("Hover_over")
	cassette_hovered_on.z_index = cassette_hovered_on.z_position_in_hand
	is_hovering_on_cassette = false
	preview_cassette.visible = false
	cassette_hovered_on = null
	var new_cassette_hovered = raycast_check_for_cassette()
	if new_cassette_hovered:
		cassette_hovered_on = new_cassette_hovered
		preview_cassette.set_preview_side(new_cassette_hovered.current_side)
		fill_preview_casette(new_cassette_hovered)
		preview_cassette.visible = true
		is_hovering_on_cassette = true
		cassette_hovered_on.animation_player.play("Hover_over")
		cassette_hovered_on.z_index = 80
		cassette_hovered_on.flip_tooltip.visible = true


func fill_preview_casette(cassette):
	preview_cassette.cassette_side_a = cassette.cassette_side_a
	preview_cassette.cassette_side_b = cassette.cassette_side_b
	preview_cassette.name = cassette.name
	preview_cassette.cassette_name = cassette.cassette_name
	preview_cassette.update_elements()


func start_drag(cassette):
	cassette_being_dragged = cassette
	cassette.animation_player.play_backwards("SwitchToFront")

func start_drag_deckbuild(cassette):
	cassette_deckbuild_being_dragged = cassette


func finish_drag_deckbuild():
	var player_deck_area = raycast_check_for_player_deck_area() 
	print(cassette_deckbuild_being_dragged.get_parent())
	if player_deck_area and len(player_deck_area.get_children()) < 10:
		cassette_draft.remove_from_available_cassettes(cassette_deckbuild_being_dragged)
		cassette_draft.player_cassettes.add_child(cassette_deckbuild_being_dragged)
		cassette_deckbuild_being_dragged.position = Vector2(0,0)
		is_hovering_on_cassette = false
		cassette_draft.deckbuilder_cassette_preview.visible = false
		cassette_draft.update_player_cassettes_column_positions()
	else:
		if cassette_deckbuild_being_dragged.get_parent() == cassette_draft.player_cassettes:
			cassette_draft.player_cassettes.remove_child(cassette_deckbuild_being_dragged)
			cassette_draft.add_to_available_cassettes(cassette_deckbuild_being_dragged)
		elif cassette_deckbuild_being_dragged.get_parent() == cassette_draft.available_cassettes_column or \
		 cassette_deckbuild_being_dragged.get_parent() == cassette_draft.available_cassettes_column_2:
			cassette_draft.update_available_cassettes_column_positions()
		else:
			cassette_draft.add_to_reward_cassettes(cassette_deckbuild_being_dragged)
			cassette_draft.update_reward_cassettes_column_positions()
	cassette_deckbuild_being_dragged = null
	cassette_draft.update_player_cassette_count()
	cassette_draft.check_if_select_deck_button_activate()

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
		preview_cassette.visible = false
		if check_if_commit_sequence_button_should_be_activated():
			commit_sequence_button.disabled = false
	else:
		#cassette_being_dragged.animation_player.play("SwitchToFront")
		player.hand.add_cassette_to_hand(cassette_being_dragged, DEFAULT_CASSETTE_SPEED)
	cassette_being_dragged = null


func raycast_check_for_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CASSETTE_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_player_deck_area():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_PLAYER_DECK_AREA
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func on_left_click_released():
	if cassette_being_dragged:
		finish_drag()
	if cassette_deckbuild_being_dragged:
		finish_drag_deckbuild()


func switch_sides(cassette):
	if cassette.current_side == "A":
		cassette.current_side = "B"
		preview_cassette.switch_preview_sides("B")
	else:
		cassette.current_side = "A"
		preview_cassette.switch_preview_sides("A")


func check_if_commit_sequence_button_should_be_activated():
	var should_be_activated = true
	for slot in player.sequence.get_children():
		if slot.cassette_in_slot == null:
			return false
	return should_be_activated
