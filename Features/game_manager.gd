class_name GameManager
extends Node

enum GameState { MAIN_MENU, STORY, FIGHT }

var current_scene: Node = null
var game_state: GameState = GameState.MAIN_MENU
@onready var music_player: AudioStreamPlayer = $"../MusicPlayer"

var current_story_index = 0  # This tracks which story to load next

func _ready():
	load_main_menu()
	Database.load_all_data()

func load_scene(scene: Node):
	if current_scene:
		current_scene.queue_free()
	current_scene = scene
	add_child(current_scene)
	connect_scene_signals(current_scene)

func load_main_menu():
	game_state = GameState.MAIN_MENU
	load_scene(preload("res://Features/MainMenu/MainMenu.tscn").instantiate())

func load_story_scene():
	await music_player.fade_out_music()
	game_state = GameState.STORY
	var story_scene = preload("res://Scenes/StoryScene.tscn").instantiate()
	story_scene.current_story = current_story_index  # Pass the current story to the StoryScene
	load_scene(story_scene)
	await music_player.fade_in_music(music_player.STORY_MUSIC)

func load_fight_scene():
	await music_player.fade_out_music()
	game_state = GameState.FIGHT
	load_scene(preload("res://Features/FightScene/FightScene.tscn").instantiate())
	await music_player.fade_in_music(music_player.FIGHT_1)

func on_start_button_pressed():
	load_story_scene()

func on_exit_button_pressed():
	get_tree().quit()

func connect_scene_signals(scene: Node):
	if scene.has_signal("start_game"):
		scene.start_game.connect(_on_game_start)
	if scene.has_signal("story_finished"):
		scene.story_finished.connect(_on_story_complete)
	if scene.has_signal("fight_complete"):
		scene.fight_complete.connect(_on_fight_complete)

func _on_story_complete(boss_name: String):
	if game_state == GameState.STORY:
		# Decide next story based on which boss was defeated
		match boss_name:
			"Hound":
				current_story_index = 1
			"Boner":
				current_story_index = 2  # This is ready for future expansion if there are more stories
		load_fight_scene()

func _on_fight_complete():
	if game_state == GameState.FIGHT:
		load_story_scene()

func _on_game_start():
	if game_state == GameState.MAIN_MENU:
		load_story_scene()
