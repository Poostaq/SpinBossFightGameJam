extends Node2D

const INACTIVE_COLOR = Color(1,1,1,0.3)
const ACTIVE_COLOR = Color(1,1,1,1)
var cassette_in_slot
@onready var top_cover = $TopClosingCover
@onready var bottom_cover = $BottomClosingCover

@onready var icon = $Icon

func remove_icons():
	icon.visible = false


func set_cover_state(closed):
	if closed:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.37,0.35),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.37,0.35),0.1)
	elif !closed:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.37,0),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.37,0),0.1)
