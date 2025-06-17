extends Node2D

const INACTIVE_COLOR = Color(1,1,1,0.3)
const ACTIVE_COLOR = Color(1,1,1,1)
var cassette_in_slot
@onready var top_cover = $TopClosingCover
@onready var bottom_cover = $BottomClosingCover

@onready var icons_container = $Icons

func remove_icons():
	for child in icons_container.get_children():
			child.queue_free()

func fill_icons(side_data: Dictionary) -> void:
	remove_icons()
	var raw_icons = side_data.get("action_icons", [])
	var spacing = 30
	var icons: Array = []
	for info in raw_icons:
		var icon_name = str(info.get("icon", ""))
		if icon_name == "":
			continue
		icons.append(info)

	var icon_count = icons.size()
	if icon_count == 0:
		return

	var start_offset = -(icon_count - 1) * spacing / 2.0
	var idx = 0
	for info in icons:
		var icon_name = str(info.get("icon", ""))
		var sprite := Sprite2D.new()
		sprite.texture = load("res://Images/action_icons/%s.png" % icon_name)
		sprite.scale = Vector2(0.15, 0.15)
		sprite.position = Vector2(start_offset + idx * spacing, 0)

		if info.has("value"):
			var val = info["value"]
			if val != 0 and str(val) != "":
				var label := Label.new()
				label.text = str(val)
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				sprite.add_child(label)

<<<<<<< HEAD
		icons_container.add_child(sprite)
		idx += 1
=======
			icons_container.add_child(sprite)
			idx += 1
>>>>>>> a9571e50c43350fa52589cfd94da8288ad8dc5c0


func set_cover_state(closed):
	if closed:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.37,0.35),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.37,0.35),0.1)
	elif !closed:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.37,0),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.37,0),0.1)
