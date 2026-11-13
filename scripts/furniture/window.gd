extends MeshInstance3D

@export var night_material : Material

func _ready():
	if Global.game_data.world_time.hour > 18: # Needs implemented
		$Glass.mesh.material = night_material
		$SpotLight3D.light_energy = 0
		
