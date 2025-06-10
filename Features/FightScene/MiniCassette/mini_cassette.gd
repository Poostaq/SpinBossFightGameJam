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
        var action_label = current_icons.get_node("Action/Label")
        var icons = action_data.get("action_icons", [])
        var shown = false
        for info in icons:
                var icon_name = str(info.get("icon", ""))
                if icon_name in ["slow_down", "line_up", "overtake"]:
                        continue
                current_icons.get_node("Action").texture = load("res://Images/action_icons/%s.png" % icon_name)
                var value = info.get("value", "")
                if value == 0 or str(value) == "":
                        action_label.text = ""
                else:
                        action_label.text = str(value)
                shown = true
                break
        if not shown:
                action_label.text = ""
        after_turn_icon.texture = load("res://Images/action_icons/%s.png" % action_data[CASSETTE_SIDE_DATA.AFTER_PLAY])
        var fuel_label = current_icons.get_node("Fuel/Label")
        fuel_label.text = str(action_data[CASSETTE_SIDE_DATA.FUEL_COST])
        maneouver_description.text = action_data[CASSETTE_SIDE_DATA.DESCRIPTION]
	
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
