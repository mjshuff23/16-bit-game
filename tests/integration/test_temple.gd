extends GutTest

const STORE_PATH := "user://test_temple_characters.json"
var game: Node
var world: Node2D

func before_each() -> void:
	game = load("res://game/main.tscn").instantiate()
	DirAccess.remove_absolute(STORE_PATH)
	game.save_path = STORE_PATH
	add_child_autofree(game)
	var screen = game.get_node("Interface/CharacterScreen")
	screen.get_node("Create/Name").text = "Traveler"
	screen.get_node("Create/Races/saiyan").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	world = game.get_node_or_null("Temple")
	assert_not_null(world, "The opening needs a temple scene")

func after_each() -> void:
	DirAccess.remove_absolute(STORE_PATH)
	for action in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		if InputMap.has_action(action):
			Input.action_release(action)

func enter_temple() -> void:
	# The setup creates an identity before entering the world.
	pass

func choose_at_altar() -> void:
	world.get_node("Player").position = Vector2(160, 62)
	world.try_interact()
	var picker = game.get_node("Interface/ClassPicker")
	picker.get_node("Classes/wizard").pressed.emit()
	picker.get_node("Confirm").pressed.emit()

func test_spawn_is_unclassed_and_can_explore() -> void:
	assert_true(world.visible)
	assert_false(game.get_node("Interface/ClassPicker").visible)
	assert_eq(world.selected_class, &"")
	Input.action_press(&"move_right")
	await wait_physics_frames(4)
	assert_gt(world.get_node("Player").position.x, 160.0)

func test_altar_choice_completes_first_quest_without_respawning() -> void:
	assert_false(world.try_interact(), "Cannot choose a class from the forest spawn")
	choose_at_altar()
	assert_eq(world.selected_class, &"wizard")
	assert_eq(world.get_node("Player").position, Vector2(160, 62))
	assert_false(game.get_node("Interface/ClassPicker").visible)
	assert_string_contains(world.get_node("HUD/Objective").text, "complete")

func test_cancel_choice_preserves_session_and_position() -> void:
	world.get_node("Player").position = Vector2(160, 62)
	world.try_interact()
	var picker = game.get_node("Interface/ClassPicker")
	assert_true(picker.visible)
	picker.get_node("Classes/wizard").pressed.emit()
	Input.action_press(&"move_down")
	await wait_physics_frames(4)
	assert_eq(world.get_node("Player").position, Vector2(160, 62))
	picker.selection_cancelled.emit()
	assert_eq(world.selected_class, &"")
	assert_false(picker.visible)
	assert_eq(picker.session.pending_class_id, &"")

func test_tree_and_map_edge_block_movement() -> void:
	if world == null: return
	enter_temple()
	var player = world.get_node("Player")
	player.position = Vector2(88, 154)
	Input.action_press(&"move_up")
	await wait_physics_frames(35)
	assert_gte(player.position.y, 139.0, "Tree base must be solid")
	Input.action_release(&"move_up")
	player.position = Vector2(160, 150)
	Input.action_press(&"move_down")
	await wait_physics_frames(25)
	assert_lte(player.position.y, 157.0, "Player must stay inside the map")

func press_and_release(action: StringName) -> void:
	# Input dispatch follows process frames, not physics ticks. A slow rendered
	# frame can contain several physics ticks; always release each distinct event.
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	await wait_process_frames(2)
	var release := InputEventAction.new()
	release.action = action
	Input.parse_input_event(release)
	await wait_process_frames(2)

func test_escape_closes_inspection_without_reclassing() -> void:
	if world == null: return
	choose_at_altar()
	world.get_node("Player").position = Vector2(160, 62)
	await press_and_release(&"interact")
	assert_true(world.inspection_open)
	await press_and_release(&"ui_cancel")
	assert_false(world.inspection_open)
	assert_true(world.visible)
	# A second Escape returns to the character list without erasing the class.
	await press_and_release(&"ui_cancel")
	assert_false(world.visible)
	assert_true(game.get_node("Interface/CharacterScreen").visible)
	assert_false(game.get_node("Interface/ClassPicker").visible)
	assert_eq(world.selected_class, &"wizard")

func test_cardinal_motion_and_wall_collision() -> void:
	if world == null: return
	enter_temple()
	var player = world.get_node("Player")
	var origin: Vector2 = player.position
	Input.action_press(&"move_right")
	await wait_physics_frames(8)
	assert_gt(player.position.x, origin.x)
	assert_almost_eq(player.position.y, origin.y, 0.01)
	Input.action_release(&"move_right")
	player.position = Vector2(160, 65)
	Input.action_press(&"move_left")
	await wait_physics_frames(70)
	assert_gte(player.position.x, 115.0, "Temple wall must block movement")

func test_diagonal_input_is_resolved_to_one_axis() -> void:
	if world == null: return
	enter_temple()
	var player = world.get_node("Player")
	var origin: Vector2 = player.position
	Input.action_press(&"move_right")
	Input.action_press(&"move_up")
	await wait_physics_frames(8)
	var offset: Vector2 = player.position - origin
	assert_true(absf(offset.x) < 0.01 or absf(offset.y) < 0.01)
	assert_gt(offset.length(), 0.0)

func test_altar_requires_proximity_and_stops_motion_while_reading() -> void:
	if world == null: return
	choose_at_altar()
	world.get_node("Player").position = Vector2(160, 128)
	assert_false(world.try_interact(), "Spawn is too far from the altar")
	var player = world.get_node("Player")
	player.position = Vector2(160, 62)
	assert_true(world.try_interact())
	assert_true(world.inspection_open)
	Input.action_press(&"move_down")
	await wait_physics_frames(8)
	assert_eq(player.position, Vector2(160, 62))
	var panel: Panel = world.get_node("HUD/Inspection")
	var text: Label = panel.get_node("Text")
	assert_lte(text.get_global_rect().end.y, panel.get_global_rect().end.y,
		"Inspection text must fit above the controls")
	world.close_inspection()
	assert_false(world.inspection_open)
	await wait_physics_frames(8)
	assert_gt(player.position.y, 62.0)

