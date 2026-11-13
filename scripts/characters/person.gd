extends CharacterBody3D

@export_enum("Walking", "Waiting", "Cutscene", "EnterDoor") var current_state : String

@export var current_stat : StoryAction = StoryAction.new()

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
	if current_stat.actionType == null:
		# Change to default
		current_stat.actionType = DEFAULT_STATE
	
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
	match current_state:
		"Walking":
			walk(delta, current_speed)
		"Waiting":
			pass
	move_and_slide()
	
func change_state(new_state : String):
	$Footsteps.deactivate()
	match new_state:
		"Walking":
			current_state = "Walking"
			rotation_degrees.y = 90.0 * current_direction
			character_mesh.set_walking(true)
			$Footsteps.activate()
		"Waiting":
			current_state = "Waiting"
			character_mesh.set_walking(false)
		"Cutscene":
			pass
		"EnterDoor":
			current_state = "EnterDoor"

func walk(delta, speed):
	velocity.x = speed * current_direction
	if len(people_in_front) > 0:
		velocity.z = speed * current_direction
	else:
		velocity.z = 0
	

func entered_door_area(destination, is_locked, _destination_path):
	if destination == door_destination:
		# enter the door
		change_state("EnterDoor")

## This function randomizes the character's look, speed, and whatever else is necessary.
func randomize_self():
	current_speed = randf_range(MIN_SPEED, MAX_SPEED)
	change_state("Walking")
	# TODO - Randomize the meshes too
	character_mesh.randomize_self()


func _on_walkng_area_body_entered(body):
	people_in_front = $WalkngArea.get_overlapping_bodies()


func _on_walkng_area_body_exited(body):
	people_in_front = []
