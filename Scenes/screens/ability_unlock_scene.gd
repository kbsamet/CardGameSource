extends Control

@onready var enchant : TextureRect = $Panel/VBoxContainer/HBoxContainer/Enchant
@onready var empower : TextureRect = $Panel/VBoxContainer/HBoxContainer2/Empower
@onready var shield_up : TextureRect = $"Panel/VBoxContainer/HBoxContainer2/Shield Up"
@onready var empower_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar2
@onready var shield_up_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar
@onready var enchantTooltip : TooltipNode = $Panel/VBoxContainer/HBoxContainer/Enchant/Control/EnchantTooltip
@onready var empowerTooltip : TooltipNode = $Panel/VBoxContainer/HBoxContainer2/Empower/EmpowerTooltip
@onready var shieldUpTooltip : TooltipNode = $"Panel/VBoxContainer/HBoxContainer2/Shield Up/ShieldUpTooltip"
@onready var infoText : RichTextLabel = $Label

var gameOverScreen : PackedScene = preload("res://Scenes/screens/GameOverScreen.tscn")
const ACTION_INTERVAL: float = 0.006 # 200ms interval between actions
var time_since_last_action: float = 0.0
var held_ability : String = "none"
func _ready() -> void:
	empower_progress.max_value = 300
	shield_up_progress.max_value = 300
	empower_progress.value = db.saveData.ability_progresses["Empower"]
	shield_up_progress.value = db.saveData.ability_progresses["Shield Up"]
	set_texts()
	set_progress()
	

func _process(delta: float) -> void:
	time_since_last_action += delta
	if held_ability != "none" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and time_since_last_action >= ACTION_INTERVAL:
		if db.saveData.souls > 0 and db.saveData.ability_progresses[held_ability] < 300:
			db.saveData.ability_progresses[held_ability] += 1
			db.saveData.souls -= 1
			set_texts()
			set_progress()
			if db.saveData.ability_progresses[held_ability] == 300:
				match held_ability:
					"Empower":
						empower.material = null
					"Shield Up":
						shield_up.material = null
		time_since_last_action = 0.0  # Reset timer
	
func set_texts() -> void:
	infoText.text = "[center]You are dead.\nYou have collected [color=d68b45]"+str(db.saveData.souls)+"[/color] souls.\nUse them to unlock new powers."
	
	empowerTooltip.set_data(db.get_ability("Empower").tooltip + \
	("\n\n[color=e39347]"+str(db.saveData.ability_progresses["Empower"])+"/300 souls for unlock[/color]" if db.saveData.ability_progresses["Empower"] != 300 else "\n\n[color=e39347]Unlocked[/color]"))
	shieldUpTooltip.set_data(db.get_ability("Shield Up").tooltip + \
	 ("\n\n[color=e39347]"+str(db.saveData.ability_progresses["Shield Up"])+"/300 souls for unlock[/color]" if db.saveData.ability_progresses["Shield Up"] != 300 else "\n\n[color=e39347]Unlocked[/color]"))
	enchantTooltip.set_data(db.get_ability("Enchant").tooltip + "\n\n[color=e39347]Unlocked[/color]")

func set_progress() -> void:
	empower_progress.value = db.saveData.ability_progresses["Empower"]
	shield_up_progress.value = db.saveData.ability_progresses["Shield Up"]
	if empower_progress.value == 300:
		empower.material = null
	if shield_up_progress.value == 300:
		shield_up.material = null
func _on_empower_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			held_ability = "Empower"
		else:
			held_ability = "none"

func _on_shield_up_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			held_ability = "Shield Up"
		else:
			held_ability = "none"


func _on_button_pressed() -> void:
	db.saveData.save_game()
	get_tree().change_scene_to_packed(gameOverScreen)
