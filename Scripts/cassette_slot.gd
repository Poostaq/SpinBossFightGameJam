extends Node2D

const INACTIVE_COLOR = Color(1,1,1,0.3)
const ACTIVE_COLOR = Color(1,1,1,1)
const COLLISION_MASK_SLOT = 16
var cassette_in_slot
@onready var top_cover = $TopClosingCover
@onready var bottom_cover = $BottomClosingCover
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func update_elements(is_active, side, fuel):
	if is_active:
		$Fuel_Amount.modulate = ACTIVE_COLOR
		$Fuel_Amount.text = str(fuel)
		$Side.modulate = ACTIVE_COLOR
		$Side.text = "SIDE: "+ side
	else:
		$Fuel_Amount.modulate = INACTIVE_COLOR
		$Fuel_Amount.text = ""
		$Side.modulate = INACTIVE_COLOR
		$Side.text = "SIDE: "

func set_cover_state(closed):
	if closed and cassette_in_slot == null:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.5,0.5),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.5,0.5),0.1)
	elif !closed and cassette_in_slot == null:
		var cover_tweener = create_tween()
		cover_tweener.tween_property(top_cover, "scale", Vector2(0.5,0),0.1)
		cover_tweener.parallel().tween_property(bottom_cover, "scale", Vector2(0.5,0),0.1)



func _on_area_2d_mouse_entered() -> void:
	set_cover_state(false)


func _on_area_2d_mouse_exited() -> void:
	set_cover_state(true)
