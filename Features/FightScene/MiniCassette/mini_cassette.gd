extends Node2D


enum CASSETTE_SIDE_DATA {FUEL_COST, DESCRIPTION, ACTIONS_LIST, AFTER_PLAY, ACTION_ICON}
enum ACTION {MOVE_TYPE, VALUE, MOVE_AREA}
var action_data = []

@onready var icons = $Node2D/CassetteMoveInfo/Icons
@onready var attack_direction = $Node2D/CassetteMoveInfo/AttackDirection
@onready var maneouver_description: Label = $Node2D/CassetteMoveInfo/ManeouverDescription
@onready var cassette_name: Label = $Node2D/Front/CassetteName
@onready var after_turn_icon: Sprite2D = $Node2D/CassetteMoveInfo/AfterTurnIcon
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var whose_cassette

func set_cassette_data(current_icons):
	#set_icons_data()
	var action_label = current_icons.get_node("Action/Label")
	if action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack" or action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack_special":
		var attack = 0
		for action in action_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
		action_label.text = str(attack)
	elif action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "attack_defence":
		var attack = 0
		var defence = 0
		for action in action_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "attack":
				attack = action[ACTION.VALUE]
			if action[ACTION.MOVE_TYPE] == "special":
				defence =action[ACTION.VALUE]
		action_label.text = str(attack)+"|"+str(defence)
	elif action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "defence":
		var defence = 0
		for action in action_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				defence =action[ACTION.VALUE]
		action_label.text = str(defence)
	elif action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "defence_special":
		var special = 0
		for action in action_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		if special == "":
			action_label.text = str(special)
	elif action_data[CASSETTE_SIDE_DATA.ACTION_ICON] == "special":
		var special = 0
		for action in action_data[CASSETTE_SIDE_DATA.ACTIONS_LIST]:
			if action[ACTION.MOVE_TYPE] == "special":
				special = action[ACTION.VALUE]
		action_label.text = str(special)
	else:
		action_label = ""
	maneouver_description.text = action_data[CASSETTE_SIDE_DATA.DESCRIPTION]
	current_icons.get_node("Action").texture = load("res://Images/action_icons/"+action_data[CASSETTE_SIDE_DATA.ACTION_ICON]+".png")
	after_turn_icon.texture = load("res://Images/action_icons/"+action_data[CASSETTE_SIDE_DATA.AFTER_PLAY]+".png")
	var fuel_label =  current_icons.get_node("Fuel/Label")
	fuel_label.text = str(action_data[CASSETTE_SIDE_DATA.FUEL_COST])
	
#func set_icons_visibility():
	#if whose_cassette == GlobalEnums.PLAYER:
		#player_icons.visible = true
		#enemy_icons.visible = false
	#else:
		#player_icons.visible = false
		#enemy_icons.visible = true
		

func highlight_cassette(is_highlighted):
	var tween = create_tween()
	var vector
	if whose_cassette == GlobalEnums.PLAYER:
		if is_highlighted:
			vector = Vector2(-40,0)
		else:
			vector = Vector2(40,0)
			
	else:
		if is_highlighted:
			vector = Vector2(40,0)
		else:
			vector = Vector2(-40,0)
	tween.tween_property(self, "position", position-vector,0.1)
	await tween.finished
