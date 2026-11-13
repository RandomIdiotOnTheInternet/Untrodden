extends CharacterBody3D

var STATE := StoryAction.STATE
var current_state = STATE.Waiting # NOTE - Could be changed to an export if helpful!
var speed = 0.75
var current_direction = 1 # 1 or -1 for left and right

# File path to the next scene
var current_destination_path : StringName

## This property automatically looks for a cutscene player. If it doesn't find one,
## please set it manually.
@export var cutscene_player : Node = null
@onready var character_mesh = $CharacterMesh
@onready var player_ui = $PlayerUI

func _ready():
	if cutscene_player == null:
		if $CutscenePlayer:
			cutscene_player = $CutscenePlayer
		else:
			print("No cutscene player found for MainCharacter...")
	
	Global.world_timer.start() # This works well, as now in scenes without the
	# main char the timer is stopped
	# I'm not even sure if we want this tbh but ok
	
	if Global.debug == true:
		print("MainCharacter._ready(): Debug is enabled!")
		#var test = StoryAction.new()
		#test.modifiers = [-1]
		#test.actionType = STATE.Walking
		#change_state(test)
		Global.change_control_state(Global.CONTROL_STATE.HasControl)

func change_state(story_action : StoryAction):
	
	var next_action = story_action.aditional_action
	var new_state = story_action.actionType
	$Audio/Footsteps.deactivate()
	match new_state:
		STATE.Walking:
			current_state = new_state
			var new_direction = story_action.modifiers[0]
			
			character_mesh.set_walking(true)
			current_direction = new_direction
			rotate_mesh(Vector3(0, 90 * current_direction, 0), false)
			$Audio/Footsteps.activate()
		STATE.Waiting:
			current_state = new_state
			
			character_mesh.set_walking(false)
			var waitTime = story_action.modifiers[0]
			
			# A value of 0 just makes you wait indefinatly (used in cutscenes)
			if waitTime > 0:
				$WaitingTimer.start(waitTime)
				await $WaitingTimer.timeout
			if next_action: change_state(next_action)
		STATE.Running:
			current_state = new_state
			var new_direction = story_action.modifiers[0]
			
			character_mesh.set_walking(true)
			current_direction = new_direction
		STATE.EnterDoor:
			character_mesh.rotation_degrees.y = 180.0
			character_mesh.set_walking(true)
			Global.change_control_state(Global.CONTROL_STATE.NoControl)
		STATE.Cutscene:
			character_mesh.set_walking(false)
			current_state = new_state
		STATE.CutsceneWait:
			current_state = new_state
		STATE.Sleep:
			character_mesh.set_walking(false)
			current_state = new_state
			#var new_direction = story_action.modifiers[0]
			#current_direction = new_direction
			$AnimationPlayer.play("sleeping")
			#$CharacterMesh.rotation_degrees.y = 90.0 * current_direction
		null:
			push_error("Uhoh, null state! :(")

func _process(delta):
	match current_state:
			STATE.Waiting:
				velocity = velocity / 2
			STATE.Walking:
				walk(delta, 1)
			STATE.Running:
				walk(delta, 2)
			STATE.EnterDoor:
				walk(delta, 1)
	
	move_and_slide()
	
	if Global.current_control_state == Global.CONTROL_STATE.HasControl and Global.current_gamestate == Global.GAMESTATE.InGame:
		## These "just pressed" checks are for state changes, so we don't have to do them every frame.
		if Input.is_action_just_pressed("left"):
			var walking_action = StoryAction.new()
			walking_action.modifiers.append(-1)
			walking_action.actionType = STATE.Walking
			change_state(walking_action)
			
		if Input.is_action_just_pressed("right"):
			var walking_action = StoryAction.new()
			walking_action.modifiers.append(1)
			walking_action.actionType = STATE.Walking
			change_state(walking_action)
		
		if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			var waiting_action = StoryAction.new()
			waiting_action.modifiers.append(0)
			waiting_action.actionType = STATE.Waiting
			change_state(waiting_action)
			return

func walk(delta, speed_modifier):
	velocity.x = speed * current_direction * speed_modifier
## ------------------------------------------
## HELPER METHODS - mostly used for cutscenes
## ------------------------------------------
func rotate_mesh(rotation_amount : Vector3, add_instead : bool = false):
	if add_instead:
		character_mesh.rotation_degrees += rotation_amount
	else:
		character_mesh.rotation_degrees = rotation_amount

func animation_reset():
	$AnimationPlayer.play("RESET")
