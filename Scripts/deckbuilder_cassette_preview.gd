extends Node2D

enum SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA, MOVE_INFO}

@onready var cassette_name: Label = $CassetteName

@onready var side_a: Dictionary = {
	"description" = $SideA/Background/Description,
	"move_type_icon" = $SideA/MoveTypeIcon,
	"move_value" = $SideA/MoveTypeIcon/Value,
	"fuel_value" = $SideA/Fuel/Value,
	"attack_targets" = $SideA/AttackTargets,
	"after_play" = $SideA/AfterPlay
	
}


@onready var side_b: Dictionary = {
	"description" = $SideB/Background/Description,
	"move_type_icon" = $SideB/MoveTypeIcon,
	"move_value" = $SideB/MoveTypeIcon/Value,
	"fuel_value" = $SideB/Fuel/Value,
	"attack_targets" = $SideB/AttackTargets,
	"after_play" = $SideB/AfterPlay
	
}


func set_icon(icon_name, element):
	element.texture = load("res://Images/action_icons/"+icon_name+".png")


func is_show_target_icon(action_moves):
	for action in action_moves:
		if action[ACTION.MOVE_TYPE] == "attack":
			return true
		if len(action) > 3:
			if action[ACTION.MOVE_INFO] == "attack_deals_damage_plus_spent_fuel_as_bonus_damage_all_sides":
				return true
	return false


func get_icon_name(action_moves):
	var action_target = action_moves[0][ACTION.MOVE_AREA]
	return "attack to the "+ action_target


func set_move_value(action_data, element):
	if action_data[SIDE_DATA.ACTION_ICON] == "attack" or action_data[SIDE_DATA.ACTION_ICON] == "attack_special":
		var attack = 0
		for action in action_data[SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
		element.text = str(attack)
	elif action_data[SIDE_DATA.ACTION_ICON] == "attack_defence":
		var attack = 0
		var defence = 0
		for action in action_data[SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
			if action[ACTION.MOVE_TYPE] == "special":
				defence =action[ACTION.VALUE]
		element.text = str(attack)+"|"+str(defence)
	elif action_data[SIDE_DATA.ACTION_ICON] == "defence":
		var defence = 0
		for action in action_data[SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				defence =action[ACTION.VALUE]
		element.text = str(defence)
	elif action_data[SIDE_DATA.ACTION_ICON] == "defence_special":
		var special = 0
		for action in action_data[SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		element.text = str(special)
	elif action_data[SIDE_DATA.ACTION_ICON] == "special":
		var special = 0
		for action in action_data[SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		element.text = str(special)
	else:
		element.text = ""


func set_preview_data(cassette_data):
	var side_a_data = cassette_data[1]
	var side_b_data = cassette_data[2]
	cassette_name.text = cassette_data[0]
	
	side_a["description"].text = side_a_data[SIDE_DATA.DESCRIPTION]
	set_icon(side_a_data[SIDE_DATA.ACTION_ICON],side_a["move_type_icon"])
	if is_show_target_icon(side_a_data[SIDE_DATA.ACTIONS_LIST]):
		side_a["attack_targets"].visible = true
		set_icon(get_icon_name(side_a_data[SIDE_DATA.ACTIONS_LIST]),side_a["attack_targets"])
	else:
		side_a["attack_targets"].visible = false
	set_move_value(side_a_data,side_a["move_value"])
	side_a["fuel_value"].text = str(side_a_data[SIDE_DATA.FUEL_COST])
	set_icon(side_a_data[SIDE_DATA.AFTER_PLAY],side_a["after_play"])
	
	side_b["description"].text = side_b_data[SIDE_DATA.DESCRIPTION]
	set_icon(side_b_data[SIDE_DATA.ACTION_ICON],side_b["move_type_icon"])
	if is_show_target_icon(side_b_data[SIDE_DATA.ACTIONS_LIST]):
		side_b["attack_targets"].visible = true
		set_icon(get_icon_name(side_b_data[SIDE_DATA.ACTIONS_LIST]),side_b["attack_targets"])
	else:
		side_b["attack_targets"].visible = false
	set_move_value(side_b_data,side_b["move_value"])
	side_b["fuel_value"].text = str(side_b_data[SIDE_DATA.FUEL_COST])
	set_icon(side_b_data[SIDE_DATA.AFTER_PLAY],side_b["after_play"])
	visible = true
