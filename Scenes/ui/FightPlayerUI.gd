extends Control

@onready var healthBarRect = $HealthBar/HealthBarRect
@onready var healthBarLabel = $HealthBar/HealthLabel
@onready var apLabel = $ApBar/ApBarOutline/ApLabel
@onready var rpLabel = $RpBar/RpBarOutline/RpLabel
@onready var apBar = $ApBar
@onready var rpBar = $RpBar
signal end_turn_clicked

var health_bar_full_width
# Called when the node enters the scene tree for the first time.
func _ready():
	db.player_state_changed.connect(update_ui_values)
	update_ui_values()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_ui_values():
	health_bar_full_width = healthBarRect.size.x
	healthBarRect.size.x = (float(db.Player.health) / float(db.Player.maxHealth)) * health_bar_full_width
	apLabel.text = str(db.Player.ap) + " / " + str(db.Player.maxAp)
	rpLabel.text = str(db.Player.rp) + " / " + str(db.Player.maxRp)
	healthBarLabel.text =  str(db.Player.health) + " / " + str(db.Player.maxHealth)
	apBar.material.set_shader_parameter("cutoff",float(db.Player.ap) / float(db.Player.maxAp))
	rpBar.material.set_shader_parameter("cutoff",float(db.Player.rp) / float(db.Player.maxRp))

func _on_button_input(event):
	if event is InputEventMouseButton:
		if event.is_released():
			end_turn_clicked.emit()
