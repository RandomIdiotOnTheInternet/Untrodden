extends Node3D

# this_story_action
@export var this_story_action : StoryAction
@export var cutscene_only = false
## If true, queue_free()s itself.
@export var temporary = true
@export var npc_point = false

func _on_person_entered(body):
	
	if cutscene_only && (Global.current_gamestate != Global.GAMESTATE.InCutscene):
		return
	
	var interactor = body
	var pointType = this_story_action.actionType
	if (interactor.is_in_group("player") and npc_point) or (not interactor.is_in_group("player") and not npc_point):
		return
	
	## NOTICE - This match statement can probably be remonved xd 12/17/2025
	match pointType:
		2: # Run
			pass
		3: # Talk
			var talk_text = this_story_action.modifiers[0]
			var talk_time = this_story_action.modifiers[1]
			interactor.new_dialogue(talk_text, talk_time)
		4: # EnterDoor
			pass
		5: # Think
			pass
		6: # Pray
			pass
		7: # Cutscene
			interactor.cutscene_player.start_cutscene(null, this_story_action.modifiers[0], true)
		_: # Any state not defined above :)
			interactor.change_state(this_story_action)
	
	if temporary:
		queue_free()
