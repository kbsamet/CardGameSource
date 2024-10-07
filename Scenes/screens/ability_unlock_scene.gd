extends Control
@onready var enchant : SkillUpgradeRect = $Panel/VBoxContainer/HBoxContainer/Enchant
@onready var shield_up : SkillUpgradeRect = $"Panel/VBoxContainer/HBoxContainer2/Shield Up" 
@onready var empower : SkillUpgradeRect = $Panel/VBoxContainer/HBoxContainer2/Empower
@onready var mass_bleed : SkillUpgradeRect = $"Panel/VBoxContainer/HBoxContainer3/Mass Bleed"
@onready var mass_daze : SkillUpgradeRect = $"Panel/VBoxContainer/HBoxContainer3/Mass Daze"
@onready var dodge : SkillUpgradeRect = $Panel/VBoxContainer/HBoxContainer3/Dodge
@onready var heal : SkillUpgradeRect = $Panel/VBoxContainer/HBoxContainer3/Heal

@onready var empower_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar2
@onready var shield_up_progress : TextureProgressBar = $Panel/Connections/HBoxContainer/TextureProgressBar
@onready var mass_bleed_progress : TextureProgressBar = $Panel/Connections/HBoxContainer2/TextureProgressBar2
@onready var mass_daze_progress: TextureProgressBar = $Panel/Connections/HBoxContainer2/TextureProgressBar
@onready var dodge_progress : TextureProgressBar = $Panel/Connections/HBoxContainer2/TextureProgressBar3
@onready var heal_progress : TextureProgressBar = $Panel/Connections/HBoxContainer2/TextureProgressBar4
@onready var infoText : RichTextLabel = $Label

var gameOverScreen : PackedScene = preload("res://Scenes/screens/GameOverScreen.tscn")
const ACTION_INTERVAL: float = 0.006 # 200ms interval between actions
var time_since_last_action: float = 0.0
var held_ability : int = -1

@onready var abilities : Array[SkillUpgradeRect] = [enchant,empower,shield_up,mass_bleed,mass_daze,dodge,heal]
@onready var progresses : Array[TextureProgressBar] = [empower_progress,shield_up_progress,mass_bleed_progress,mass_daze_progress,dodge_progress,heal_progress]
func _ready() -> void:
	enchant.set_data(0,"Enchant",false,false)
	empower.set_data(1,"Empower",true,false)
	shield_up.set_data(2,"Shield Up",true,false)
	mass_bleed.set_data(3,"Mass Bleed",true,true)
	mass_daze.set_data(4,"Mass Daze",true,true)
	dodge.set_data(5,"Dodge",true,true)
	heal.set_data(6,"Heal",true,true)
	
	var empower_unlocked : bool = db.saveData.ability_progresses["Empower"] == empower.ability.soul_requirement
	var shield_up_unlocked : bool = db.saveData.ability_progresses["Shield Up"] == shield_up.ability.soul_requirement
	
	if empower_unlocked:
		mass_bleed.set_hidden(false)
		mass_daze.set_hidden(false)
	if shield_up_unlocked:
		dodge.set_hidden(false)
		heal.set_hidden(false)
	
	for i in range(progresses.size()):
		progresses[i].max_value = abilities[i+1].ability.soul_requirement
	for ability in abilities:
		ability.clicked.connect(_ability_clicked)
	set_texts()
	set_progress()
	

func _process(delta: float) -> void:
	time_since_last_action += delta
	if held_ability != -1 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and time_since_last_action >= ACTION_INTERVAL:
		if db.saveData.souls > 0 and db.saveData.ability_progresses[abilities[held_ability].ability._name] < abilities[held_ability].ability.soul_requirement:
			db.saveData.ability_progresses[abilities[held_ability].ability._name] += 1
			db.saveData.souls -= 1
			set_texts()
			set_progress()
			if db.saveData.ability_progresses[abilities[held_ability].ability._name] == abilities[held_ability].ability.soul_requirement:
				abilities[held_ability].set_disabled(false)
				match held_ability:
					1:
						abilities[3].set_hidden(false)
						abilities[4].set_hidden(false)
					2:
						abilities[5].set_hidden(false)
						abilities[6].set_hidden(false)
		time_since_last_action = 0.0  # Reset timer
	
func set_texts() -> void:
	infoText.text = "[center]You are dead.\nYou have collected [color=d68b45]"+str(db.saveData.souls)+"[/color] souls.\nUse them to unlock new powers."
	for ability : SkillUpgradeRect in abilities:
		var tooltip:String = db.get_ability(ability.ability._name).get_tooltip()
		if db.saveData.ability_progresses[ability.ability._name] != ability.ability.soul_requirement:
			tooltip += "\n\n[color=e39347]"+str(db.saveData.ability_progresses[ability.ability._name])+"/"+str(ability.ability.soul_requirement)+" souls for unlock[/color]"
		else:
			tooltip += "\n\n[color=e39347]Unlocked[/color]"
		ability.tooltip.set_data(tooltip)
	
	
func set_progress() -> void:
	for i in range(progresses.size()):
		progresses[i].value = db.saveData.ability_progresses[abilities[i+1].ability._name]
		if progresses[i].value == abilities[i+1].ability.soul_requirement:
			abilities[i+1].set_disabled(false)

func _ability_clicked(id:int) -> void:
	held_ability = id

func _on_button_pressed() -> void:
	db.saveData.save_game()
	get_tree().change_scene_to_packed(gameOverScreen)
