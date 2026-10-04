extends GutTest

const STORE_PATH := "user://test_character_profiles.json"
var store: RefCounted

func before_each() -> void:
	DirAccess.remove_absolute(STORE_PATH)
	var script = load("res://game/character/character_store.gd")
	assert_not_null(script, "Named characters need a persistent store")
	if script != null:
		store = script.new(STORE_PATH)

func after_each() -> void:
	DirAccess.remove_absolute(STORE_PATH)
	DirAccess.remove_absolute(STORE_PATH + ".tmp")

func test_create_reload_and_class_update_keep_characters_separate() -> void:
	if store == null: return
	assert_true(store.load_profiles())
	var first = CharacterSession.new()
	assert_true(first.create_identity("  Kairo  ", &"saiyan"))
	assert_true(store.save_profile(first))
	var second = CharacterSession.new()
	assert_true(second.create_identity("Rune", &"patryn"))
	assert_true(store.save_profile(second))
	first.preview_class(&"monk")
	assert_true(first.confirm_class())
	assert_true(store.save_profile(first))
	assert_true(store.load_profiles())
	assert_eq(store.profiles.size(), 2)
	var restored = store.restore(first.character_id)
	assert_eq(restored.character_name, "Kairo")
	assert_eq(restored.race_id, &"saiyan")
	assert_eq(restored.class_id, &"monk")
	assert_eq(store.restore(second.character_id).class_id, &"")

func test_invalid_save_is_preserved_and_does_not_replace_loaded_profiles() -> void:
	if store == null: return
	var character = CharacterSession.new()
	character.create_identity("Kairo", &"saiyan")
	store.save_profile(character)
	var file := FileAccess.open(STORE_PATH, FileAccess.WRITE)
	file.store_string('{"version":1,"profiles":[{"id":"x","name":"Bad","race":"typo","class":""}]}')
	file.close()
	assert_false(store.load_profiles())
	assert_eq(store.profiles.size(), 1)
	assert_false(store.save_profile(character), "Do not overwrite a damaged save")
	assert_string_contains(FileAccess.get_file_as_string(STORE_PATH), "typo")

func test_identity_validation_and_race_caps_are_independent_of_class() -> void:
	var character = CharacterSession.new()
	assert_false(character.create_identity("  ", &"saiyan"))
	assert_false(character.create_identity("Kairo", &"sayan"))
	assert_true(character.create_identity("Kairo", &"saiyan"))
	assert_eq(character.attribute_cap(&"body"), 100)
	assert_eq(character.attribute_cap(&"mind"), 75)
	character.preview_class(&"wizard")
	character.confirm_class()
	assert_eq(character.attribute_cap(&"body"), 100)
	assert_eq(character.stats.body, 10)
	assert_false(character.create_identity("Changed", &"mazoku"))
func test_unknown_version_duplicate_ids_and_wrong_types_are_rejected() -> void:
	if store == null: return
	var character = CharacterSession.new()
	character.create_identity("Rune", &"patryn")
	assert_true(store.save_profile(character))
	var record: Dictionary = store.profiles[0].duplicate()
	for invalid in [
		{"version": 2, "profiles": [record]},
		{"version": 1, "profiles": [record, record]},
		{"version": 1, "profiles": [{"id": "id", "name": 12, "race": "saiyan", "class": ""}]},
		{"version": 1, "profiles": [{"id": "id", "name": "Bad", "race": "saiyan", "class": "typo"}]},
	]:
		var file := FileAccess.open(STORE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(invalid))
		file.close()
		assert_false(store.load_profiles())
		assert_eq(store.profiles.size(), 1)

func test_save_failure_does_not_commit_in_memory_and_can_be_retried() -> void:
	if store == null: return
	var character = CharacterSession.new()
	character.create_identity("Kairo", &"saiyan")
	store.path = "user://missing_profile_directory/characters.json"
	assert_false(store.save_profile(character))
	assert_eq(store.profiles.size(), 0)
	store.path = STORE_PATH
	assert_true(store.save_profile(character))
	assert_eq(store.profiles.size(), 1)
func test_fist_and_witch_are_races_combined_with_the_original_classes() -> void:
	assert_true(RaceCatalog.contains(&"fist"))
	assert_true(RaceCatalog.contains(&"witch_warlock"))
	assert_false(ClassCatalog.contains(&"fist"))
	assert_eq(ClassCatalog.display_name(&"warlock"), "Warlock")
	assert_eq(ClassCatalog.CLASSES.size(), 12)
	assert_eq(RaceCatalog.RACES.size(), 5)
	for pairing in [[&"fist", &"monk"], [&"witch_warlock", &"wizard"]]:
		var character = CharacterSession.new()
		assert_true(character.create_identity("Traveler", pairing[0]))
		assert_true(character.preview_class(pairing[1]))
		assert_true(character.confirm_class())
		assert_eq(character.race_id, pairing[0])
		assert_eq(character.class_id, pairing[1])
		assert_true(store.save_profile(character))
		assert_true(store.load_profiles())
		var restored = store.restore(character.character_id)
		assert_not_null(restored)
		assert_eq(restored.race_id, pairing[0])
		assert_eq(restored.class_id, pairing[1])