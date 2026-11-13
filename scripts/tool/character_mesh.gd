extends MeshInstance3D

## For this script to work properly:
## All faces should have their first mesh be the neutral one, and the
## second be the blinking (so, index 1 is blinking, 0 is neutral).
## After that, go wild :)
## Leg meshes should have their first frame (index 0) be a standing position.
## Indexes 1 and 2 are for walking, the rest are for everything else.
@export_group("Libraries")
@export var head_libraries : BodyMeshLibrary
@export var head_library_default : int = 0
@export var face_libraries : BodyMeshLibrary
@export var face_library_default : int = 0
@export var torso_libraries : BodyMeshLibrary
@export var torso_library_default : int = 0
@export var arms_libraries : BodyMeshLibrary
@export var arms_library_default : int = 0
@export var legs_libraries : BodyMeshLibrary
@export var legs_library_default : int = 0

var head_library : MeshLibrary
var face_library : MeshLibrary
var torso_library : MeshLibrary
var arms_library : MeshLibrary
var legs_library : MeshLibrary

@export_group("Settings")
@export var blinking_active = true
@export_range(0, 1) var blink_speed = 0.1

## This just affects the animation, not the actual movement speed.
@export_range(0, 2) var step_speed = 1.0

@onready var blink_timer = $FaceMesh/BlinkTimer
@onready var walk_timer = $LegsMesh/WalkTimer

const MIN_BLINK_TIME = 2.5
const MAX_BLINK_TIME = 5
## Again, these bois should correspond to the MeshLibraries.
var current_face : Mesh
var blinking_face : Mesh

var blinking = false
var walking = false

## ---------------------
## ALL-PURPOSE FUNCTIONS
## ---------------------

func _ready():
	# Clears the template mesh shown in the editor
	set_full_mesh(null)
	
	if head_libraries:
		set_head_library(head_library_default)
		set_head_mesh(0)
	if torso_libraries:
		set_torso_library(torso_library_default)
		set_torso_mesh(0)
	if arms_libraries:
		set_arms_library(arms_library_default)
		set_arms_mesh(0, true)
		set_arms_mesh(0, false)
	if face_libraries:
		set_face_library(face_library_default)
		set_expression(0)
	if legs_libraries:
		set_legs_library(legs_library_default)
		set_legs_mesh(0)
	
	if blinking_active:
		blink_timer.start(randf_range(0.1, MAX_BLINK_TIME))

func set_full_mesh(new_mesh):
	$HeadMesh.mesh = null
	$FaceMesh.mesh = null
	$TorsoMesh.mesh = null
	$LegsMesh.mesh = null
	$HeldItemMesh.mesh = null
	$ArmMeshLeft.mesh = null
	$ArmMeshRight.mesh = null
	mesh = new_mesh

func randomize_self():
	if head_libraries:
		set_head_library(randi_range(0, len(head_libraries.libraries) - 1))
		set_head_mesh(0)
	if torso_libraries:
		set_torso_library(randi_range(0, len(torso_libraries.libraries) - 1))
		set_torso_mesh(0)
	if arms_libraries:
		set_arms_library(randi_range(0, len(arms_libraries.libraries) - 1))
		set_arms_mesh(0, true)
		set_arms_mesh(0, false)
	if face_libraries:
		set_face_library(randi_range(0, len(face_libraries.libraries) - 1))
		set_expression(0)
	if legs_libraries:
		set_legs_library(randi_range(0, len(legs_libraries.libraries) - 1))
		set_legs_mesh(0)

## -------------------
## HEAD MESH FUNCTIONS
## -------------------

func set_head_library(index : int):
	head_library = head_libraries.libraries[index]

func set_head_mesh(index : int):
	$HeadMesh.mesh = head_library.get_item_mesh(index)

## -------------------
## FACE MESH FUNCTIONS
## -------------------

# Trigger: BlinkTimer.timeout
func blink():
	if blinking:
		$FaceMesh.mesh = current_face
		blinking = false
		if blinking_active:
			blink_timer.start(randf_range(MIN_BLINK_TIME, MAX_BLINK_TIME))
	else:
		blinking = true
		$FaceMesh.mesh = blinking_face
		blink_timer.start(randf_range(MIN_BLINK_TIME, MAX_BLINK_TIME) * blink_speed)

func set_face_library(index : int):
	face_library = face_libraries.libraries[index]
	# NOTE - This is included for ease of use, but if it generates issues should
	# be changed
	set_face_mesh(0)

func set_face_mesh(index : int):
	$FaceMesh.mesh = face_library.get_item_mesh(index)

func set_expression(index : int):
	current_face = face_library.get_item_mesh(index)
	blinking_face = face_library.get_item_mesh(index + 1)
	$FaceMesh.mesh = current_face

func set_blinking_active(new_bool : bool):
	blinking_active = new_bool
	if !blinking_active:
		blink_timer.stop()
	if blinking:
		pass
	blinking = false
	set_face_mesh(0)

## -------------------
## TORSO MESH FUNCTIONS
## -------------------

func set_torso_library(index : int):
	torso_library = torso_libraries.libraries[index]

func set_torso_mesh(index : int):
	$TorsoMesh.mesh = torso_library.get_item_mesh(index)

## ------------------
## LEG MESH FUNCTIONS
## ------------------
var step_index = 0
const STARTING_STEP_INDEX = 0
const MAX_STEP_INDEX = 2

func set_legs_library(index : int):
	legs_library = legs_libraries.libraries[index]

func set_legs_mesh(index : int):
	$LegsMesh.mesh = legs_library.get_item_mesh(index)

func set_walking(new_bool : bool):
	walking = new_bool
	if walking:
		step()
		walk_timer.start()
	else:
		walk_timer.stop()
		step_index = STARTING_STEP_INDEX
		set_legs_mesh(STARTING_STEP_INDEX)

# Called by WalkTimer.timeout
func step():
	step_index += 1
	if step_index > MAX_STEP_INDEX:
		step_index = STARTING_STEP_INDEX
	set_legs_mesh(step_index)

## ------------------
## ARM MESH FUNCTIONS
## ------------------

func set_arms_library(index : int):
	arms_library = arms_libraries.libraries[index]

func set_arms_mesh(index : int, left_arm : bool):
	if left_arm:
		$ArmMeshLeft.mesh = arms_library.get_item_mesh(index)
	else:
		$ArmMeshRight.mesh = arms_library.get_item_mesh(index)
