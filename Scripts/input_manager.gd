extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_DECK = 4
const COLLISION_MASK_DECKBUILD_CASSETTE = 65536
const CASSETTE_RATTLE = preload("res://sfx/652388__department64__cassette-tape-rattle-69.ogg")
enum SCREEN {MENU, STORY, BATTLE, DRAFT}

@onready var cassette_manager: Node2D = %CassetteManager
@onready var player_deck: Node2D = $"../Player/Deck"
@onready var player_hand: Node2D = $"../Player/Hand"
@onready var game_manager: Node2D = $"../GameManager"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_mouse_button_clicked.emit()
			if game_manager.current_screen == SCREEN.BATTLE:
				left_click_raycast(COLLISION_MASK_CASSETTE,"Regular")
			elif game_manager.current_screen == SCREEN.DRAFT:
				left_click_raycast(COLLISION_MASK_CASSETTE,"Draft")
				
		else:
			left_mouse_button_released.emit()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			right_click_raycast()

func left_click_raycast(collision_mask, cassette_type):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		var cassette_found = result[0].collider.get_parent().get_parent()
		if cassette_found:
			if cassette_type == "Regular":
				cassette_manager.start_drag(cassette_found)
			elif cassette_type == "Draft":
				cassette_manager.start_drag_deckbuild(cassette_found)
			cassette_manager.audio_stream_player.stream = CASSETTE_RATTLE
			cassette_manager.audio_stream_player.play()
		#

func right_click_raycast():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CASSETTE:
			var cassette_found = result[0].collider.get_parent().get_parent()
			if cassette_found:
				cassette_manager.switch_sides(cassette_found)
				
