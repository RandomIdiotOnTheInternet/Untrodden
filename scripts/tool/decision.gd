extends Resource
class_name Decision

@export var options : Array[DecisionOption]

@export_group("Gated")
@export var gate : DataHolder
@export var deeper_decision : Decision
