extends Node2D

signal story_finished
signal tbc_finished

var story_tween: Tween
var current_story = 0
var currently_animated_element
var currently_animated_parameter
var tween_target_value

@onready var narration: RichTextLabel = $Narration
@onready var portrait: Sprite2D = $Portrait
@onready var portrait_2: Sprite2D = $Portrait2
@onready var sfx_player: AudioStreamPlayer = $"../SfxPlayer"
@onready var story_wait_time: Timer = $StoryWaitTime
const HER_DEFAULT = preload("res://Images/portraits/Her/her default.png")
const HOUND_DEFAULT = preload("res://Images/portraits/hound/hound default.png")
const BONER_DEFAULT = preload("res://Images/portraits/boner/boner default.png")
const CAR_ENGINE_START_AND_PULL_AWAY = preload("res://sfx/car engine start and pull away.mp3")


func _input(event: InputEvent) -> void:
	if visible == true:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				skip_next_story_element()

func play_story():
	match current_story:
		0:
			play_story_one()
		1:
			play_story_two()
		99:
			play_story_tbc()

func play_story_one():
	portrait.texture = HER_DEFAULT
	portrait_2.texture = HOUND_DEFAULT
	narration.visible_characters = 0
	narration.text = "Husband: HELP! HELP! Let me go, you bastard! "
	await animate_story_element(narration,"visible_characters",len(narration.text),3, 1)
	narration.visible_characters = 0
	narration.text = "Wife: Huh?! What's going on?! Honey?! Take your dirty hands off my husband!"
	await animate_story_element(portrait,"modulate",Color(1, 1, 1, 1),2,0.1)
	await animate_story_element(portrait_2,"modulate",Color(1, 1, 1, 1),2,0.1)
	await animate_story_element(narration, "visible_characters", len(narration.text),3, 1)
	narration.visible_characters = 0
	narration.text = "Hound: Hahaha! I wish I could but I don't want to. It was nice to meet you ma'am. Cya!"
	await animate_story_element(narration, "visible_characters", len(narration.text),3, 1)
	sfx_player.stream = CAR_ENGINE_START_AND_PULL_AWAY
	sfx_player.play()
	await sfx_player.finished
	narration.visible_characters = 0
	narration.text = "Wife: I won't let him take you away from me my dear! I'm coming, hub!"
	await animate_story_element(narration, "visible_characters", len(narration.text),3)
	await animate_story_element(portrait,"modulate",Color(1, 1, 1, 0),1)
	await animate_story_element(narration,"modulate",Color(1, 1, 1, 0),1)
	story_finished.emit()



func play_story_two():
	portrait.modulate = Color(1, 1, 1, 0)
	portrait_2.modulate = Color(1, 1, 1, 0)
	narration.visible_characters = 0
	narration.text = "Hound: Ouch…! Holly molly, my head…!"
	await animate_story_element(narration, "visible_characters", len(narration.text),3)
	await animate_story_element(portrait,"modulate",Color(1, 1, 1, 1),1)
	await animate_story_element(narration, "visible_characters", len(narration.text),3, 1)
	narration.visible_characters = 0
	narration.text = "Wife: Where's my husband?! What do you want from him?! Talk!"
	await animate_story_element(narration, "visible_characters", len(narration.text),3)
	narration.visible_characters = 0
	narration.text = "Hound: I don't know. I was paid to get him out of town."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),3)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Wife: And you left him on this fricking desert?!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),3)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Hound: Sort of. The moment I dropped him off I saw some spooky ride taking him somewhere."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),3)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Wife: Where did they go?!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Hound: Dunno… They headed south..."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Wife: Darn it! I hope you're telling the truth, or I'll find you and run you over… again and again."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),3)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Hound:..."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),1)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	sfx_player.stream = CAR_ENGINE_START_AND_PULL_AWAY
	sfx_player.play()
	await sfx_player.finished
	story_tween = create_tween()
	story_tween.tween_property(portrait,"modulate",Color(1, 1, 1, 0),1)
	story_tween.parallel().tween_property(portrait_2,"modulate",Color(1, 1, 1, 0),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	story_tween = create_tween()
	story_tween.tween_property(portrait,"modulate",Color(1, 1, 1, 1),1)
	await story_tween.finished
	narration.visible_characters = 0
	narration.text = "Wife: Where are they… I've been driving for an hour and still nothing… Can they be this fast?"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),3)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Huh?! What the hell is that? Could this be..."
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Boner: We meet again…"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	portrait_2.texture = BONER_DEFAULT
	story_tween = create_tween()
	story_tween.tween_property(portrait_2,"modulate",Color(1, 1, 1, 1),1)
	await story_tween.finished
	narration.visible_characters = 0
	narration.text = "Boner: Long time no see!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Wife: I know you have him! Leave him alone!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Boner: Who told you I have him? Hahahahaha!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Wife: Wait a minute, I know this irritating voice!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	narration.text = "Boner: Who's irritating?!"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await story_tween.finished
	await get_tree().create_timer(1).timeout
	narration.visible_characters = 0
	story_tween = create_tween()
	story_tween.tween_property(portrait,"modulate",Color(1, 1, 1, 0),1)
	story_tween.tween_property(portrait_2,"modulate",Color(1, 1, 1, 0),1)
	story_tween.tween_property(narration, "modulate",Color(1, 1, 1, 0),1)
	await story_tween.finished
	story_finished.emit()

func play_story_tbc():
	portrait.texture = load("res://Images/cars/boner 1.png")
	portrait.modulate = Color(1, 1, 1, 1)
	portrait.visible = true
	portrait_2.texture = load("res://Images/cars/evans/thunder mcking 1.png")
	portrait_2.modulate = Color(1, 1, 1, 1)
	portrait.visible = true
	narration.visible_characters = 0
	narration.text = "TO BE CONTINUED - COULDN'T FINISH ALL WE WANTED IN TIME"
	story_tween = create_tween()
	story_tween.tween_property(narration, "visible_characters", len(narration.text),2)
	await get_tree().create_timer(10).timeout
	tbc_finished.emit()


func animate_story_element(element, parameter, target_value, duration, wait_time_after=0):
	currently_animated_element = element
	currently_animated_parameter = parameter
	tween_target_value = target_value
	story_tween = create_tween()
	story_tween.tween_property(element,parameter, target_value,duration)
	await story_tween.finished
	if wait_time_after > 0:
		story_wait_time.start(wait_time_after)
		await story_wait_time.timeout
	currently_animated_element = null
	currently_animated_parameter = ""
	tween_target_value = null
	return true

func skip_next_story_element():
	if story_tween.is_running():
		story_tween.custom_step(99)
	if !story_wait_time.is_stopped():
		story_wait_time.stop()
		story_wait_time.timeout.emit()
	if sfx_player.playing:
		sfx_player.seek(sfx_player.stream.get_length()-0.2)
