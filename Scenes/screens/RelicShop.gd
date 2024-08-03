extends Control
class_name RelicShopScene

@onready var relicContainer = $RelicContainer
var tavernScene = preload("res://Scenes/screens/TavernScreen.tscn")
var relicForSaleScene = preload("res://Scenes/ui/RelicForSale.tscn")
var chosen_relics : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var relics_copy = db.relics.duplicate(true)
	for i in range(3):
		var chosen_index = randi_range(0,relics_copy.size()-1)
		var chosen_relic = relics_copy[chosen_index]
		chosen_relics[i] = chosen_relic
		relics_copy.remove_at(chosen_index)
		var chosen_relic_scene = relicForSaleScene.instantiate() as RelicForSaleScene
		relicContainer.add_child(chosen_relic_scene)
		chosen_relic_scene.set_data(chosen_relic,i)
		chosen_relic_scene.relic_chosen.connect(_on_relic_chosen)

func _on_relic_chosen(id:int):
	var relic_scenes = relicContainer.get_children()
	var chosen_relic
	for relic in relic_scenes:
		if relic.id == id:
			chosen_relic = relic
			break
	relicContainer.remove_child(chosen_relic)
	chosen_relic.queue_free()
	db.player.add_relic(chosen_relic.relic_data,true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	db.clickPlayer.play()
	get_tree().change_scene_to_packed(tavernScene)
