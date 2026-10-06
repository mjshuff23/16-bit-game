extends GutTest
func test_touch_overlay_releases_input_when_hidden() -> void:
	var script = load("res://game/ui/mobile_controls.gd")
	assert_not_null(script)
	if script == null: return
	var controls = script.new()
	add_child_autofree(controls)
	controls.enabled = true
	controls.update_context(true, false, false)
	assert_true(controls.get_node("Left").visible)
	Input.action_press("move_left")
	controls.update_context(false, true, false)
	assert_false(Input.is_action_pressed("move_left"))
	assert_false(controls.get_node("Left").visible)
	assert_true(controls.get_node("Character").visible)
	controls.update_context(false, false, false)
	assert_false(controls.get_node("Character").visible)

func test_background_pause_and_resume_skip_simulation_frame() -> void:
	var script = load("res://game/web_lifecycle.gd")
	assert_not_null(script)
	if script == null: return
	var lifecycle = script.new()
	add_child_autofree(lifecycle)
	lifecycle.set_suspended(true)
	assert_true(get_tree().paused)
	lifecycle.set_suspended(false)
	assert_false(get_tree().paused)
	assert_true(lifecycle.skip_frame)

func test_summary_keeps_movement_and_moves_controls_off_character_details() -> void:
	var controls := MobileControls.new()
	add_child_autofree(controls)
	controls.enabled = true
	controls.call("update_context", true, false, false, true)
	assert_true(controls.get_node("Left").visible)
	assert_false(controls.get_node("Interact").visible)
	assert_lt(controls.get_node("Back").position.x, 328.0)
	assert_lt(controls.get_node("Character").position.x, 328.0)

func test_two_fingers_release_independently_and_menu_clears_held_direction() -> void:
	var controls := MobileControls.new()
	add_child_autofree(controls)
	controls.enabled = true
	controls.update_context(true, false, false)
	var left := InputEventScreenTouch.new()
	left.index = 0
	left.position = controls.get_node("Left").global_position
	left.pressed = true
	get_viewport().push_input(left, true)
	var up := InputEventScreenTouch.new()
	up.index = 1
	up.position = controls.get_node("Up").global_position
	up.pressed = true
	get_viewport().push_input(up, true)
	assert_true(Input.is_action_pressed("move_left"))
	assert_true(Input.is_action_pressed("move_up"))
	left.pressed = false
	get_viewport().push_input(left, true)
	assert_false(Input.is_action_pressed("move_left"))
	assert_true(Input.is_action_pressed("move_up"))
	controls.update_context(false, false, false)
	assert_false(Input.is_action_pressed("move_up"))
	up.pressed = false
	get_viewport().push_input(up, true)

func test_cancel_resets_button_contact_so_next_touch_can_press_again() -> void:
	var controls := MobileControls.new()
	add_child_autofree(controls)
	controls.enabled = true
	controls.update_context(true, false, false)
	var touch := InputEventScreenTouch.new()
	touch.position = controls.get_node("Left").global_position
	touch.pressed = true
	get_viewport().push_input(touch, true)
	assert_true(controls.get_node("Left").is_pressed())
	controls.release_actions()
	assert_false(controls.get_node("Left").is_pressed())
	get_viewport().push_input(touch, true)
	assert_true(Input.is_action_pressed("move_left"))
	touch.pressed = false
	get_viewport().push_input(touch, true)
