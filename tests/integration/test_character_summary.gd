extends GutTest
const SAVE_PATH := "user://test_summary_profiles.json"
var game: Node

func before_each() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	game = load("res://game/main.tscn").instantiate()
	game.save_path = SAVE_PATH
	add_child_autofree(game)

func after_each() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	Input.action_release(&"move_right")

func enter_world() -> void:
	var creation = game.get_node("Interface/CharacterScreen")
	creation.get_node("Create/Name").text = "Cereal"
	creation.get_node("Create/Races/mazoku").pressed.emit()
	creation.get_node("Create/Begin").pressed.emit()

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await wait_process_frames(2)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	Input.parse_input_event(event)
	await wait_process_frames(2)

func test_c_opens_summary_allows_movement_and_escape_returns_to_world() -> void:
	enter_world()
	await key(KEY_C)
	var summary = game.get_node_or_null("Interface/CharacterSummary")
	assert_not_null(summary)
	if summary == null: return
	assert_true(summary.visible)
	assert_string_contains(summary.get_node("Name").text, "Cereal")
	assert_string_contains(summary.get_node("Identity").text, "Mazoku")
	assert_string_contains(summary.get_node("Identity").text, "Unclassed")
	assert_string_contains(summary.get_node("Attributes").text, "10 / 95")
	assert_string_contains(summary.get_node("Resources").text, "2000 / 2000")
	assert_string_contains(summary.get_node("Quest").text, "Choose a class")
	var player = game.get_node("Temple/Player")
	var origin: Vector2 = player.position
	Input.action_press(&"move_right")
	await wait_physics_frames(8)
	assert_gt(player.position.x, origin.x)
	await key(KEY_ESCAPE)
	assert_false(summary.visible)
	assert_false(game.get_node("Interface/CharacterScreen").visible)
	await wait_physics_frames(8)
	assert_gt(player.position.x, origin.x)

func test_summary_refreshes_after_class_choice_and_closes_with_c() -> void:
	enter_world()
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	game.get_node("Interface/ClassPicker/Classes/warlock").pressed.emit()
	game.get_node("Interface/ClassPicker/Confirm").pressed.emit()
	game.session.stats.mana = 321
	await key(KEY_C)
	var summary = game.get_node_or_null("Interface/CharacterSummary")
	assert_not_null(summary)
	if summary == null: return
	assert_string_contains(summary.get_node("Identity").text, "Warlock")
	assert_string_contains(summary.get_node("Resources").text, "%d / 1000" % game.session.stats.mana)
	assert_string_contains(summary.get_node("Quest").text, "Complete")
	await key(KEY_C)
	assert_false(summary.visible)
	assert_eq(game.session.class_id, &"warlock")

func test_hotkey_does_not_open_over_creation_or_class_picker() -> void:
	await key(KEY_C)
	var summary = game.get_node_or_null("Interface/CharacterSummary")
	assert_not_null(summary)
	if summary == null: return
	assert_false(summary.visible)
	enter_world()
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	await key(KEY_C)
	assert_false(summary.visible)
	assert_true(game.get_node("Interface/ClassPicker").visible)

func test_summary_does_not_replace_open_inspection() -> void:
	enter_world()
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	game.get_node("Interface/ClassPicker/Classes/monk").pressed.emit()
	game.get_node("Interface/ClassPicker/Confirm").pressed.emit()
	game.get_node("Temple").try_interact()
	await key(KEY_C)
	var summary = game.get_node_or_null("Interface/CharacterSummary")
	assert_not_null(summary)
	if summary == null: return
	assert_false(summary.visible)
	assert_true(game.get_node("Temple").inspection_open)
func test_arrow_keys_move_with_summary_open() -> void:
	enter_world()
	await key(KEY_C)
	var player = game.get_node("Temple/Player")
	var origin: Vector2 = player.position
	await key(KEY_RIGHT)
	assert_gt(player.position.x, origin.x)
	assert_true(game.get_node("Interface/CharacterSummary").visible)
func test_panel_is_above_hud_and_interaction_closes_it() -> void:
	enter_world()
	await key(KEY_C)
	assert_gt(game.get_node("Interface").layer, game.get_node("Temple/HUD").layer)
	game.get_node("Temple/Player").position = Vector2(160, 62)
	await key(KEY_E)
	assert_false(game.get_node("Interface/CharacterSummary").visible)
	assert_true(game.get_node("Interface/ClassPicker").visible)