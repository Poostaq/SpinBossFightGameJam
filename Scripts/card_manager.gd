extends Node2D

const COLLISION_MASK_CARD = 1

var screen_size
var card_being_dragged

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var cards = self.get_children()
	for card in cards:
		connect_card_signals(card)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x),
		clamp(mouse_pos.y, 0, screen_size.y))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				card_being_dragged = card
		else:
			card_being_dragged = null

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func connect_card_signals(card):
	card.hovered.connect(_on_card_hovered)
	card.hovered_off.connect(_on_card_hovered_off)


func _on_card_hovered(card) -> void:
	card_highlighting(card, true)


func _on_card_hovered_off(card) -> void:
	card_highlighting(card, false)

func card_highlighting(card, hovered):
	if hovered:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.08)
		#card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "scale", Vector2(1.00, 1.00), 0.08)
		#card.scale = Vector2(1,1)
		card.z_index = 1
