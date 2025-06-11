extends Node2D
class_name Cassette

signal hovered(cassette: Cassette)
signal hovered_off(cassette: Cassette)

const ENLARGED_CASSETTE_SIZE = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE = Vector2(0.5,0.5)
const DEFAULT_CASSETTE_SPEED = 0.2
const TOP_Y = 40


enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA, MOVE_INFO}
enum STATE {INITIALIZING, IN_HAND, HOVERED_OVER, DRAGGING, IN_SLOT}

const ICON_BEHAVIORS = {
	"attack": ["attack"],
	"attack_special": ["attack", "special"],
	"attack_defence": ["attack", "defence"],
	"defence": ["defence"],
	"defence_special": ["defence", "special"],
	"special": ["special"]
	# Add more if you need them
}

var position_in_hand
var scale_in_hand
var side_a_data
var side_b_data
var cassette_name
var current_side
var whose_cassette
var side_a_actions_path
var side_b_actions_path
var state = STATE.INITIALIZING

@onready var animation_player = $AnimationPlayer
@onready var flip_tooltip: Sprite2D = $FlipTooltip
@onready var side_a: Node2D = $Sprites/SideA
@onready var front_cassette_name_label: Label = $Sprites/Front/CassetteName
@onready var top_cassette_name_label: Label = $Sprites/Top/CassetteName
@onready var side_a_fuel_label: Label = $Sprites/SideA/Fuel/Label
@onready var actions_sprite: Sprite2D = $Sprites/SideA/Actions
@onready var action_icon1: Sprite2D = $Sprites/SideA/Icon1
@onready var icon1_label: Label = $Sprites/SideA/Icon1/Label
@onready var action_icon2: Sprite2D = $Sprites/SideA/Icon2
@onready var icon2_label: Label = $Sprites/SideA/Icon2/Label
@onready var side_a_after_play: Sprite2D = $Sprites/SideA/AfterPlay
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	flip_tooltip.visible = false
	hovered_off.emit(self)


func update_elements():
	front_cassette_name_label.text = cassette_name
	top_cassette_name_label.text = cassette_name
	var side_data = get_current_side_data()
	side_a_fuel_label.text = str(side_data["fuel_cost"])
	_display_action_icons(side_data, action_icon1, icon1_label, action_icon2, icon2_label)
	set_icon(side_data["after_play"], side_a_after_play)
	update_actions_texture()



func get_current_side_fuel():
	if current_side == "A":
			return side_a_data["fuel_cost"]
	elif current_side == "B":
			return side_b_data["fuel_cost"]
	else:
			return ""

func update_actions_texture() -> void:
	if current_side == "A" and side_a_actions_path:
			actions_sprite.texture = load(side_a_actions_path)
	elif current_side == "B" and side_b_actions_path:
			actions_sprite.texture = load(side_b_actions_path)


func parse_cassette_actions(actions: Array) -> Dictionary:
	var result = {
		"attack": 0,
		"defence": 0,
		"special": 0
	}

	for action in actions:
		var move_type = action["action_type"]
		
		var value = action["value"] if "value" in action.keys() and str(action["value"]) != "" else 0

		match move_type:
			"attack":
				result["attack"] += value
			"defence":
				result["defence"] += value
			"special":
				result["special"] += value

	return result


func set_icon_value(icon_info: Dictionary, label: Label) -> void:
	label.text = _get_value_text(icon_info)

# Display up to two action icons and their values
func _get_filtered_icons(action_data: Dictionary) -> Array:
	var icons = action_data.get("action_icons", [])
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
	return str(val)

func _display_action_icons(action_data: Dictionary, icon1: Sprite2D, label1: Label, icon2: Sprite2D, label2: Label) -> void:
	var icons = _get_filtered_icons(action_data)
	if icons.size() > 0:
			var info = icons[0]
			icon1.texture = load("res://Images/action_icons/%s.png" % info.get("icon", ""))
			label1.text = _get_value_text(info)
			icon1.visible = true
	else:
			icon1.visible = false
			label1.text = ""
	if icons.size() > 1:
			var info2 = icons[1]
			icon2.texture = load("res://Images/action_icons/%s.png" % info2.get("icon", ""))
			label2.text = _get_value_text(info2)
			icon2.visible = true
	else:
			icon2.visible = false
			label2.text = ""


