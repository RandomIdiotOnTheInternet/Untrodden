extends Node3D

@export var on = false

const MAX_LIGHT_ENERGY = 2.0

func _ready():
	if on:
		change_animation("static")
		$SpotLight3D.light_energy = MAX_LIGHT_ENERGY
	else:
		change_animation("off")
		$SpotLight3D.light_energy = 0.0

func change_animation(animation : StringName):
	$AnimationPlayer.play(animation)
