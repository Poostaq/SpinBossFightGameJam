extends Node2D


const ENLARGED_CASSETTE_SIZE = Vector2(0.85,0.85)
const REGULAR_CASSETTE_SIZE = Vector2(0.70,0.70)
const SMALLER_CASSETTE_SIZE = Vector2(0.5,0.5)
const TOP_Y = 40



enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA}
var position_in_hand
var rotation_in_hand
var cassette_side_a
var cassette_side_b
var cassette_name
var current_side
var tween_hover

@onready var animation_player = $AnimationPlayer


func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func highlight_cassette(should_highlight):
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
		
	tween_hover = create_tween()
	if should_highlight:
		tween_hover.tween_property($CassetteSprites, "scale", ENLARGED_CASSETTE_SIZE, 0.1)
	else:
		tween_hover.tween_property($CassetteSprites, "scale", REGULAR_CASSETTE_SIZE, 0.1)

func update_elements():
	$CassetteSprites/Front/CassetteName.text = cassette_name
	$CassetteSprites/Top/CassetteName.text = cassette_name
	$CassetteSprites/SideA/Fuel/Label.text = str(cassette_side_a[CASSETTE_SIDE_DATA.FUEL_COST])
	$CassetteSprites/SideA/Description.text = cassette_side_a[CASSETTE_SIDE_DATA.DESCRIPTION]
	$CassetteSprites/SideB/Fuel/Label.text = str(cassette_side_b[CASSETTE_SIDE_DATA.FUEL_COST])
	$CassetteSprites/SideB/Description.text = cassette_side_b[CASSETTE_SIDE_DATA.DESCRIPTION]
	$CassetteSprites/SideA/Icon.texture = load("res://Images/action_icons/"+cassette_side_a[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	set_icon_value(cassette_side_a, $CassetteSprites/SideA/Icon/Label)
	$CassetteSprites/SideB/Icon.texture = load("res://Images/action_icons/"+cassette_side_b[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	set_icon_value(cassette_side_b, $CassetteSprites/SideB/Icon/Label)

func get_current_side_fuel():
	if current_side == "A":
		return cassette_side_a[CASSETTE_SIDE_DATA.FUEL_COST]
	elif current_side == "B":
		return cassette_side_b[CASSETTE_SIDE_DATA.FUEL_COST]
	else:
		return ""

func set_name_labels():
	$CassetteSprites/Front/CassetteName.text = cassette_name
	$CassetteSprites/Top/CassetteName.text = cassette_name

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
	

func switch_preview_sides(current_preview_side):
	var tween = create_tween()
	if current_preview_side == "A":
		animation_player.play_backwards("SwitchToOtherSide")
		tween.tween_property($CassetteSprites/SideA, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property($CassetteSprites/SideA, "modulate", Color(1,1,1,1),0.1)
		tween.parallel().tween_property($CassetteSprites/SideB, "scale", Vector2(0.8,0.8), 0.1)
		tween.parallel().tween_property($CassetteSprites/SideB, "modulate", Color(1,1,1,0.5),0.1)
		
	else:
		animation_player.play("SwitchToOtherSide")
		tween.tween_property($CassetteSprites/SideB, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property($CassetteSprites/SideB, "modulate", Color(1,1,1,1),0.1)
		tween.parallel().tween_property($CassetteSprites/SideA, "scale", Vector2(0.8,0.8), 0.1)
		tween.parallel().tween_property($CassetteSprites/SideA, "modulate", Color(1,1,1,0.5),0.1)
		
func set_preview_side(current_preview_side):
	if current_preview_side == "A":
		$CassetteSprites/SideA.scale= Vector2(1.1, 1.1)
		$CassetteSprites/SideA.modulate = Color(1,1,1,1)
		$CassetteSprites/SideB.scale = Vector2(0.8,0.8)
		$CassetteSprites/SideB.modulate = Color(1,1,1,0.5)
		$CassetteSprites/Front/ASideLogo.scale = Vector2(0.5,0.5)
		$CassetteSprites/Front/BSideLogo.scale = Vector2(0.3,0.3)
	else:
		$CassetteSprites/SideB.scale= Vector2(1.1, 1.1)
		$CassetteSprites/SideB.modulate = Color(1,1,1,1)
		$CassetteSprites/SideA.scale = Vector2(0.8,0.8)
		$CassetteSprites/SideA.modulate = Color(1,1,1,0.5)
		$CassetteSprites/Front/ASideLogo.scale = Vector2(0.3,0.3)
		$CassetteSprites/Front/BSideLogo.scale = Vector2(0.5,0.5)
