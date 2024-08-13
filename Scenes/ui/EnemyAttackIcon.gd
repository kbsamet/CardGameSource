extends Control

@onready var sprite = $Node2D/Sprite
@onready var amountLabel = $Node2D/AmountLabel
@onready var tooltip = $Tooltip as TooltipNode
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_data(attack: EnemySingleAttackData,empowered : bool):
	sprite.texture = load("res://Sprites/ui/enemyAttacks/"+get_attack_name(attack.attack_type)+".png")
	amountLabel.text = str(attack.amount)
	var tooltip_text_ = db.enemy_tooltips[attack.attack_type]
	tooltip_text_ = tooltip_text_.replace("_", str(attack.amount))
	tooltip.set_data(tooltip_text_)
	if attack.attack_type == db.EnemyAttack.Damage and empowered:
		amountLabel.label_settings = amountLabel.label_settings.duplicate()
		amountLabel.label_settings.font_color = Color("557d55")
		
func get_attack_name(attack : db.EnemyAttack) -> String:
	match  attack:
		db.EnemyAttack.Bleed:
			return "bleed"
		db.EnemyAttack.Damage:
			return "damage"
		db.EnemyAttack.ArmorUp:
			return "armorUp"
		db.EnemyAttack.Blind:
			return "blind"
		db.EnemyAttack.Burn:
			return "burn"
		db.EnemyAttack.Daze:
			return "daze"
		db.EnemyAttack.Empower:
			return "empower"
		db.EnemyAttack.Unstoppable:
			return "unstoppable"
		db.EnemyAttack.HealAll:
			return "healAll"
		db.EnemyAttack.StaminaCost:
			return "staminaCost"
		db.EnemyAttack.Lifesteal:
			return "lifesteal"
		db.EnemyAttack.DrainAp:
			return "drainAp"
		db.EnemyAttack.DrainRp:
			return "drainRp"
		db.EnemyAttack.Unblockable:
			return "unblockable"
		db.EnemyAttack.GainStamina:
			return "staminaGain"
	assert(false, "Attack name not found!")
	return ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	tooltip.visible = true


func _on_mouse_exited():
	tooltip.visible = false
