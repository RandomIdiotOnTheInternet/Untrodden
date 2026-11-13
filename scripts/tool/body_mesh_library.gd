extends Resource
class_name BodyMeshLibrary

@export var libraries : Array[MeshLibrary]

func get_item_library(index : int):
	return libraries[index]

func get_random_library():
	return libraries[randi_range(0, len(libraries) - 1)]
