extends Node2D

const INACTIVE_COLOR = Color(1,1,1,0.3)
const ACTIVE_COLOR = Color(1,1,1,1)
const COLLISION_MASK_SLOT = 16
var cassette_in_slot
@onready var top_cover = $TopClosingCover
@onready var bottom_cover = $BottomClosingCover
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func update_elements() -> void:
	$Fuel_Amount.modulate = ACTIVE_COLOR if cassette_in_slot!=null else INACTIVE_COLOR
	$Fuel_Amount.text     = str(cassette_in_slot.get_current_side_fuel()) if cassette_in_slot!=null  else ""
	$Side.modulate        = ACTIVE_COLOR if cassette_in_slot!=null else INACTIVE_COLOR
	$Side.text            = cassette_in_slot.current_side if cassette_in_slot!=null else ""

func set_cover_state(closed):
	if closed and cassette_in_slot == null:
		animation_player.play("CloseSlot")
	elif !closed and cassette_in_slot == null:
		animation_player.play("OpenSlot")

func reset_cover_modulate():
	top_cover.modulate = Color(1, 1, 1, 1)
	bottom_cover.modulate = Color(1, 1, 1, 1)

func _on_area_2d_mouse_entered() -> void:
	set_cover_state(false)


func _on_area_2d_mouse_exited() -> void:
	set_cover_state(true)
