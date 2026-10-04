extends GutTest

const SESSION_PATH := "res://game/character/character_session.gd"
const EXPECTED_IDS := [&"barbarian", &"bard", &"cleric", &"druid", &"fighter", &"monk", &"paladin", &"ranger", &"rogue", &"sorcerer", &"warlock", &"wizard"]

var session: RefCounted

func test_shared_stats_match_mud_starting_values() -> void:
	assert_eq(session.stats.body, 10)
	assert_eq(session.stats.mind, 10)
	assert_eq(session.stats.spirit, 10)
	assert_eq(session.stats.willpower, 10)
	assert_eq(session.stats.health, 2000)
	assert_eq(session.stats.max_health, 2000)
	assert_eq(session.stats.mana, 1000)
	assert_eq(session.stats.max_mana, 1000)
	assert_eq(session.stats.move_points, 1000)
	assert_eq(session.stats.max_move_points, 1000)
	assert_eq(session.stats.primal, 0)

func test_class_confirmation_does_not_reset_stats() -> void:
	session.stats.body = 12
	session.stats.mana = 900
	session.preview_class(&"wizard")
	session.confirm_class()
	assert_eq(session.stats.body, 12)
	assert_eq(session.stats.mana, 900)
	var other: RefCounted = load(SESSION_PATH).new()
	assert_eq(other.stats.body, 10)
	session.reset()
	assert_eq(session.stats.body, 10)
	assert_eq(session.stats.mana, 1000)

func before_each() -> void:
	var script = load(SESSION_PATH)
	assert_not_null(script, "The session implementation must exist")
	if script != null:
		session = script.new()

func test_no_default_or_confirmation_without_selection() -> void:
	if session == null: return
	assert_eq(session.class_id, &"")
	assert_eq(session.pending_class_id, &"")
	assert_false(session.confirm_class())

func test_every_core_class_can_be_confirmed() -> void:
	if session == null: return
	for id in EXPECTED_IDS:
		session.reset()
		assert_true(session.preview_class(id))
		assert_eq(session.class_id, &"", "Preview must not commit")
		assert_true(session.confirm_class())
		assert_eq(session.class_id, id)

func test_invalid_choice_preserves_previous_preview() -> void:
	if session == null: return
	session.preview_class(&"wizard")
	assert_false(session.preview_class(&"wizzard"))
	assert_false(session.preview_class(&""))
	assert_eq(session.pending_class_id, &"wizard")

func test_preview_can_change_but_confirmation_locks_choice() -> void:
	if session == null: return
	session.preview_class(&"fighter")
	session.preview_class(&"monk")
	assert_true(session.confirm_class())
	assert_false(session.preview_class(&"bard"))
	assert_false(session.confirm_class())
	assert_eq(session.class_id, &"monk")

func test_reset_clears_choice_without_affecting_another_session() -> void:
	if session == null: return
	var other: RefCounted = load(SESSION_PATH).new()
	session.preview_class(&"rogue")
	session.confirm_class()
	assert_eq(other.class_id, &"")
	other.preview_class(&"druid")
	session.reset()
	assert_eq(session.class_id, &"")
	assert_eq(session.pending_class_id, &"")
	assert_eq(other.pending_class_id, &"druid")
