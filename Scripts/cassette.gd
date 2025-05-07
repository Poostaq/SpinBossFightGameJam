extends Node2D
class_name Cassette

signal hovered(cassette: Cassette)
signal hovered_off(cassette: Cassette)

const ENLARGED_CASSETTE_SIZE = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE = Vector2(0.5,0.5)
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
var cassette_slot_cassette_is_in
var side_a_data
var side_b_data
var cassette_name
var current_side
var tween_hover
var whose_cassette
var state = STATE.INITIALIZING

@onready var animation_player = $AnimationPlayer
@onready var flip_tooltip: Sprite2D = $FlipTooltip
@onready var side_a: Node2D = $Sprites/SideA
@onready var side_b: Node2D = $Sprites/SideB
@onready var front_cassette_name_label: Label = $Sprites/Front/CassetteName
@onready var top_cassette_name_label: Label = $Sprites/Top/CassetteName
@onready var side_a_fuel_label: Label = $Sprites/SideA/Fuel/Label
@onready var side_b_fuel_label: Label = $Sprites/SideB/Fuel/Label
@onready var side_a_description: RichTextLabel = $Sprites/SideA/Description
@onready var side_b_description: RichTextLabel = $Sprites/SideB/Description
@onready var side_a_move_type_icon: Sprite2D = $Sprites/SideA/MoveType
@onready var side_b_move_type_icon: Sprite2D = $Sprites/SideB/MoveType
@onready var side_a_move_type_label: Label = $Sprites/SideA/MoveType/Label
@onready var side_b_move_type_label: Label = $Sprites/SideB/MoveType/Label
@onready var side_a_attack_targets: Sprite2D = $Sprites/SideA/AttackTargets
@onready var side_a_after_play: Sprite2D = $Sprites/SideA/AfterPlay
@onready var side_b_attack_targets: Sprite2D = $Sprites/SideB/AttackTargets
@onready var side_b_after_play: Sprite2D = $Sprites/SideB/AfterPlay
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	flip_tooltip.visible = false
	hovered_off.emit(self)


func update_elements():
	front_cassette_name_label.text = cassette_name
	top_cassette_name_label.text = cassette_name
	#SIDE A
	side_a_fuel_label.text = str(side_a_data["fuel_cost"])
	side_a_description.text = side_a_data["description"]
	side_a_move_type_icon.texture = load("res://Images/action_icons/"+side_a_data["action_icon"]+".png")
	set_icon_value(side_a_data, side_a_move_type_label)
	if is_show_target_icon(side_a_data["actions"]):
		side_a_attack_targets.visible = true
		set_icon(get_icon_name(side_a_data["actions"]),side_a_attack_targets)
	else:
		side_a_attack_targets.visible = false
	set_icon(side_a_data["after_play"],side_a_after_play)
	#SIDE B
	side_b_fuel_label.text = str(side_b_data["fuel_cost"])
	side_b_description.text = side_b_data["description"]
	side_b_move_type_icon.texture = load("res://Images/action_icons/"+side_b_data["action_icon"]+".png")
	set_icon_value(side_b_data, side_b_move_type_label)
	if is_show_target_icon(side_b_data["actions"]):
		side_b_attack_targets.visible = true
		set_icon(get_icon_name(side_b_data["actions"]),side_b_attack_targets)
	else:
		side_a_attack_targets.visible = false
	set_icon(side_b_data["after_play"],side_b_after_play)


func get_current_side_fuel():
	if current_side == "A":
		return side_a_data["fuel_cost"]
	elif current_side == "B":
		return side_b_data["fuel_cost"]
	else:
		return ""


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


func set_icon_value(cassette_data: Dictionary, label: Label) -> void:
	var icon_type = cassette_data["action_icon"]
	var actions = cassette_data["actions"]
	if not ICON_BEHAVIORS.has(icon_type):
		label.text = ""
		return
	var totals = parse_cassette_actions(actions)
	var categories = ICON_BEHAVIORS[icon_type]
	var values_str = []
	for cat in categories:
		values_str.append(str(totals[cat]))
	label.text = array_join(values_str, "|")


func array_join(arr: Array, sep: String) -> String:
	var result := ""
	for i in range(arr.size()):
		if i > 0:
			result += sep
		result += str(arr[i])
	return result
	

func animate_cassette_to_position(new_position, speed):
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
		print(cassette_name + " stops old animation " + old_name)
		if old_name != "":
			var old_data: Animation = animation_player.get_animation(old_name)
			if old_data:
				if animation_player.get_playing_speed() < 0:
					print("Skipping it to the start")
					animation_player.seek(0, true)
				elif animation_player.get_playing_speed() > 0:
					print("Skipping it to the end")
					animation_player.seek(old_data.length, true)
	if reversed:
		print(cassette_name + " plays backward animation " + anim_name)
		animation_player.play_backwards(anim_name)
		print("Speed Scale = " + str(animation_player.get_playing_speed()))
	else:
		print(cassette_name + " plays animation " + anim_name)
		animation_player.play(anim_name)
		print("Speed Scale = " + str(animation_player.get_playing_speed()))

		
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
		animation_player.stop()
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
	animation_player.stop()

func switch_sides(current_preview_side):
	var tween = create_tween()
	if current_preview_side == "A":
		play_animation("SwitchToOtherSide", true)
		tween.tween_property(side_a, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property(side_a, "modulate", Color(1,1,1,1),0.1)
		tween.parallel().tween_property($Sprites/SideB, "scale", Vector2(0.8,0.8), 0.1)
		tween.parallel().tween_property($Sprites/SideB, "modulate", Color(1,1,1,0.5),0.1)
		
	else:
		play_animation("SwitchToOtherSide")
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


func set_icon(icon_name, element):
	element.texture = load("res://Images/action_icons/"+icon_name+".png")


func get_icon_name(action_moves):
	var action_target = action_moves[0]["target_area"]
	return "attack to the "+ action_target


func is_show_target_icon(action_moves):
	for action in action_moves:
		if action["action_type"] == GlobalEnums.ACTION_TYPE.ATTACK:
			return true
		if action["action_type"] == GlobalEnums.ACTION_TYPE.SPECIAL:
			if action["effect_name"] == "attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides":
				return true
	return false


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
	z_index = 0
	

func _enter_in_hand():
	print(cassette_name + " Enters Hand")
	z_index = 0

func _exit_in_hand():
	print(cassette_name + " Exits Hand")
	pass

func _enter_hovered_over():
	print(cassette_name + " Enters Hover Over")
	flip_tooltip.visible = true
	z_index = 2
	play_animation("Hover_over")

func _exit_hovered_over():
	print(cassette_name + " Exits Hover Over")
	flip_tooltip.visible = false
	play_animation("Hover_over", true)

func _enter_dragging():
	print(cassette_name + " Enters Dragging")
	z_index = 3
	play_animation("SwitchToFront", true)

func _exit_dragging():
	print(cassette_name + " Exits Dragging")
	play_animation("SwitchToFront")
	self.get_parent().remove_child(self)
	

func _enter_in_slot():
	z_index = 1
	flip_tooltip.visible = false
	self.position = Vector2(0,0)

func _exit_in_slot():
	self.get_parent().remove_child(self)


func print_start_animation():
	print("START OF ANIMATION " + animation_player.current_animation)


func print_end_animation():
	print("END OF ANIMATION " + animation_player.current_animation)
