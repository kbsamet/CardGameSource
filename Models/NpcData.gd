extends Node

class_name  NpcData

var _name : String
var postion : Vector2
var dialogue_offset : Vector2
static func from_dict(npc_data : Dictionary) -> NpcData:
	var new_npc : NpcData = NpcData.new()
	new_npc._name = npc_data["name"]
	new_npc.postion = npc_data["position"]
	new_npc.dialogue_offset = npc_data["dialogue_offset"]
	return new_npc
