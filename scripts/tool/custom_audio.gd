extends AudioStreamPlayer3D

@export var active : bool = false
@export_range(0.0, 5.0) var speed : float = 1


func _ready():
	if active:
		activate()

func activate():
	active = true
	play()
	$Timer.wait_time = speed * 0.5
	$Timer.start()

func deactivate():
	active = false
	$Timer.stop()

func trigger():
	play()
