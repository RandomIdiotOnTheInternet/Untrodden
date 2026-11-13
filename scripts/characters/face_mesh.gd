extends MeshInstance3D

@export var blinking_active = true
@export var face_library : MeshLibrary

const MIN_BLINK_TIME = 2.5
const MAX_BLINK_TIME = 3.5

@export var IDHolder : Node

var face_mesh : Mesh
var blinking_mesh : Mesh


func _ready():
	change_expression(IDHolder.face_id, IDHolder.blinking_id)
	mesh = face_mesh
	
	$BlinkTimer.start()

func blink():
	mesh = blinking_mesh
	$OpenEyesTimer.start()

func open_eyes():
	mesh = face_mesh
	$BlinkTimer.start(randf_range(MIN_BLINK_TIME, MAX_BLINK_TIME))

func change_expression(new_expression_id : int, new_blinking_id : int):
	face_mesh = face_library.get_item_mesh(IDHolder.face_id)
	blinking_mesh = face_library.get_item_mesh(IDHolder.blinking_id)

func set_blinking_active(new_bool : bool):
	blinking_active = new_bool
