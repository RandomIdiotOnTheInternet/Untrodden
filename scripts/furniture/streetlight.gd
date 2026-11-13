extends Node3D

@export var on = false
@export var flickering = false
@export var pole_visible = true

func _ready():
	if not on:
		$BulbMesh.hide()
		$SpotLight3D.light_energy = 0
	if not pole_visible:
		$Mesh.hide()

func _process(delta):
	if on and flickering and Global.flashing_lights:
		$SpotLight3D.light_energy = randf_range(0.0, 4.0)
