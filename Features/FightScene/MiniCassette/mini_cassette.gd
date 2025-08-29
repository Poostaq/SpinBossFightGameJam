extends Node2D


@onready var actions_sprite: Sprite2D = $Node2D/ActionData/Actions
@onready var cassette_name: Label = $Node2D/Front/CassetteName
@onready var after_turn_icon: Sprite2D = $Node2D/ActionData/AfterTurnIcon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fuel_icon: Sprite2D = $Node2D/ActionData/Icons/Fuel
@onready var fuel_label: Label = $Node2D/ActionData/Icons/Fuel/Label
@onready var action_icon1: Sprite2D = $Node2D/ActionData/Icons/Icon1
@onready var action_icon2: Sprite2D = $Node2D/ActionData/Icons/Icon2

@onready var action_icons: Array[Variant] = [action_icon1, action_icon2]

var original_cassette 

func set_cassette_data(base_cassette: Cassette):
	original_cassette = base_cassette
	actions_sprite.texture = base_cassette.actions_sprite.texture.duplicate()
	cassette_name.text = base_cassette.cassette_name
	after_turn_icon.texture = base_cassette.action_data_after_play.texture.duplicate()
	_display_action_icons(base_cassette.get_current_side_data())
	set_up_action_labels(base_cassette)
	hide_icons()



func _display_action_icons(data: Dictionary) -> void:
	fuel_label.text = str(int(data["fuel_cost"]))
	var icons = data.get("action_icons", [])
	for icon in action_icons:
		icon.visible = false
		icon.get_node("Label").text = ""
	for i in range(0, min(len(icons), action_icons.size())):
		action_icons[i].visible = true
		var info = icons[i]
		var texture = action_icons[i]
		texture.texture = load("res://Images/action_icons/%s.png" % info.get("icon", ""))
		var label = action_icons[i].get_node("Label")
		set_icon_value(info, label)
	if icons.size() < 2:
		print(icons)
		print(icons.size())
		action_icon2.visible = false

func set_icon_value(icon_info: Dictionary, label: Label) -> void:
	label.text = _get_value_text(icon_info)


func _get_value_text(info: Dictionary) -> String:
	if not info.has("value"):
			return ""
	var val = info["value"]
	if val == 0 or str(val) == "":
			return ""
	return str(int(val))


func set_up_action_labels(base_cassette: Cassette):
	var action_labels = base_cassette.actions_sprite.get_children()
	for i in range(action_labels.size()):
		var label_node = action_labels[i] as Label
		var mini_label_node = label_node.duplicate() as Label
		actions_sprite.add_child(mini_label_node)
		mini_label_node.position = label_node.position
		mini_label_node.text = label_node.text
		mini_label_node.visible = true
		mini_label_node.set_deferred("size", label_node.size)
		mini_label_node.scale = label_node.scale

func highlight_cassette(is_highlighted):
	var tween = create_tween()
	var vector
	if original_cassette.whose_cassette == GlobalEnums.PLAYER:
		if is_highlighted:
			vector = Vector2(-300,0)
		else:
			vector = Vector2(300,0)
			
	else:
		if is_highlighted:
			vector = Vector2(300,0)
		else:
			vector = Vector2(-300,0)
	tween.tween_property(self, "position", position+vector,0.1)
	await tween.finished

func show_icons():
	fuel_icon.visible = true
	var action_icons_data = original_cassette.get_current_side_data().get("action_icons", [])
	for i in range(action_icons_data.size()):
		action_icons[i].visible = true
		action_icons[i].get_node("Label").visible = true


func hide_icons():
	fuel_icon.visible = false
	for icon in action_icons:
		icon.visible = false
		icon.get_node("Label").visible = false
