class_name StoryScene
extends Node2D

signal story_finished

var story_tween: Tween
var current_tween: Tween = null

var current_story = 0

var currently_animated_node: Node = null
var currently_animated_property: String = ""
var target_modulate_color: Color = Color(1, 1, 1, 1)

@onready var narration: RichTextLabel = $Narration
@onready var portrait: Sprite2D = $Portrait
@onready var portrait_2: Sprite2D = $Portrait2
@onready var story_wait_time: Timer = $StoryWaitTime

const HER_DEFAULT = preload("res://Images/portraits/Her/her default.png")
const HOUND_DEFAULT = preload("res://Images/portraits/hound/hound default.png")
const BONER_DEFAULT = preload("res://Images/portraits/boner/boner default.png")
const CAR_ENGINE_START_AND_PULL_AWAY = preload("res://sfx/car engine start and pull away.mp3")

var story_steps = []

func _ready():
	setup_story_steps()
	play_story()

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		skip_current_tween()

func skip_current_tween():
	if SfxManager.is_playing():
		SfxManager.stop_sfx()
	if current_tween and current_tween.is_running():
		current_tween.custom_step(9999)

func play_story():
	set_process_input(true)
	await run_story_steps()
	set_process_input(false)

func run_story_steps():
	set_process_input(true)

	for step in story_steps:
		if step.has("portrait1"):
			portrait.texture = step.portrait1
		if step.has("portrait2"):
			portrait_2.texture = step.portrait2

		if step.has("text"):
			await animate_narration_text(step.text)

		if step.has("set_modulate_portrait1"):
			portrait.modulate = step.set_modulate_portrait1
		if step.has("animate_modulate_portrait1"):
			await animate_modulate(portrait, step.animate_modulate_portrait1, 1)

		if step.has("set_modulate_portrait2"):
			portrait_2.modulate = step.set_modulate_portrait2
		if step.has("animate_modulate_portrait2"):
			await animate_modulate(portrait_2, step.animate_modulate_portrait2, 1)

		if step.has("set_narration_modulate"):
			narration.modulate = step.set_narration_modulate
		if step.has("animate_narration_modulate"):
			await animate_modulate(narration, step.animate_narration_modulate, 1)

		if step.has("sfx"):
			await play_sfx_and_wait(step.sfx)

		if step.has("story_finished"):
			story_finished.emit(step.story_finished)
			print("STORY FINISHED")
			return

func animate_narration_text(text: String):
	currently_animated_node = narration
	currently_animated_property = "visible_characters"
	narration.visible_characters = 0
	narration.text = text

	current_tween = create_tween()
	current_tween.tween_property(narration, "visible_characters", len(text), 3)
	await current_tween.finished

	await wait(1)

func animate_modulate(target: Node, color: Color, duration: float):
	currently_animated_node = target
	currently_animated_property = "modulate"
	target_modulate_color = color
	current_tween = create_tween()
	current_tween.tween_property(target, "modulate", color, duration)
	await current_tween.finished

func wait(seconds: float):
	story_wait_time.start(seconds)
	await story_wait_time.timeout

func play_sfx_and_wait(sfx: AudioStream):
	SfxManager.play_sfx(sfx)
	await SfxManager.sfx_finished

func setup_story_steps():
	if current_story == 0:
		story_steps = [
			{"set_modulate_portrait1": Color(1, 1, 1, 0), "set_modulate_portrait2": Color(1, 1, 1, 0)},
			{"portrait1": HER_DEFAULT, "portrait2": HOUND_DEFAULT},
			{"text": "Husband: HELP! HELP! Let me go, you bastard!"},
			{"animate_modulate_portrait1": Color(1, 1, 1, 1)},
			{"text": "Wife: Huh?! What's going on?! Honey?! Take your dirty hands off my husband!"},
			{"animate_modulate_portrait2": Color(1, 1, 1, 1)},
			{"text": "Hound: Hahaha! I wish I could but I don't want to. It was nice to meet you ma'am. Cya!"},
			{"animate_modulate_portrait2": Color(1, 1, 1, 0)},
			{"sfx": CAR_ENGINE_START_AND_PULL_AWAY},
			{"text": "Wife: I won't let him take you away from me my dear! I'm coming, hub!"},
			{"animate_modulate_portrait1": Color(1, 1, 1, 0)},
			{"animate_narration_modulate": Color(1, 1, 1, 0)},
			{"story_finished": "Hound"}
		]
	elif current_story == 1:
		story_steps = [
			{"set_modulate_portrait1": Color(1, 1, 1, 0), "set_modulate_portrait2": Color(1, 1, 1, 0)},
			{"animate_modulate_portrait2": Color(1, 1, 1, 1)},
			{"text": "Hound: Ouch…! Holly molly, my head…!"},
			{"animate_modulate_portrait1": Color(1, 1, 1, 1)},
			{"text": "Wife: Where's my husband?! What do you want from him?! Talk!"},
			{"text": "Hound: I don't know. I was paid to get him out of town."},
			{"text": "Wife: And you left him on this fricking desert?!"},
			{"text": "Hound: Sort of. The moment I dropped him off I saw some spooky ride taking him somewhere."},
			{"text": "Wife: Where did they go?!"},
			{"text": "Hound: Dunno… They headed south..."},
			{"text": "Wife: Darn it! I hope you're telling the truth, or I'll find you and run you over… again and again."},
			{"text": "Hound:..."},
			{"sfx": CAR_ENGINE_START_AND_PULL_AWAY},
			{"animate_modulate_portrait1": Color(1, 1, 1, 0), "animate_modulate_portrait2": Color(1, 1, 1, 0)},
			{"animate_narration_modulate": Color(1, 1, 1, 0)},
			{"animate_modulate_portrait1": Color(1, 1, 1, 1)},
			{"text": ""},
			{"animate_narration_modulate": Color(1, 1, 1, 0)},
			{"text": "Wife: Where are they… I've been driving for an hour and still nothing… Can they be this fast?"},
			{"text": "Huh?! What the hell is that? Could this be..."},
			{"text": "Boner: We meet again…", "portrait2": BONER_DEFAULT},
			{"animate_modulate_portrait2": Color(1, 1, 1, 1)},
			{"modulate2": Color(1, 1, 1, 1)},
			{"text": "Boner: Long time no see!"},
			{"text": "Wife: I know you have him! Leave him alone!"},
			{"text": "Boner: Who told you I have him? Hahahahaha!"},
			{"text": "Wife: Wait a minute, I know this irritating voice!"},
			{"text": "Boner: Who's irritating?!"},
			{"animate_modulate_portrait1": Color(1, 1, 1, 0), "animate_modulate_portrait2": Color(1, 1, 1, 0)},
			{"story_finished": "Boner"}
		]
