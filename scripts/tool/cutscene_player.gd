extends AnimationPlayer

signal cutscene_end(cutsceneID : StringName)
signal cutscene_start(cutsceneID : StringName)
signal cutscene_paused()
signal new_decision_start(decisionID : StringName)
signal dialogue_started()
signal dialogue_resumed()
## Outputted whenever the current dialogue is done doing its thing
signal dialogue_finished(waits : bool)

var focused = false
var ready_to_swap = false

## For the purposes of this script, it's assumed that all connected nodes have a cutscene player that's
## also stored as a @onready variable called "cutscene_player".

var connected_cutscene_player : Node

## Currently unused except for bug tracking - 8/10/2026
@export var current_cutscene : Cutscene

func _ready():
	$Timer.start()
	await $Timer.timeout
	Global.player_ui.text_box.dialouge_finished.connect(dialogue_finish)
	Global.player_ui.decision_made.connect(decision_made)

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if Global.current_control_state == Global.CONTROL_STATE.CutsceneAdvance and focused:
			Global.change_control_state(Global.CONTROL_STATE.Cutscene)
			
			if ready_to_swap and connected_cutscene_player:
				change_focus()
			else:
				resume()

func start_cutscene(connected_player : Node, cutscene : Cutscene, 
has_starting_focus : bool):
	current_cutscene = cutscene
	connected_cutscene_player = connected_player
	play(cutscene.cutscene_id)
	emit_signal("cutscene_start", cutscene.cutscene_id)
	Global.player_ui.start_cutscene(cutscene.cutscene_id) # NOTE - Different function
	if is_in_group("player"):
		Global.game_data.current_cutscene = cutscene
		Global.old_control_state = Global.current_control_state
		Global.current_gamestate = Global.GAMESTATE.InCutscene
	if has_starting_focus:
		focused = true
		if connected_cutscene_player and connected_cutscene_player != self:
			connected_cutscene_player.start_cutscene(self, cutscene, false)
	else:
		pause()

func end_cutscene(cutsceneID : String):
	emit_signal("cutscene_end", cutsceneID)
	Global.player_ui.end_cutscene(cutsceneID)
	if connected_cutscene_player:
		# This looks terrible but it works so ok 👍
		if connected_cutscene_player.connected_cutscene_player:
			connected_cutscene_player.gain_focus()
		connected_cutscene_player = null
	else:
		Global.player_ui.text_box.fade_out()
	stop()
	if is_in_group("player"):
		Global.current_gamestate = Global.GAMESTATE.InGame
		Global.change_control_state(Global.old_control_state)

func resume():
	if is_animation_active() and not is_playing() and focused:

		emit_signal("dialogue_resumed")
		Global.player_ui.dialogue_resumed()
		play()

func change_focus():
	ready_to_swap = false
	connected_cutscene_player.gain_focus()
	focused = false
	pause()

func gain_focus():
	if connected_cutscene_player.focused:
		focused = true
		connected_cutscene_player.focused = false
		resume()
	else:
		print("Error: gain_focus() was called but I already had the focus :(")

func cutscene_pause():
	pause()
	emit_signal("cutscene_paused")

# Activated by thoughts.dialogueFinished
func dialogue_finish(waits : bool):
	emit_signal("dialogue_finished", waits)
	Global.player_ui.dialogue_finished(waits)
	if waits:
		if connected_cutscene_player:
			connected_cutscene_player.emit_signal("dialogue_finished", waits)
	else:
		# Stops the flow for a bit
		$Timer.start()
		await $Timer.timeout
		resume()

# The text_sound and portrait parameters remeber the last input, so
# you don't have to put them in every time :)
func new_dialogue(dialogue : Dialogue, swap_focus : bool = true):
	
	# Check for gates / change the dialogue to the deeper ones if gates aren't met
	while dialogue.gate:
		if dialogue.gate.check_value():
			if dialogue.deeper_dialogue:
				dialogue = dialogue.deeper_dialogue
			else:
				break
		else:
			break
	
	if len(dialogue.text) > 0: # Empty dialogues are skipped
		emit_signal("dialogue_started")
		cutscene_pause()
		
		# This is for default alignment
		if dialogue.horizontal_alignment == -1 and Global.player_ui.text_box.horizontal_alignment == -1:
			if is_in_group("player"):
				dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			else:
				dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		if swap_focus and connected_cutscene_player:
			ready_to_swap = true
		dialogue.apply_self()

func new_decision(decision : Decision):
	while decision.gate:
		if decision.gate.check_value():
			if decision.deeper_decision:
				decision = decision.deeper_decision
			else:
				break
		else:
			break
	
	Global.player_ui.new_decision(decision)
	emit_signal("new_decision_start", decision)
	pause()

func decision_made(option_picked : DecisionOption):
	if focused:
		change_cutscene(option_picked.cutscene, 0.0)
		if connected_cutscene_player:
			if option_picked.ccp_cutscene:
				connected_cutscene_player.change_cutscene(option_picked.ccp_cutscene, 0.0)
			else:
				connected_cutscene_player.change_cutscene(option_picked.cutscene, 0.0)
			
			if focused:
				connected_cutscene_player.pause()
			else:
				pause()

func change_cutscene(cutscene : Cutscene, time : float):
	while cutscene.gate:
		if cutscene.gate.check_value():
			if cutscene.deeper_cutscene:
				cutscene = cutscene.deeper_cutscene
			else:
				# If there's a gate, but no deeper cutscene,
				# we return false and cancel the cutscene change.
				return false
		else:
			break
	current_cutscene = cutscene
	
	if has_animation(cutscene.cutscene_id):
		play(cutscene.cutscene_id)
		seek(time) # Jumps the animation ahead
	else:
		print("ERROR - Cutscene_player got a bad cutscene_id! It was: " + cutscene.cutscene_id)

func change_scene(scene_path : StringName, auto_cutscene : Cutscene = null):
	Global.change_scene(scene_path)
	Global.game_data.current_cutscene = auto_cutscene

func fade_away_text_box():
	Juicee.fade(Global.player_ui.text_box, 0.0, 3.0)
