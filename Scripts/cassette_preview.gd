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
        _display_icon(cassette_side_a, $CassetteSprites/SideA/Icon, $CassetteSprites/SideA/Icon/Label)
        _display_icon(cassette_side_b, $CassetteSprites/SideB/Icon, $CassetteSprites/SideB/Icon/Label)

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

func _display_icon(cassette_data, icon_node, label_node):
        var icons = cassette_data.get("action_icons", [])
        for info in icons:
                var icon_name = str(info.get("icon", ""))
                if icon_name in ["slow_down", "line_up", "overtake"]:
                        continue
                icon_node.texture = load("res://Images/action_icons/%s.png" % icon_name)
                var value = info.get("value", "")
                if value == 0 or str(value) == "":
                        label_node.text = ""
                else:
                        label_node.text = str(value)
                return
        label_node.text = ""
	

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
