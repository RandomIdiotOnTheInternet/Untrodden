extends PathFollow3D

signal dialogueFinished(waits : bool)

@onready var thought_text = %ThoughtText
@onready var animation_player = $AnimationPlayer
@onready var thought_mesh = $ThoughtMesh

# These are both used to check for proper advencement of dialogue (ex. so that the
# player can't advance a timed dialogue that should do so on its own)
var waiting = false
var waits = false

@export var dialogue_sound : AudioStream

func _ready():
	thought_mesh.mesh.material = thought_mesh.mesh.material.duplicate()
	
	if dialogue_sound:
		thought_text.stream = dialogue_sound


#func _process(delta):
#	progress_ratio = lerp(progress_ratio, current_thought_progress_ratio, delta)

func new_dialogue(new_text : String, waits_afterwards : bool):
	thought_text.text = new_text
	
	fade_in()
	
	if waits_afterwards:
		dialogue_pause()
		waits = true
	else:
		waits = false

func dialogue_pause():
	waiting = true

# Triggered on $ThoughtText.finishedRevealing
func dialogue_finish():
	emit_signal("dialogueFinished", waits)

# Triggered on $ThoughtTimer.timeout and CutscenePlayer on DialogueResume
func dialogue_resume():
	waiting = false
	fade_out()

## -----------------------------------
## ANIMATIONS
## -----------------------------------

func fade_in():
	animation_player.play("fade_in")
	thought_text.visible_ratio = 0
	thought_text.start_reveal()

func fade_out():
	animation_player.play("fade_out")
