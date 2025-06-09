extends Node

signal sfx_finished

var sfx_player: AudioStreamPlayer

func _ready():
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.bus = "SFX"
	sfx_player.finished.connect(_on_sfx_finished)

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()

func _on_sfx_finished():
	sfx_finished.emit()

func stop_sfx():
	sfx_player.seek(sfx_player.stream.get_length()-0.2)
	
func is_playing():
	return sfx_player.playing
