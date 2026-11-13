extends Resource
class_name DecisionOption

@export var cutscene : Cutscene
# ccp - connected cutscene player. If left blank will copy decision_id.
@export var ccp_cutscene : Cutscene

# These are unnecessary for NPC decisions. Only useful for players,
# so they can see what the decision is and why to pick the options.
@export_multiline("Glory to God :)") var decision_description : String
@export_multiline() var decision_reasoning : String = "[color=dark_gray]\"\""

@export var deeper_option : DecisionOption
@export var costs : Array[DataHolder]
@export var requirements : Array[DataHolder]
@export var requirements_hide : bool = false
# This is an unfortunate fix I needed for the Bmails. If you find a way around it,
# please implement :)
@export_multiline() var decision_result : String
