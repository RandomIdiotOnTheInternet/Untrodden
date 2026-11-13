extends Node3D

signal interacted(cutscene)

## Just a descriptior for the player and stuff
@export var interaction_details : String
## Needs to be exactly the same as the cutscene's name
@export var cutscene : Cutscene
## After every interaction, the interaction_id gets changed to the topmost element.
@export var deeper_interactions : Array[Cutscene]
@export var data_requirements : Array[DataHolder]
@export var time_requirements : Array[DateTime]
## If True, it's unavailable.
@export var interactable = true
## This is the width of the collision box.
@export var collision_range = 0.5
@export var instant = false
@export var one_shot = false
# If false, will not get logged as an interacted interaction.
@export var interaction_logable = true

@onready var interaction_label = %InteractionLabel
@onready var interaction_area = $InteractionArea
# The instigator is the one starting the cutscene, while the connected is the
# one who's being added to the cutscene.
## NOTICE - The instigator is always the parent node by default. Top level is enabled.
var instigator : Node = null
var connected_node : Node = null
const INTERACTION_KEY_PATH = "res://assets/images/UI/Keyboard & Mouse/Default/keyboard_shift.png"

func _ready():
	instigator = get_parent()
	check_requirements()
	
	if cutscene:
		if cutscene.cutscene_id in Global.game_data.interacted_interactions:
			print("Interaction Point - " + name + " queued free due to already being interacted.")
			queue_free()

func entered(body):
	if body != instigator:
		connected_node = body
	if body.is_in_group("player"):
		if instant:
			begin_interaction()
		else:
			if check_requirements():
				$InteractionDisplay.show()

func exited(body):
	connected_node = null
	if body.is_in_group("player"):
		$InteractionDisplay.hide()

func _input(event):
	if Global.current_control_state == Global.CONTROL_STATE.HasControl:
		if Input.is_action_just_pressed("shift") and interactable:
			if (instigator.is_in_group("player") or connected_node.is_in_group("player")):
				var body_list = $InteractionArea.get_overlapping_bodies()
				for body in body_list:
					if body.is_in_group("player"): # Working on this...
						$InteractionDisplay.hide()
						begin_interaction()
						return

func begin_interaction():
	emit_signal("interacted")
	if instigator: print("Interaction - Instigator: " + instigator.name)
	if connected_node: print("Interaction - Connected Node: " + connected_node.name)
	
	if connected_node:
		instigator.cutscene_player.start_cutscene(connected_node.cutscene_player, 
		cutscene, true)
	else:
		instigator.cutscene_player.start_cutscene(null, cutscene, true)
	if one_shot:
		if interaction_logable:
			Global.current_interacted_interactions.append(cutscene.cutscene_id)
		queue_free()
	if len(deeper_interactions) > 0:
		cutscene = deeper_interactions[0]
		deeper_interactions.remove_at(0)
	if instant:
		instant = false # prevents loops :)

# This function should return true if we want the interaction to be visible
# even if the requirement isn't met.
func check_requirements():
	for requirement in data_requirements:
		if not requirement.check_value():
			interaction_label.text = requirement.description
			interactable = false
			return true
	for requirement in time_requirements:
		if not requirement.is_equal_to(Global.game_data.world_time):
			interactable = false
			return false
	interaction_label.text = interaction_details + "\n[img]" + INTERACTION_KEY_PATH + "[/img]"
	interactable = true
	return true
