extends Resource
class_name SaveFile

# Any values listed here are the defaults for new save files
@export var day = 1
@export var day_stage = 1
@export var world_time : DateTime = DateTime.new()
@export var energy = 100
@export var money = 200
@export var current_scene = "res://scenes/world/StoryScenes/day_1/day_1_start.tscn"
@export var interacted_interactions : Array[StringName]
@export var faith_level = 0.0
@export var saved_sister = false
@export var helped_beggar = false
# TODO - Can be used for bringing cutscenes between scenes, needs implementation
# Currently used for the dialogue_void
@export var current_cutscene : Cutscene = Cutscene.new()
@export var known_bmail_addresses : Array[StringName]
@export var current_bmails : Array[BmailData] = [load("res://resources/custom_resources/story/bmails/Day 1/bmail_rage.tres")]
@export var future_incoming_bmails : Array[BmailData]
