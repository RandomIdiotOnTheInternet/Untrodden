extends Resource
class_name Cutscene

@export var cutscene_id : StringName

@export_group("Gated")
@export var gate : DataHolder
@export var deeper_cutscene : Cutscene
