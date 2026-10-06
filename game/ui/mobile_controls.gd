class_name MobileControls
extends Node2D
var enabled := false
var _context := ""
const ACTIONS := ["move_left", "move_right", "move_up", "move_down", "interact", "character_summary", "ui_cancel"]
func _ready() -> void:
	enabled = DisplayServer.is_touchscreen_available() or OS.has_feature("web")
	_button("Left", "<", "move_left", Vector2(26, 272))
	_button("Right", ">", "move_right", Vector2(118, 272))
	_button("Up", "^", "move_up", Vector2(72, 226))
	_button("Down", "v", "move_down", Vector2(72, 318))
	_button("Interact", "Use", "interact", Vector2(602, 272))
	_button("Character", "Char", "character_summary", Vector2(550, 188))
	_button("Back", "Back", "ui_cancel", Vector2(602, 188))
	update_context(false, false, false)

func _button(id: String, caption: String, action: String, at: Vector2) -> void:
	var button := TouchScreenButton.new()
	button.name = id
	button.position = at
	button.action = action
	var shape := RectangleShape2D.new()
	shape.size = Vector2(44, 44)
	button.shape = shape
	button.shape_visible = false
	button.passby_press = false
	add_child(button)
	var background := Polygon2D.new()
	background.polygon = PackedVector2Array([Vector2(-22,-22), Vector2(22,-22), Vector2(22,22), Vector2(-22,22)])
	background.color = Color(0.08, 0.15, 0.13, 0.85)
	button.add_child(background)
	var label := Label.new()
	label.text = caption
	label.position = Vector2(-22,-22)
	label.size = Vector2(44,44)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)

func update_context(world: bool, battle: bool, inspecting: bool, summary_open: bool = false) -> void:
	var context := "%s/%s/%s/%s/%s" % [enabled, world, battle, inspecting, summary_open]
	if context == _context:
		return
	_context = context
	if enabled:
		release_actions()
	for id in ["Left", "Right", "Up", "Down"]:
		get_node(id).visible = enabled and world and not inspecting
	$Interact.visible = enabled and world and not inspecting and not summary_open
	$Character.visible = enabled and (world or battle) and not inspecting
	$Back.visible = enabled and (world or battle)
	$Character.position.x = 244 if summary_open else 550
	$Back.position.x = 296 if summary_open else 602

func release_actions() -> void:
	# Hiding clears TouchScreenButton's finger contact as well as Input state.
	for child in get_children():
		if child is TouchScreenButton and child.visible:
			child.hide()
			child.show()
	for action in ACTIONS:
		Input.action_release(action)
