extends CharacterBody3D


@export var current_state : StoryAction

## -1 is left, 1 is right
@export var current_direction = 1
@export var current_speed = -1.0
@export var my_cutscene : StoryAction
@export var door_destination : StringName
@export var wandering : bool = false

@onready var character_mesh = $CharacterMesh

var STATE := StoryAction.STATE
var people_in_front : Array

const MIN_SPEED = 0.8
const MAX_SPEED = 1
const DEFAULT_STATE = STATE.Waiting

func _ready():
	if not current_state:
		current_state = StoryAction.new()
	if current_state.actionType == null:
		# Change to default
		current_state.actionType = DEFAULT_STATE
		current_state.modifiers.append(0)
	
	# A speed of -1 is default, meaning that it should be randomized.
	if current_speed == -1.0:
		current_speed = randf_range(MIN_SPEED, MAX_SPEED)
	$Footsteps.speed = current_speed
	
	if my_cutscene:
		$CutsceneArea.monitoring = true
		$CutsceneArea.set_collision_layer_value(6, false)
		
	if door_destination:
		$CutsceneArea.set_collision_layer_value(8, true)
	
	if wandering:
		randomize_self()
	change_state(current_state)

func _process(delta):
	match current_state.actionType:
		STATE.Walking:
			walk(delta, current_speed)
		STATE.Waiting:
			pass
	move_and_slide()
	
func change_state(story_action : StoryAction):
	
	var next_action = story_action.aditional_action
	var new_state = story_action.actionType
	$Footsteps.deactivate()
	match new_state:
		STATE.Walking:
			current_state.actionType = new_state
			var new_direction = story_action.modifiers[0]
			
			character_mesh.set_walking(true)
			current_direction = new_direction
			rotate_self(Vector3(0, 90 * current_direction, 0), false)
			$Footsteps.activate()
		STATE.Waiting:
			velocity = Vector3.ZERO
			current_state.actionType = new_state
			
			character_mesh.set_walking(false)
			var waitTime = story_action.modifiers[0]
			
			# A value of 0 just makes you wait indefinatly (used in cutscenes)
			if waitTime > 0:
				await get_tree().create_timer(waitTime).timeout
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

func rotate_self(rotation_amount : Vector3, add_instead : bool = false):
	if add_instead:
		rotation_degrees += rotation_amount
	else:
		rotation_degrees = rotation_amount

func walk(delta, speed):
	velocity.x = speed * current_direction
	if len(people_in_front) > 0:
		velocity.z = speed * current_direction
	else:
		velocity.z = 0 # This is bad, but works for now :l
	

# Unused - 11/13/2026
func entered_door_area(destination, is_locked, _destination_path):
	if destination == door_destination:
		# enter the door
		change_state(null)

## This function randomizes the character's look, speed, and whatever else is necessary.
func randomize_self():
	current_speed = randf_range(MIN_SPEED, MAX_SPEED)
	var new_state = StoryAction.new()
	new_state.actionType = STATE.Walking
	new_state.modifiers[0] = -current_direction
	change_state(new_state)
	# TODO - Randomize the meshes too
	character_mesh.randomize_self()


func _on_walkng_area_body_entered(body):
	people_in_front = $WalkngArea.get_overlapping_bodies()


func _on_walkng_area_body_exited(body):
	people_in_front = []
