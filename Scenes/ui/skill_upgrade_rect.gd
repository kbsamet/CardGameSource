extends TextureRect
class_name SkillUpgradeRect

@onready var tooltip : TooltipNode = $Tooltip
@onready var gray_tint : ShaderMaterial = preload("res://Shaders/gray_tint.tres")
signal clicked(id:int)
signal selected(id:int)
var ability : AbilityData
var id : int
var is_disabled : bool
var is_hidden : bool
func set_data(id:int,ability_name: String,disabled : bool,hidden:bool) -> void:
	self.id = id
	is_disabled = disabled
	is_hidden = hidden
	ability = db.get_ability(ability_name)
	if hidden:
		texture = load("res://Sprites/ui/HiddenAbility.png")
	else:
		texture = load("res://Sprites/abilities/"+ability_name+".png")
	if disabled:
		material = gray_tint
	tooltip.set_data(ability.get_tooltip())
	if hidden:
		mouse_filter = MOUSE_FILTER_IGNORE
		mouse_default_cursor_shape = CURSOR_ARROW
	else:
		mouse_filter = MOUSE_FILTER_PASS
		mouse_default_cursor_shape = CURSOR_POINTING_HAND

func set_disabled(disabled : bool) -> void:
	is_disabled = disabled
	if disabled:
		material = gray_tint
	else:
		material = null

func set_hidden(hidden : bool) -> void:
	is_hidden = hidden
	if hidden:
		texture = load("res://Sprites/ui/HiddenAbility.png")
	else:
		texture = load("res://Sprites/abilities/"+ability._name+".png")
	if hidden:
		mouse_filter = MOUSE_FILTER_IGNORE
		mouse_default_cursor_shape = CURSOR_ARROW
	else:
		mouse_filter = MOUSE_FILTER_PASS
		mouse_default_cursor_shape = CURSOR_POINTING_HAND

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			selected.emit(id)
		if event.is_pressed():
			clicked.emit(id)
		else:
			clicked.emit(-1)
