class_name ResourceBars
extends Control
## Shared presentation for exploration and training; numbers supplement color.
const COLORS := [Color("a4494b"), Color("426fa9"), Color("9c8143")]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index in 3:
		var background := ColorRect.new()
		background.name = "Pool%d" % index
		background.position = Vector2(index * 204, 0)
		background.size = Vector2(196, 22)
		background.color = Color("14201c")
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(background)
		var fill := ColorRect.new()
		fill.name = "Fill"
		fill.size = Vector2(196, 22)
		fill.color = COLORS[index]
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.add_child(fill)
		var label := Label.new()
		label.name = "Value"
		label.size = Vector2(196, 22)
		label.add_theme_font_size_override("font_size", 12)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.add_child(label)

func update_values(stats: CharacterStats) -> void:
	var names := ["Health", "Mana", "Vigor"]
	var current := [stats.health, stats.mana, stats.vigor]
	var maximum := [stats.max_health, stats.max_mana, stats.max_vigor]
	for index in 3:
		get_node("Pool%d/Fill" % index).size.x = 196.0 * clampf(float(current[index]) / maxf(1.0, maximum[index]), 0.0, 1.0)
		get_node("Pool%d/Value" % index).text = "%s %d / %d" % [names[index], current[index], maximum[index]]