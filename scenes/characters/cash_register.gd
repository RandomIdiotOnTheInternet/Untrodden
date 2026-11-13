extends Node3D

var face_index = 0
const MAX_FACE_INDEX = 1

@onready var character_mesh = $CharacterMesh
@export var cutscene_player : Node

func _on_talk_timer_timeout():
	face_index += 1
	if face_index > MAX_FACE_INDEX:
		face_index = 0
	character_mesh.set_face_mesh(face_index)

func stop_talking():
	face_index = 0
	character_mesh.set_face_mesh(face_index)
	$TalkTimer.stop()

func start_talking():
	$TalkTimer.start()
	_on_talk_timer_timeout()

func _on_cutscene_player_dialogue_started():
	start_talking()

func _on_cutscene_player_dialogue_finished(timed : bool):
	if timed:
		stop_talking()
