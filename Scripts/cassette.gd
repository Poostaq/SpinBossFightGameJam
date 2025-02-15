extends Node2D

signal hovered(cassette)
signal hovered_off(cassette)

const ENLARGED_CASSETTE_SIZE = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE = Vector2(0.5,0.5)
const TOP_Y = 40


enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
var position_in_hand
var rotation_in_hand
var scale_in_hand
var z_position_in_hand
var cassette_slot_cassette_is_in
var cassette_side_a
var cassette_side_b
var cassette_name
var current_side
var tween_hover
var tween_rotation
var whose_cassette

@onready var animation_player = $AnimationPlayer
@onready var flip_tooltip: Sprite2D = $FlipTooltip


func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)
	#highlight_cassette(true)
	#print(cassette_name + " hovered on")


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
	#highlight_cassette(false)
	#print(cassette_name + " hovered off")

func highlight_cassette(should_highlight):
	#if tween_hover and tween_hover.is_running():
		#tween_hover.kill()
	#tween_hover = create_tween()
	if should_highlight:
		#tween_hover.tween_property(self, "scale", ENLARGED_CASSETTE_SIZE, 0.1)
		animation_player.play("Hover_over")
	else:
		#tween_hover.tween_property(self, "scale", scale_in_hand, 0.1)
		animation_player.play_backwards("Hover_over")

func update_elements():
	$Front/CassetteName.text = cassette_name
	$Top/CassetteName.text = cassette_name
	$SideA/Fuel/Label.text = str(cassette_side_a[CASSETTE_SIDE_DATA.FUEL_COST])
	$SideA/Description.text = cassette_side_a[CASSETTE_SIDE_DATA.DESCRIPTION]
	$SideB/Fuel/Label.text = str(cassette_side_b[CASSETTE_SIDE_DATA.FUEL_COST])
	$SideB/Description.text = cassette_side_b[CASSETTE_SIDE_DATA.DESCRIPTION]
	$SideA/Icon.texture = load("res://Images/action_icons/"+cassette_side_a[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	$SideB/Icon.texture = load("res://Images/action_icons/"+cassette_side_b[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")

func get_current_side_fuel():
	if current_side == "A":
		return cassette_side_a[CASSETTE_SIDE_DATA.FUEL_COST]
	elif current_side == "B":
		return cassette_side_b[CASSETTE_SIDE_DATA.FUEL_COST]
	else:
		return ""

func set_name_labels():
	$Front/CassetteName.text = cassette_name
	$Top/CassetteName.text = cassette_name

func animate_cassette_to_position(new_position, speed, new_rotation=0):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, speed)
	tween.parallel().tween_property(self, "rotation_degrees", new_rotation, speed)
	await tween.finished


func get_current_action():
	if current_side == "A":
		return cassette_side_a
	else:
		return cassette_side_b
	
func set_front_visible():
	self.animation_player.play("SwitchToFront")
	
