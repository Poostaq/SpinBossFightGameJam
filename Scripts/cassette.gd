extends Node2D

signal hovered(cassette)
signal hovered_off(cassette)

const ENLARGED_CASSETTE_SIZE = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE = Vector2(0.5,0.5)
const TOP_Y = 40


enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA, MOVE_INFO}
enum STATE {IN_DECK, IN_HAND_IDLE, HOVERED_OVER, DRAGGING, IN_SLOT}

var position_in_hand
var rotation_in_hand
var scale_in_hand
var z_position_in_hand
var cassette_slot_cassette_is_in
var side_a_data
var side_b_data
var cassette_name
var current_side
var tween_hover
var whose_cassette
var state

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


func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	flip_tooltip.visible = false
	animation_player.play_backwards("Hover_over")
	await get_tree().create_timer(0.1).timeout
	hovered_off.emit(self)


func update_elements():
	front_cassette_name_label.text = cassette_name
	top_cassette_name_label.text = cassette_name
	#SIDE A
	side_a_fuel_label.text = str(side_a_data[CASSETTE_SIDE_DATA.FUEL_COST])
	side_a_description.text = side_a_data[CASSETTE_SIDE_DATA.DESCRIPTION]
	side_a_move_type_icon.texture = load("res://Images/action_icons/"+side_a_data[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	set_icon_value(side_a_data, side_a_move_type_label)
	if is_show_target_icon(side_a_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]):
		side_a_attack_targets.visible = true
		set_icon(get_icon_name(side_a_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]),side_a_attack_targets)
	else:
		side_a_attack_targets.visible = false
	set_icon(side_a_data[CASSETTE_SIDE_DATA.AFTER_PLAY],side_a_after_play)
	#SIDE B
	side_b_fuel_label.text = str(side_b_data[CASSETTE_SIDE_DATA.FUEL_COST])
	side_b_description.text = side_b_data[CASSETTE_SIDE_DATA.DESCRIPTION]
	side_b_move_type_icon.texture = load("res://Images/action_icons/"+side_b_data[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	set_icon_value(side_b_data, side_b_move_type_label)
	if is_show_target_icon(side_b_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]):
		side_b_attack_targets.visible = true
		set_icon(get_icon_name(side_b_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]),side_b_attack_targets)
	else:
		side_a_attack_targets.visible = false
	set_icon(side_b_data[CASSETTE_SIDE_DATA.AFTER_PLAY],side_b_after_play)


func get_current_side_fuel():
	if current_side == "A":
		return side_a_data[CASSETTE_SIDE_DATA.FUEL_COST]
	elif current_side == "B":
		return side_b_data[CASSETTE_SIDE_DATA.FUEL_COST]
	else:
		return ""


func set_icon_value(cassette_data, label):
	if cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack":
		var attack = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
		label.text = str(attack)
	elif cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack_special":
		var attack = 0
		var special = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		if attack == 0:
			label.text = str(special)
		if special == 0:
			label.text = str(attack)
	elif cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack_defence":
		var attack = 0
		var defence = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
			if action[ACTION.MOVE_TYPE] == "special":
				defence += action[ACTION.VALUE]
		label.text = str(attack)+"|"+str(defence)
	elif cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "defence":
		var defence = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				defence =action[ACTION.VALUE]
		label.text = str(defence)
	elif cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "defence_special":
		var special = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		label.text = str(special)
	elif cassette_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "special":
		var special = 0
		for action in cassette_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		label.text = str(special)
	else:
		label = ""


func animate_cassette_to_position(new_position, speed, new_rotation=0):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, speed)
	tween.parallel().tween_property(self, "rotation_degrees", new_rotation, speed)
	await tween.finished


func get_current_action():
	if current_side == "A":
		return side_a_data
	else:
		return side_b_data


func set_front_visible():
	self.animation_player.play("SwitchToFront")


func switch_sides(current_preview_side):
	var tween = create_tween()
	if current_preview_side == "A":
		animation_player.play_backwards("SwitchToOtherSide")
		tween.tween_property(side_a, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property(side_a, "modulate", Color(1,1,1,1),0.1)
		tween.parallel().tween_property($Sprites/SideB, "scale", Vector2(0.8,0.8), 0.1)
		tween.parallel().tween_property($Sprites/SideB, "modulate", Color(1,1,1,0.5),0.1)
		
	else:
		animation_player.play("SwitchToOtherSide")
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
	var action_target = action_moves[0][ACTION.MOVE_AREA]
	return "attack to the "+ action_target


func is_show_target_icon(action_moves):
	for action in action_moves:
		if action[ACTION.MOVE_TYPE] == "attack":
			return true
		if len(action) > 3:
			if action[ACTION.MOVE_INFO] == "attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides":
				return true
	return false
