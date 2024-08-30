extends Control
class_name AttackIcon
@onready var sprite : Sprite2D = $Node2D/Sprite
@onready var amountLabel : Label = $Node2D/AmountLabel
@onready var tooltip : TooltipNode = $Tooltip 

func set_data(attack: EnemySingleAttackData,empowered : int) -> void:
	sprite.texture = load("res://Sprites/ui/enemyAttacks/"+get_attack_name(attack.attack_type)+".png")
	var attack_amount :int = attack.amount
	if empowered != -1:
		attack_amount += empowered
	amountLabel.text = str(attack_amount)
	var tooltip_text_ : String = db.enemy_tooltips[attack.attack_type]
	if attack.attack_type == db.EnemyAttack.Damage and empowered != -1:
		amountLabel.label_settings = amountLabel.label_settings.duplicate()
		amountLabel.label_settings.font_color = Color("557d55")
	tooltip_text_ = tooltip_text_.replace("_", str(attack_amount))
	tooltip.set_data(tooltip_text_)
		
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
		db.EnemyAttack.Cripple:
			return "cripple"
	assert(false, "Attack name not found!")
	return ""


func _on_mouse_entered() -> void:
	tooltip.visible = true


func _on_mouse_exited() -> void:
	tooltip.visible = false
