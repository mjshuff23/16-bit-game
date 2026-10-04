extends GutTest

const STORE_PATH := "user://test_character_screen.json"
var game: Node

func before_each() -> void:
	DirAccess.remove_absolute(STORE_PATH)
	game = load("res://game/main.tscn").instantiate()
	game.set("save_path", STORE_PATH)
	add_child_autofree(game)

func after_each() -> void:
	DirAccess.remove_absolute(STORE_PATH)
	DirAccess.remove_absolute(STORE_PATH + ".tmp")
	Input.action_release(&"move_up")

func test_creation_gates_world_then_altar_preserves_identity() -> void:
	var screen = game.get_node_or_null("Interface/CharacterScreen")
	assert_not_null(screen)
	if screen == null: return
	assert_false(game.get_node("Temple").visible)
	assert_true(screen.visible)
	Input.action_press(&"move_up")
	await wait_physics_frames(4)
	assert_eq(game.get_node("Temple/Player").position, Vector2(160, 128))
	Input.action_release(&"move_up")
	screen.get_node("Create/Name").text = "Kairo"
	screen.get_node("Create/Races/saiyan").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	assert_true(game.get_node("Temple").visible)
	assert_false(screen.visible)
	assert_eq(game.session.race_id, &"saiyan")
	assert_eq(game.session.class_id, &"")
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	game.get_node("Interface/ClassPicker/Classes/monk").pressed.emit()
	game.get_node("Interface/ClassPicker/Confirm").pressed.emit()
	assert_eq(game.session.class_id, &"monk")
	assert_eq(game.session.character_name, "Kairo")
	game.return_to_characters()
	assert_true(screen.visible)
	assert_string_contains(screen.get_node("Select/Summary").text, "Monk")
	screen.get_node("Select/Continue").pressed.emit()
	assert_eq(game.session.class_id, &"monk")
	assert_eq(game.session.race_id, &"saiyan")
	assert_eq(game.get_node("Temple/Player").position, Vector2(160, 128))

func test_creation_requires_name_and_explicit_race() -> void:
	var screen = game.get_node_or_null("Interface/CharacterScreen")
	assert_not_null(screen)
	if screen == null: return
	assert_true(screen.get_node("Create/Begin").disabled)
	screen.get_node("Create/Name").text = "Kairo"
	screen.get_node("Create/Name").text_changed.emit("Kairo")
	assert_true(screen.get_node("Create/Begin").disabled)
	screen.get_node("Create/Races/patryn").pressed.emit()
	assert_false(screen.get_node("Create/Begin").disabled)
	assert_string_contains(screen.get_node("Create/Details").text, "100")
func test_failed_class_save_keeps_quest_unfinished_and_allows_retry() -> void:
	var screen = game.get_node("Interface/CharacterScreen")
	screen.get_node("Create/Name").text = "Rune"
	screen.get_node("Create/Races/patryn").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	game.store.path = "user://missing_profile_directory/characters.json"
	var picker = game.get_node("Interface/ClassPicker")
	picker.get_node("Classes/monk").pressed.emit()
	picker.get_node("Confirm").pressed.emit()
	assert_eq(game.session.class_id, &"")
	assert_true(picker.visible)
	assert_false(picker.get_node("Classes/monk").disabled)
	assert_string_contains(picker.get_node("Description").text, "Cannot save")
	game.store.path = STORE_PATH
	picker.get_node("Classes/monk").pressed.emit()
	picker.get_node("Confirm").pressed.emit()
	assert_eq(game.session.class_id, &"monk")
	assert_false(picker.visible)

func test_new_character_keeps_existing_profile_and_can_cancel_creation() -> void:
	var screen = game.get_node("Interface/CharacterScreen")
	screen.get_node("Create/Name").text = "First"
	screen.get_node("Create/Races/saiyan").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	game.return_to_characters()
	screen.get_node("Select/New").pressed.emit()
	screen.get_node("Create/Back").pressed.emit()
	assert_true(screen.get_node("Select").visible)
	assert_eq(game.store.profiles.size(), 1)
	screen.get_node("Select/New").pressed.emit()
	screen.get_node("Create/Name").text = "Second"
	screen.get_node("Create/Races/mazoku").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	assert_eq(game.store.profiles.size(), 2)
	assert_eq(game.session.character_name, "Second")
	assert_eq(game.session.class_id, &"")
	game.return_to_characters()
	screen.get_node("Select/Characters").select(0)
	screen.get_node("Select/Continue").pressed.emit()
	assert_eq(game.session.character_name, "First")
	assert_eq(game.session.race_id, &"saiyan")
func test_five_races_fit_creation_screen_without_overlapping_details() -> void:
	var screen = game.get_node("Interface/CharacterScreen")
	var races = screen.get_node("Create/Races")
	assert_eq(races.get_child_count(), 5)
	await wait_physics_frames(2)
	var details: Label = screen.get_node("Create/Details")
	assert_lte(races.get_global_rect().end.y, details.global_position.y)
	assert_lte(details.get_global_rect().end.y, screen.get_node("Create/Begin").global_position.y)
	for button: Button in races.get_children():
		assert_lte(button.get_global_rect().end.x, 640.0)
		assert_lte(button.get_global_rect().end.y, details.global_position.y)
func test_every_race_description_fits_above_create_button() -> void:
	var screen = game.get_node("Interface/CharacterScreen")
	for button: Button in screen.get_node("Create/Races").get_children():
		button.pressed.emit()
		await wait_physics_frames(2)
		var details: Label = screen.get_node("Create/Details")
		assert_lte(details.get_global_rect().end.y, screen.get_node("Create/Begin").global_position.y,
			"Selected race description must not overlap the create button")
func test_640_viewport_and_readable_interface() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)
	var screen = game.get_node("Interface/CharacterScreen")
	assert_gte(screen.get_node("Create/Name").get_theme_font_size("font_size"), 18)
	assert_gte(screen.get_node("Title").get_theme_font_size("font_size"), 28)
	var temple = game.get_node("Temple")
	assert_eq(temple.get_node("Camera").zoom, Vector2(2, 2), "Frame the existing world without rescaling physics")
	assert_eq(temple.get_node("HUD").get_final_transform().get_scale(), Vector2.ONE, "HUD should render at its own font resolution")
	assert_eq(temple.get_node("HUD/Footer").get_global_rect().end, Vector2(640, 360))
func test_hud_is_hidden_in_menus_and_long_identity_does_not_cover_class() -> void:
	var screen = game.get_node("Interface/CharacterScreen")
	var hud = game.get_node("Temple/HUD")
	assert_false(hud.visible)
	screen.get_node("Create/Name").text = "WWWWWWWWWWWWWWWWWW"
	screen.get_node("Create/Races/witch_warlock").pressed.emit()
	screen.get_node("Create/Begin").pressed.emit()
	assert_true(hud.visible)
	var identity: Label = hud.get_node("Header/Location")
	assert_true(identity.clip_text, "Long identities must not cover the class label")
	assert_lte(identity.get_global_rect().end.x, hud.get_node("Header/Class").global_position.x)
	game.get_node("Temple/Player").position = Vector2(160, 62)
	game.get_node("Temple").try_interact()
	assert_false(hud.visible)
	game.get_node("Interface/ClassPicker").selection_cancelled.emit()
	assert_true(hud.visible)
	game.return_to_characters()
	assert_false(hud.visible)