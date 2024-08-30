extends Control

var chooseRewardScene : PackedScene = preload("res://Scenes/screens/RewardSelectScreen.tscn")
var npcScene : PackedScene = preload("res://Scenes/ui/NpcScene.tscn")

var npcs : Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for npc : String in db.npcs.keys():
		var npc_data : NpcData = NpcData.from_dict(db.npcs[npc])
		var npc_scene : NPCNode = npcScene.instantiate()
		npcs[npc] = npc_scene
		add_child(npc_scene)
		npc_scene.set_data(npc_data)
		npc_scene.started_dialogue.connect(on_dialogue_started)
		npc_scene.dialogue_ended.connect(on_dialogue_ended)
		

func on_dialogue_started() -> void:
	for n in get_children():
		if n is NPCNode:
			n.dialogue_free = false

func on_dialogue_ended() -> void:
	for n in get_children():
		if n is NPCNode:
			n.dialogue_free = true


func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		for n in get_children():
			if n is NPCNode:
				for k in n.get_children():
					if k is DialogueBalloon:
						k._on_balloon_gui_input(event)
						db.clickPlayer.play()


func _on_button_pressed() -> void:
	db.clickPlayer.play()
	get_tree().change_scene_to_packed(load("res://Scenes/screens/RewardSelectScreen.tscn"))
