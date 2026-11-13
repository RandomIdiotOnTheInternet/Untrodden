extends RichTextLabel

signal finishedRevealing
## Emitted whenever a character is revealed
signal reveal

@export var stream : AudioStream
@export var reveal_speed : float = 1.0
@export var pitch_scale : float = 1.0
@export var keyboard_activated : bool = false
@export var punctuation_pauses : bool = true

@onready var reveal_sound = $RevealSound

const BASE_REVEAL_SPEED = 0.1

var internal_timer: Timer
var revealing : bool = false
var revealing_string: String = ""
var revealing_index : int = 0

# Used for making any PUNCTUATION_CHARS in the revealing text take longer, like
# a pause in a real conversation
const PUNCTUATION_TIME_SCALE = 3
const PUNCTUATION_CHARS = ",?.!:"
const PUNCTUATION_DB = -8.0
const PUNCTUATION_PITCH = 0.1

func _ready():
	internal_timer = Timer.new()
	add_child(internal_timer)
	internal_timer.timeout.connect(reveal_text)
	internal_timer.one_shot = true
	internal_timer.wait_time = Global.text_speed * reveal_speed * BASE_REVEAL_SPEED

func _process(delta):
	# This is for clicking to advance dialogue
	if Input.is_action_just_pressed("interact") and revealing and not keyboard_activated:
		visible_characters = get_total_character_count() - 1
		reveal_sound.play()

func _unhandled_input(event):
	if keyboard_activated and event is InputEventKey and revealing:
		reveal_text()

func start_reveal(reset : bool = true):
	if reset:
		visible_characters = 0
	revealing = true
	reveal_sound.stream.set_stream(0, stream)
	if keyboard_activated:
		pass
	else:
		internal_timer.start()

func stop_reveal():
	revealing = false
	emit_signal("finishedRevealing")
	internal_timer.stop()

func reveal_text():
	if visible_characters < get_total_character_count():
		visible_characters += 1
		emit_signal("reveal")
		if punctuation_pauses:
			if current_character() in PUNCTUATION_CHARS:
				internal_timer.wait_time = Global.text_speed * reveal_speed * BASE_REVEAL_SPEED * PUNCTUATION_TIME_SCALE
				reveal_sound.volume_db = -8.0
				reveal_sound.pitch_scale = pitch_scale + PUNCTUATION_PITCH
			else:
				reveal_sound.volume_db = 0.0
				reveal_sound.pitch_scale = pitch_scale
				internal_timer.wait_time = Global.text_speed * reveal_speed * BASE_REVEAL_SPEED
		
		reveal_sound.play()
		
		if not keyboard_activated:
			internal_timer.start()
		
		
		if visible_characters == get_total_character_count():
			stop_reveal()

# This function returns the current visible character for revealing, if aplicable.
# Avoids errors with indexs of -1 or out of bounds.
func current_character():
	var parsed_text = get_parsed_text()
	var char = ""
	if char == parsed_text[parsed_text.length() - 1]:
		char = parsed_text[visible_characters]
	else:
		char = parsed_text[visible_characters - 1]
	return char

# Quick function for ease of use
func fade_in():
	Juicee.fade(self, 1, 0.1)
	start_reveal()

func fade_out():
	Juicee.fade(self, 0, 0.25)
