extends Control

var chooseRewardScene = preload("res://Scenes/screens/RewardSelectScreen.tscn")
var npcScene = preload("res://Scenes/ui/npc.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for npc in db.npcs.values():
		var npc_data = NpcData.from_dict(npc)
		var npc_scene = npcScene.instantiate()
		add_child(npc_scene)
		npc_scene.set_data(npc_data)
		npc_scene.started_dialogue.connect(on_dialogue_started)
		npc_scene.dialogue_ended.connect(on_dialogue_ended)


func on_dialogue_started():
	for n in get_children():
		if n is NPCNode:
			n.dialogue_free = false

func on_dialogue_ended():
	for n in get_children():
		if n is NPCNode:
			n.dialogue_free = true


func _on_gui_input(event):
	if event is InputEventMouseButton:
		for n in get_children():
			if n is NPCNode:
				for k in n.get_children():
					if k is DialogueBalloon:
						k._on_balloon_gui_input(event)


func _on_button_pressed():
	get_tree().change_scene_to_packed(chooseRewardScene)
