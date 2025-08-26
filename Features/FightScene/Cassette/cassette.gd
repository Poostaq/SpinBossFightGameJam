extends Node2D
class_name Cassette

signal hovered(cassette: Cassette)
signal hovered_off(cassette: Cassette)

const ENLARGED_CASSETTE_SIZE: Vector2 = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE: Vector2  = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE: Vector2 = Vector2(0.5,0.5)
const DEFAULT_CASSETTE_SPEED: float  = 0.2
const TOP_Y: int                    = 40
const A_ICON                   = preload("res://Images/action_icons/a_side.png")
const B_ICON                   = preload("res://Images/action_icons/b_side.png")
const ActionValue: PackedScene = preload("res://Features/FightScene/Cassette/ActionValue.tscn")

enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA, MOVE_INFO}
enum STATE {INITIALIZING, IN_HAND, HOVERED_OVER, DRAGGING, IN_SLOT}
enum Side {A,B}

var position_in_hand
var scale_in_hand
var side_a_data
var side_b_data
var cassette_name
var current_side
var whose_cassette
var side_a_actions_path
var side_b_actions_path
var state: int = STATE.INITIALIZING

@onready var animation_player = $AnimationPlayer
@onready var flip_tooltip: Sprite2D = $FlipTooltip
@onready var action_data: Node2D = $Sprites/ActionData
@onready var front_cassette_name_label: Label = $Sprites/Front/CassetteName
@onready var top_cassette_name_label: Label = $Sprites/Top/CassetteName
@onready var action_data_fuel_label: Label = $Sprites/ActionData/Fuel/Label
@onready var actions_sprite: Sprite2D = $Sprites/ActionData/Actions
@onready var action_icon1: Node2D = $Sprites/ActionData/Icon1
@onready var action_icon2: Node2D = $Sprites/ActionData/Icon2
@onready var action_data_after_play: Sprite2D = $Sprites/ActionData/AfterPlay
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var side_logo: Sprite2D = $Sprites/Front/SideLogo
@onready var action_icons: Array[Variant] = [action_icon1, action_icon2]


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)


func setup_player_cassette(cassette_data_name, cassette_info):
	scale = REGULAR_CASSETTE_SIZE
	name = cassette_data_name
	side_a_data = cassette_info["side_a"]
	side_b_data = cassette_info["side_b"]
	side_a_actions_path = cassette_info["image_a"]
	side_b_actions_path = cassette_info["image_b"]
	cassette_name = cassette_data_name
	current_side = Side.A
	whose_cassette = GlobalEnums.PLAYER


func setup_enemy_cassette(new_cassette_name, cassette_info):
	scale = SMALLER_CASSETTE_SIZE
	name = new_cassette_name
	side_a_data = cassette_info["side_a"]
	side_b_data = cassette_info["side_b"]
	cassette_name = new_cassette_name
	current_side = Side.A
	whose_cassette = GlobalEnums.ENEMY
	state = STATE.IN_HAND


func update_elements():
	front_cassette_name_label.text = cassette_name
	top_cassette_name_label.text = cassette_name
	var side_data = get_current_side_data()
	action_data_fuel_label.text = str(int(side_data["fuel_cost"]))
	update_actions_texture()
	_display_action_icons(side_data)
	_display_action_labels(side_data)
	set_icon(side_data["after_play"], action_data_after_play)
	set_side_icon()


func get_current_side_fuel():
	if current_side == Side.A:
		return side_a_data["fuel_cost"]
	elif current_side == Side.B:
		return side_b_data["fuel_cost"]
	else:
		return ""


func update_actions_texture() -> void:
	if current_side == Side.A and side_a_actions_path:
			actions_sprite.texture = load(side_a_actions_path)
	elif current_side == Side.B and side_b_actions_path:
			actions_sprite.texture = load(side_b_actions_path)


func set_icon_value(icon_info: Dictionary, label: Label) -> void:
	label.text = _get_value_text(icon_info)


func _get_filtered_icons(data: Dictionary) -> Array:
	var icons = data.get("action_icons", [])
	var result: Array = []
	for info in icons:
			var icon_name = str(info.get("icon", ""))
			if icon_name in ["slow_down", "line_up", "overtake"]:
					continue
			result.append(info)
			if result.size() >= 2:
					break
	return result


func _get_value_text(info: Dictionary) -> String:
	if not info.has("value"):
			return ""
	var val = info["value"]
	if val == 0 or str(val) == "":
			return ""
	return str(int(val))


func _display_action_icons(data: Dictionary) -> void:
	var icons = _get_filtered_icons(data)
	for icon in action_icons:
		icon.visible = false
		icon.get_node("Label").text = ""
	for i in range(0, min(len(icons), action_icons.size())):
		action_icons[i].visible = true
		var info = icons[i]
		var texture = action_icons[i].get_node("Sprite")
		texture.texture = load("res://Images/action_icons/%s.png" % info.get("icon", ""))
		var label = action_icons[i].get_node("Label")
		set_icon_value(info, label)


