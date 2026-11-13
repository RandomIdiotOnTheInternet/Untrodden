extends Control

const computer_path = "res://scenes/UI/computer.tscn"

func _ready():
	ResourceLoader.load_threaded_request(computer_path)

func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(computer_path, progress)
	
	if progress[0] == 1:
		var packedScene = ResourceLoader.load_threaded_get(computer_path)
		$AnimationPlayer.play("done_loading")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_packed(packedScene)
