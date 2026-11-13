extends Area3D

var person : Node

func _on_person_entered_area(area):
	person = area.get_parent() # This should get the person. If not, then... uhoh
	
	if person.wandering:
		person.current_direction = -person.current_direction
		person.randomize_self()
