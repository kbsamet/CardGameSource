extends Control
@onready var enchant : TextureRect = $Panel/VBoxContainer/HBoxContainer/Enchant
@onready var empower : TextureRect = $Panel/VBoxContainer/HBoxContainer2/Empower
@onready var shield_up : TextureRect = $"Panel/VBoxContainer/HBoxContainer2/Shield Up"
@onready var empower_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar2
@onready var shield_up_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar
@onready var enchantTooltip : TooltipNode = $Panel/VBoxContainer/HBoxContainer/Enchant/Control/EnchantTooltip
@onready var empowerTooltip : TooltipNode = $Panel/VBoxContainer/HBoxContainer2/Empower/EmpowerTooltip
@onready var shieldUpTooltip : TooltipNode = $"Panel/VBoxContainer/HBoxContainer2/Shield Up/ShieldUpTooltip"

@onready var select_reward_screen : PackedScene = load("res://Scenes/screens/RewardSelectScreen.tscn")
@onready var red_outline : ShaderMaterial = preload("res://Shaders/outline_red.tres").duplicate()
@onready var blue_outline : ShaderMaterial = preload("res://Shaders/outline_blue.tres").duplicate()
@onready var gray_tint : ShaderMaterial = preload("res://Shaders/gray_tint.tres").duplicate()


var selected_ability : String = "Enchant"

func _ready() -> void:
	red_outline.set_shader_parameter("width",3)
	blue_outline.set_shader_parameter("width",3)
	enchant.material = red_outline
	empower_progress.max_value = 300
	shield_up_progress.max_value = 300
	empower_progress.value = db.saveData.ability_progresses["Empower"]
	shield_up_progress.value = db.saveData.ability_progresses["Shield Up"]
	if empower_progress.value == 300:
		empower.material = null
	if shield_up_progress.value == 300:
		shield_up.material = null
	set_texts()
	
func set_texts() -> void:
	empowerTooltip.set_data(db.get_ability("Empower").tooltip + \
	("\n\n[color=e39347]"+str(db.saveData.ability_progresses["Empower"])+"/300 souls for unlock[/color]" if db.saveData.ability_progresses["Empower"] != 300 else "\n\n[color=e39347]Unlocked[/color]"))
	shieldUpTooltip.set_data(db.get_ability("Shield Up").tooltip + \
	 ("\n\n[color=e39347]"+str(db.saveData.ability_progresses["Shield Up"])+"/300 souls for unlock[/color]" if db.saveData.ability_progresses["Shield Up"] != 300 else "\n\n[color=e39347]Unlocked[/color]"))
	enchantTooltip.set_data(db.get_ability("Enchant").tooltip + "\n\n[color=e39347]Unlocked[/color]")


func _on_enchant_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			selected_ability = "Enchant"
			enchant.material = red_outline
			shield_up.material = gray_tint if db.saveData.ability_progresses["Shield Up"] < 300 else null
			empower.material = gray_tint if db.saveData.ability_progresses["Empower"] < 300 else null


func _on_empower_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			if db.saveData.ability_progresses["Empower"] < 300:
				return
			selected_ability = "Empower"
			enchant.material = null
			shield_up.material = gray_tint if db.saveData.ability_progresses["Shield Up"] < 300 else null
			empower.material = red_outline


func _on_shield_up_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			if db.saveData.ability_progresses["Shield Up"] < 300:
				return
			selected_ability = "Shield Up"
			enchant.material = null
			shield_up.material = blue_outline
			empower.material = gray_tint if db.saveData.ability_progresses["Empower"] < 300 else null


func _on_button_pressed() -> void:
	db.player.ability = db.get_ability(selected_ability)
	get_tree().change_scene_to_packed(select_reward_screen)
