extends GutTest
const SAVE := "user://test_training.json"
var game: Node
func before_each() -> void:
	DirAccess.remove_absolute(SAVE)
	game = load("res://game/main.tscn").instantiate()
	game.save_path = SAVE
	add_child_autofree(game)
	var screen = game.get_node("Interface/CharacterScreen")
	screen.get_node("Create/Name").text = "Trainee"
	screen.get_node("Create/Races/fist").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
func after_each() -> void:
	DirAccess.remove_absolute(SAVE)
func choose_class() -> void:
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	game.get_node("Interface/ClassPicker/Classes/monk").pressed.emit()
	game.get_node("Interface/ClassPicker/Confirm").pressed.emit()
func test_training_requires_class_and_proximity() -> void:
	var screen = game.get_node_or_null("Interface/Training")
	assert_not_null(screen)
	if screen == null: return
	var temple = game.get_node("Temple")
	temple.get_node("Player").position = Vector2(202, 116)
	temple.try_interact()
	assert_false(screen.visible)
	choose_class()
	temple.get_node("Player").position = Vector2(160, 128)
	assert_false(temple.try_interact())
	temple.get_node("Player").position = Vector2(202, 116)
	assert_true(temple.try_interact())
	assert_true(screen.visible)
	assert_eq(game.encounter.state, &"ready")
func test_training_spends_live_resources_and_returns_to_same_position() -> void:
	var screen = game.get_node_or_null("Interface/Training")
	assert_not_null(screen)
	if screen == null: return
	choose_class()
	game.get_node("Temple/Player").position = Vector2(202, 116)
	game.get_node("Temple").try_interact()
	screen.get_node("Start").pressed.emit()
	screen.get_node("HeavyStrike").pressed.emit()
	assert_eq(game.session.stats.vigor, 920)
	assert_eq(game.encounter.state, &"active")
	assert_false(game.get_node("Temple").visible)
	screen.get_node("Leave").pressed.emit()
	assert_true(game.get_node("Temple").visible)
	assert_eq(game.get_node("Temple/Player").position, Vector2(202, 116))
	assert_eq(game.encounter.state, &"withdrawn")
func press_key(code: Key) -> void:
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

func test_keyboard_skills_summary_and_escape_do_not_pause_or_reset_combat() -> void:
	choose_class()
	game.get_node("Temple/Player").position = Vector2(202, 116)
	game.get_node("Temple").try_interact()
	await press_key(KEY_ENTER)
	await press_key(KEY_1)
	assert_eq(game.session.stats.vigor, 920)
	assert_gt(game.encounter.lag_remaining, 0.0)
	await press_key(KEY_2)
	assert_eq(game.session.stats.mana, 1000)
	await press_key(KEY_C)
	assert_true(game.get_node("Interface/CharacterSummary").visible)
	var before: float = game.encounter.until_round
	await wait_process_frames(4)
	assert_lt(game.encounter.until_round, before)
	assert_string_contains(game.get_node("Interface/CharacterSummary/Resources").text, "Vigor   920 / 1000")
	await press_key(KEY_ESCAPE)
	assert_false(game.get_node("Interface/CharacterSummary").visible)
	assert_true(game.get_node("Interface/Training").visible)
	await press_key(KEY_ESCAPE)
	assert_false(game.get_node("Interface/Training").visible)
	assert_true(game.get_node("Temple").visible)
	assert_eq(game.encounter.state, &"withdrawn")

func test_exploration_recovery_updates_hud_and_summary() -> void:
	game.session.stats.vigor = 0
	await press_key(KEY_C)
	await wait_process_frames(8)
	assert_gt(game.session.stats.vigor, 0)
	assert_string_contains(game.get_node("Interface/CharacterSummary/Resources").text, "Vigor")
	assert_string_contains(game.world_bars.get_node("Pool2/Value").text, "Vigor")
func test_training_layout_has_no_bar_or_log_overlap() -> void:
	choose_class()
	game.get_node("Temple/Player").position = Vector2(202, 116)
	game.get_node("Temple").try_interact()
	var screen = game.get_node("Interface/Training")
	await wait_process_frames(2)
	assert_lte(screen.get_node("EnemyBar").get_global_rect().end.y, screen.get_node("Timing").global_position.y)
	screen.get_node("Start").pressed.emit()
	game.encounter.advance(3.0)
	screen.refresh()
	await wait_process_frames(2)
	assert_lte(screen.get_node("Log").get_global_rect().end.y, screen.get_node("HeavyStrike").global_position.y)
	assert_lte(screen.get_node("Footer").get_global_rect().end.y, 360.0)