func _display_action_labels(data: Dictionary) -> void:
	for child in actions_sprite.get_children():
		child.queue_free()
	var labels = data.get("action_labels", [])
	for info in labels:
		var new_label = ActionValue.instantiate()
		actions_sprite.add_child(new_label)
		new_label.text = str(int(info.get("value", "")))
		new_label.set_deferred("size", Vector2(190,190))
		new_label.set_deferred("position", Vector2(info.get("x_position", 0), info.get("y_position", 0)))
		# new_label.size = Vector2(190,190)
		# new_label.position = Vector2(info.get("x_position", 0), info.get("y_position", 0))
		var scale_val = info.get("scale", 1)
		new_label.scale = Vector2(scale_val, scale_val)


#func array_join(arr: Array, sep: String) -> String:
	#var result := ""
	#for i in range(arr.size()):
		#if i > 0:
			#result += sep
		#result += str(arr[i])
	#return result
	

func animate_cassette_to_position(new_position, speed = DEFAULT_CASSETTE_SPEED):
	collision_shape_2d.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, speed)
	await tween.finished
	collision_shape_2d.disabled = false


func get_current_side_data():
	if current_side == Side.A:
		return side_a_data
	else:
		return side_b_data


func play_animation(anim_name: String, reversed: bool = false) -> void:
	if animation_player.is_playing():
		var old_name = animation_player.current_animation
		if old_name != "":
			var old_data: Animation = animation_player.get_animation(old_name)
			if old_data:
				if animation_player.get_playing_speed() < 0:
					animation_player.seek(0, true)
				elif animation_player.get_playing_speed() > 0:
					animation_player.seek(old_data.length, true)
	if reversed:
		animation_player.play_backwards(anim_name)
	else:
		animation_player.play(anim_name)

func skip_animation(anim_name: String, reversed: bool = false) -> void:
	if animation_player.is_playing():
		var old_name = animation_player.current_animation
		if old_name != "":
			var old_data = animation_player.get_animation(old_name)
			if old_data:
				if animation_player.speed_scale < 0:
					animation_player.seek(0, true)
				else:
					animation_player.seek(old_data.length, true)
	var new_data = animation_player.get_animation(anim_name)
	if new_data == null:
		push_error("Animation '%s' not found!" % anim_name)
		return
	if reversed:
		animation_player.play_backwards(anim_name)
		animation_player.seek(0, true)
	else:
		animation_player.play(anim_name)
		animation_player.seek(new_data.length, true)


func switch_sides():
	if current_side == Side.A:
		current_side = Side.B
	elif current_side == Side.B:
		current_side = Side.A
	else:
		print("SOMETHING DIDN'T WORK, I'M NOT SWITCHING SIDE")
		return
	action_data.visible = false
	play_animation("SwitchToOtherSide")


func set_icon(icon_name, element):
	element.texture = load("res://Images/action_icons/"+icon_name+".png")


func set_side_icon():
	if current_side == Side.A:
		side_logo.texture = A_ICON
	elif current_side == Side.B:
		side_logo.texture = B_ICON


func set_state(new_state: STATE) -> void:
	if new_state == state:
		return
	if not _can_transition(state, new_state):
		return

	match state:
		STATE.INITIALIZING:_exit_initializing()
		STATE.IN_HAND:     _exit_in_hand()
		STATE.HOVERED_OVER:_exit_hovered_over()
		STATE.DRAGGING:    _exit_dragging()
		STATE.IN_SLOT:     _exit_in_slot()

	state = new_state

	match state:
		STATE.IN_HAND:     _enter_in_hand()
		STATE.HOVERED_OVER:_enter_hovered_over()
		STATE.DRAGGING:    _enter_dragging()
		STATE.IN_SLOT:     _enter_in_slot()


func _can_transition(from: STATE, to: STATE) -> bool:
	match from:
		STATE.INITIALIZING:
			return to == STATE.IN_HAND
		STATE.IN_HAND:
			return to in [ STATE.HOVERED_OVER, STATE.DRAGGING ]
		STATE.HOVERED_OVER:
			return to in [ STATE.IN_HAND, STATE.DRAGGING ]
		STATE.DRAGGING:
			return to in [ STATE.IN_SLOT, STATE.IN_HAND ]
		STATE.IN_SLOT:
			return to in [ STATE.DRAGGING, STATE.IN_HAND ]
		_:
			return false


func _exit_initializing():
	pass


func _enter_in_hand():
	z_index = 2

func _exit_in_hand():
	pass


func _enter_hovered_over():
	z_index = 4
	play_animation("Hover_over")


func _exit_hovered_over():
	play_animation("Hover_over", true)


func _enter_dragging():
	z_index = 4
	play_animation("SwitchToFront", true)


func _exit_dragging():
	play_animation("SwitchToFront")
	self.get_parent().remove_child(self)


func _enter_in_slot():
	flip_tooltip.visible = false
	z_index = 0
	skip_animation("SwitchToFront", true)
	self.position = Vector2(0,0)


func _exit_in_slot():
	play_animation("SwitchToFront")


func clear_cassette_name():
	top_cassette_name_label.text = ""
