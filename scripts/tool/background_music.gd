extends AudioStreamPlayer

func _ready():
	match Global.game_data.day:
		1:
			pass
		2:
			pass
	play()

func _on_finished():
	play()
