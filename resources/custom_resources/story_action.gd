extends Resource
class_name StoryAction

@export_enum("Move", "Wait", "Run", "Talk", "EnterDoor", "Think", "Pray",
"Cutscene", "CutsceneWait", "Sleep") var actionType
@export var modifiers : Array = [0] # 0 is default.
@export var aditional_action : StoryAction

enum STATE{Walking, Waiting, Running, Talking, EnterDoor, Think, Pray, Cutscene,
CutsceneWait, Sleep}
