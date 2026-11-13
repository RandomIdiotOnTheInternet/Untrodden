extends RichTextLabel

# Configuration
@export var chars_per_tap : int = 3   # How many letters appear per key press
@export var is_active : bool = false # Controlled by your game manager

signal email_finished

func _ready():
	# Start with everything hidden
	visible_characters = 0
	set_process_unhandled_input(is_active)

func _unhandled_input(event):
	# We only care if the player is "working" and presses a key
	if is_active and event is InputEventKey and event.pressed:
		_reveal_text()

func _reveal_text():
	# Increase the count of visible characters
	visible_characters += chars_per_tap
	
	# Optional: Add a 'typing' sound effect here
	# $TypingSound.play()

	# Check if we've reached the end of the email
	if visible_characters >= get_total_character_count():
		_finish_email()

func _finish_email():
	is_active = false
	emit_signal("email_finished")
	set_process_unhandled_input(false)

# Call this from your UI or Game Manager to start a new email
