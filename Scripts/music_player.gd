extends AudioStreamPlayer

const MENU_MUSIC_2 = preload("res://Music/Im coming hub new and better title screen.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_in_music(MENU_MUSIC_2)

func fade_in_music(music):
	stream = music
	play()
	var tweener = create_tween()
	tweener.tween_property(self, "volume_db",0,1)
	await tweener.finished
	
func fade_out_music():
	var tweener = create_tween()
	tweener.tween_property(self, "volume_db",-60,1)
	await tweener.finished
