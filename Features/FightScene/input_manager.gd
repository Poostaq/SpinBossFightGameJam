extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CASSETTE = 1
const COLLISION_MASK_DECK = 4
enum SCREEN {MENU, STORY, BATTLE, DRAFT}

@onready var cassette_manager: Node2D = %CassetteManager

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("IM PRESSING LEFT MOUSE BUTTON")
			left_mouse_button_clicked.emit()
			left_click_raycast(COLLISION_MASK_CASSETTE)
		else:
			left_mouse_button_released.emit()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			print("IM PRESSING RIGHT MOUSE BUTTON")
			right_click_raycast()

func left_click_raycast(collision_mask):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var cassette_found: Cassette = result[0].collider.get_parent()
		if cassette_found:
			print("Cassette Found, start dragging")
			cassette_manager.start_drag(cassette_found)
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
			var cassette_found = result[0].collider.get_parent()
			if cassette_found:
				cassette_found.switch_sides()
				