func array_join(arr: Array, sep: String) -> String:
	var result := ""
	for i in range(arr.size()):
		if i > 0:
			result += sep
		result += str(arr[i])
	return result
	

func animate_cassette_to_position(new_position, speed = DEFAULT_CASSETTE_SPEED):
	collision_shape_2d.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, speed)
	await tween.finished
	collision_shape_2d.disabled = false


func get_current_side_data():
	if current_side == "A":
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

func switch_sides(current_preview_side):
	var tween = create_tween()
	if current_preview_side == "A":
			play_animation("SwitchToOtherSide", true)
			if side_b_actions_path:
					actions_sprite.texture = load(side_b_actions_path)
			tween.tween_property(side_a, "scale", Vector2(1.1, 1.1), 0.1)
			tween.parallel().tween_property(side_a, "modulate", Color(1,1,1,1),0.1)
			tween.parallel().tween_property($Sprites/SideB, "scale", Vector2(0.8,0.8), 0.1)
			tween.parallel().tween_property($Sprites/SideB, "modulate", Color(1,1,1,0.5),0.1)

	else:
			play_animation("SwitchToOtherSide")
			if side_a_actions_path:
					actions_sprite.texture = load(side_a_actions_path)
			tween.tween_property($Sprites/SideB, "scale", Vector2(1.1, 1.1), 0.1)
			tween.parallel().tween_property($Sprites/SideB, "modulate", Color(1,1,1,1),0.1)
			tween.parallel().tween_property(side_a, "scale", Vector2(0.8,0.8), 0.1)
			tween.parallel().tween_property(side_a, "modulate", Color(1,1,1,0.5),0.1)


func set_side(cassette_current_side):
		if cassette_current_side == "A":
				side_a.scale= Vector2(1.1, 1.1)
				side_a.modulate = Color(1,1,1,1)
				$Sprites/SideB.scale = Vector2(0.8,0.8)
				$Sprites/SideB.modulate = Color(1,1,1,0.5)
				$Sprites/Front/ASideLogo.scale = Vector2(0.5,0.5)
				$Sprites/Front/BSideLogo.scale = Vector2(0.3,0.3)
		else:
				$Sprites/SideB.scale= Vector2(1.1, 1.1)
				$Sprites/SideB.modulate = Color(1,1,1,1)
				side_a.scale = Vector2(0.8,0.8)
				side_a.modulate = Color(1,1,1,0.5)
				$Sprites/Front/ASideLogo.scale = Vector2(0.3,0.3)
				$Sprites/Front/BSideLogo.scale = Vector2(0.5,0.5)

		update_actions_texture()


func set_icon(icon_name, element):
	element.texture = load("res://Images/action_icons/"+icon_name+".png")


# 3) Single setter method
func set_state(new_state: STATE) -> void:
	if new_state == state:
		return
	if not _can_transition(state, new_state):
		return

	# Exit old
	match state:
		STATE.INITIALIZING:_exit_initializing()
		STATE.IN_HAND:     _exit_in_hand()
		STATE.HOVERED_OVER:_exit_hovered_over()
		STATE.DRAGGING:    _exit_dragging()
		STATE.IN_SLOT:     _exit_in_slot()

	state = new_state

	# Enter new
	match state:
		STATE.IN_HAND:     _enter_in_hand()
		STATE.HOVERED_OVER:_enter_hovered_over()
		STATE.DRAGGING:    _enter_dragging()
		STATE.IN_SLOT:     _enter_in_slot()

# 4) Transition rules
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

# 5) Enter/Exit hooks

func _exit_initializing():
	pass
	

func _enter_in_hand():
	z_index = 2

func _exit_in_hand():
	pass

func _enter_hovered_over():
	flip_tooltip.visible = true
	z_index = 4
	play_animation("Hover_over")

func _exit_hovered_over():
	
	flip_tooltip.visible = false
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
