extends Sprite2D

signal cassette_hovered(cassette_data)
signal cassette_hovered_off()

@onready var label: Label = $Label

var cassette_data

func animate_cassette_to_position(new_position, speed, new_rotation=0):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", new_position, speed)
	tween.parallel().tween_property(self, "rotation_degrees", new_rotation, speed)
	await tween.finished


func _on_area_2d_mouse_entered() -> void:
	cassette_hovered.emit(cassette_data)
	scale = Vector2(1.1,1.1)


func _on_area_2d_mouse_exited() -> void:
	cassette_hovered_off.emit()
	scale = Vector2(1,1)
