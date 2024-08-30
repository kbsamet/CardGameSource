extends Control
class_name RelicShopScene

@onready var relicContainer : HBoxContainer = $RelicContainer
var tavernScene : PackedScene = preload("res://Scenes/screens/TavernScreen.tscn")
var relicForSaleScene : PackedScene = preload("res://Scenes/ui/RelicForSale.tscn")
var chosen_relics : Dictionary = {}
var relics : Array[RelicData]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	relics = db.npcs["Wizard"].relics
	for i in range(3):
		chosen_relics[i] = relics[i]
		var chosen_relic_scene : RelicForSaleScene = relicForSaleScene.instantiate()
		relicContainer.add_child(chosen_relic_scene)
		chosen_relic_scene.set_data(relics[i],i)
		chosen_relic_scene.relic_chosen.connect(_on_relic_chosen)

func _on_relic_chosen(id:int) -> void:
	var relic_scenes : Array[Node] = relicContainer.get_children()
	var chosen_relic : RelicForSaleScene
	for relic in relic_scenes:
		if relic.id == id:
			chosen_relic = relic
			break
	relicContainer.remove_child(chosen_relic)
	chosen_relic.queue_free()
	db.player.add_relic(chosen_relic.relic_data,true)

func _on_button_pressed() -> void:
	db.clickPlayer.play() 
	get_tree().change_scene_to_packed(tavernScene)
