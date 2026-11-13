extends Control

signal dialouge_finished(waits_afterwards : bool)
signal dialogue_started()

@onready var player_portrait = $HBoxContainer/PlayerPortrait
@onready var other_portrait = $HBoxContainer/OtherPortrait
@onready var dialogue_text = $HBoxContainer/DialogueText
@onready var screen_notice_label = %ScreenNoticeLabel

# These are for sotring and playing the text sounds for the respective characters
# in a dialogue.
var horizontal_alignment : int = 0

var text_sound_left : AudioStream
var text_sound_right : AudioStream
var text_sound_center : AudioStream

var waits = false

func new_dialogue(dialogue : Dialogue):
	emit_signal("dialogue_started")
	if not visible:
		visible = true
	
	if dialogue.horizontal_alignment != -1:
		horizontal_alignment = dialogue.horizontal_alignment
	dialogue_text.set_horizontal_alignment(horizontal_alignment)
	
	match dialogue.horizontal_alignment:
		HORIZONTAL_ALIGNMENT_LEFT:
			if dialogue.text_sound:
				text_sound_left = dialogue.text_sound
			dialogue_text.stream = text_sound_left
		HORIZONTAL_ALIGNMENT_RIGHT:
			if dialogue.text_sound:
				text_sound_right = dialogue.text_sound
			dialogue_text.stream = text_sound_right
		HORIZONTAL_ALIGNMENT_CENTER:
			if dialogue.text_sound:
				text_sound_center = dialogue.text_sound
			dialogue_text.stream = text_sound_center
		_:
			print("Hmm... text_box got " + str(dialogue.horizontal_alignment) + " as an alignment...")
	
	if dialogue.left_portrait:
		change_portrait(dialogue.left_portrait, HORIZONTAL_ALIGNMENT_LEFT)
	if dialogue.right_portrait:
		change_portrait(dialogue.right_portrait, HORIZONTAL_ALIGNMENT_RIGHT)
	if dialogue.reset_text:
		dialogue_text.text = dialogue.text
	else:
		dialogue_text.text += dialogue.text
	dialogue_text.reveal_speed = dialogue.reveal_speed_modifier
	dialogue_text.pitch_scale = dialogue.pitch_scale
	dialogue_text.start_reveal(dialogue.reset_text)
	Juicee.fade(screen_notice_label, 0, 0.25)
	waits = dialogue.waits

func change_portrait(portrait : CompressedTexture2D, alignment : int):
	if portrait: # The portrait is only changed if the portrait is set.
		if alignment == HORIZONTAL_ALIGNMENT_LEFT: # The player
			player_portrait.texture = portrait
		elif alignment == HORIZONTAL_ALIGNMENT_RIGHT: # Everyone else
			other_portrait.texture = portrait
		else:
			print("Something went wrong! text_box got " + str(alignment) + " as the allignment :(")


func _on_finished_revealing():
	emit_signal("dialouge_finished", waits)
	if waits:
		screen_notice_label.fade_in()

func fade_out():
	$"../UI Animations".play("RESET")
