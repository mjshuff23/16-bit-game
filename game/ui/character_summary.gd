extends Control
## A non-modal, read-only view of the current character. Never takes key focus.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := Panel.new()
	panel.position = Vector2(350, 0)
	panel.size = Vector2(290, 360)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101d19")
	style.border_color = Color("829879")
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	_label("Title", Rect2(362, 20, 254, 22), 14)
	$Title.text = "CHARACTER          C / Esc: close"
	_label("Name", Rect2(362, 45, 254, 38), 16)
	_label("Identity", Rect2(362, 85, 254, 38), 14)
	_label("Attributes", Rect2(362, 129, 254, 58), 14)
	_label("Resources", Rect2(362, 191, 254, 58), 14)
	_label("Modifiers", Rect2(362, 253, 254, 38), 13)
	_label("Quest", Rect2(362, 297, 254, 42), 12)

func show_character(character: CharacterSession) -> void:
	var stats := character.stats
	$Name.text = character.character_name
	var class_name_text := ClassCatalog.display_name(character.class_id) if character.class_id != &"" else "Unclassed"
	$Identity.text = "Race: %s\nClass: %s" % [RaceCatalog.display_name(character.race_id), class_name_text]
	$Attributes.text = "BASE ATTRIBUTES / RACIAL CAPS\nBody %d / %d    Int %d / %d\nWill %d / %d    Spirit %d / %d" % [
		stats.body, character.attribute_cap(&"body"), stats.mind, character.attribute_cap(&"mind"),
		stats.willpower, character.attribute_cap(&"willpower"), stats.spirit, character.attribute_cap(&"spirit")]
	$Resources.text = "Health  %d / %d\nMana    %d / %d\nVigor   %d / %d" % [stats.health, stats.max_health, stats.mana, stats.max_mana, stats.vigor, stats.max_vigor]
	$Modifiers.text = "Hitroll %d   Damroll %d\nArmor %d   Primal %d" % [stats.hitroll, stats.damroll, stats.armor, stats.primal]
	var quest := "Choose a class at the altar" if character.class_id == &"" else "Complete - class chosen"
	$Quest.text = "Forest Temple\nFirst quest: %s" % quest
	show()

func _label(node_name: String, rect: Rect2, font_size: int) -> void:
	var label := Label.new()
	label.name = node_name
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)