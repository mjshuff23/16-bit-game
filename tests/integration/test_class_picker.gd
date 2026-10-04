extends GutTest

var picker: Control

func test_grid_does_not_overlap_description() -> void:
	await wait_physics_frames(2)
	var grid: GridContainer = picker.get_node("Classes")
	var description: Label = picker.get_node("Description")
	assert_lte(grid.get_global_rect().end.y, description.global_position.y)

func test_keyboard_can_select_focused_class() -> void:
	await wait_physics_frames(2)
	var button: Button = picker.get_node("Classes/barbarian")
	button.grab_focus()
	var press := InputEventAction.new()
	press.action = &"ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	await wait_physics_frames(1)
	var release := InputEventAction.new()
	release.action = &"ui_accept"
	Input.parse_input_event(release)
	await wait_physics_frames(1)
	assert_eq(picker.session.pending_class_id, &"barbarian")
	assert_false(picker.get_node("Confirm").disabled)

func before_each() -> void:
	picker = load("res://game/ui/class_picker.tscn").instantiate()
	add_child_autofree(picker)

func test_all_classes_have_focusable_buttons_and_no_default_selection() -> void:
	var grid := picker.get_node_or_null("Classes")
	assert_not_null(grid, "Class grid must be present")
	if grid == null: return
	assert_eq(grid.get_child_count(), ClassCatalog.CLASSES.size())
	var names: Array[String] = []
	for button in grid.get_children():
		names.append(button.text)
		assert_eq(button.focus_mode, Control.FOCUS_ALL)
	assert_has(names, "Warlock")
	assert_has(names, "Wizard")
	assert_true(picker.get_node("Confirm").disabled)

func test_preview_and_confirm_do_not_offer_reclassing() -> void:
	var grid := picker.get_node_or_null("Classes")
	assert_not_null(grid)
	if grid == null: return
	var wizard: Button = grid.get_node("wizard")
	wizard.pressed.emit()
	var confirm: Button = picker.get_node("Confirm")
	assert_false(confirm.disabled)
	assert_string_contains(picker.get_node("Description").text, "Wizard")
	confirm.pressed.emit()
	assert_eq(picker.session.class_id, &"wizard")
	assert_true(wizard.disabled)
	assert_string_contains(picker.get_node("Description").text, "chosen")
	assert_true(confirm.disabled)
	confirm.pressed.emit()
	assert_eq(picker.session.class_id, &"wizard")
	assert_true(confirm.disabled)
	assert_true(wizard.disabled)
