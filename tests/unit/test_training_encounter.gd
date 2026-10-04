extends GutTest
var stats: CharacterStats
var encounter: RefCounted

func before_each() -> void:
	stats = CharacterStats.new()
	var script = load("res://game/combat/training_encounter.gd")
	assert_not_null(script, "A testable encounter model is required")
	if script != null:
		encounter = script.new(stats, 12345)

func test_melee_clock_is_independent_of_skill_lag() -> void:
	if encounter == null: return
	encounter.start()
	encounter.advance(2.9)
	assert_true(encounter.use_skill(&"heavy_strike"))
	assert_eq(stats.vigor, 920)
	assert_false(encounter.use_skill(&"spark"))
	assert_eq(stats.mana, 1000)
	encounter.advance(0.11)
	assert_eq(encounter.rounds, 1)
	assert_gt(encounter.lag_remaining, 1.3)
	assert_eq(stats.vigor, 920, "No recovery during combat")

func test_skill_costs_fail_atomically_and_actions_require_active_encounter() -> void:
	if encounter == null: return
	assert_false(encounter.use_skill(&"spark"))
	encounter.start()
	stats.mana = 99
	stats.vigor = 79
	assert_false(encounter.use_skill(&"spark"))
	assert_false(encounter.use_skill(&"heavy_strike"))
	assert_false(encounter.use_skill(&"missing"))
	assert_eq(stats.mana, 99)
	assert_eq(stats.vigor, 79)
	assert_eq(encounter.enemy_health, 600)
	assert_eq(encounter.lag_remaining, 0.0)
	stats.mana = 100
	assert_true(encounter.use_skill(&"spark"))
	assert_eq(stats.mana, 0)

func test_large_and_small_time_steps_produce_same_outcome() -> void:
	if encounter == null: return
	var other = load("res://game/combat/training_encounter.gd").new(CharacterStats.new(), 12345)
	encounter.start()
	other.start()
	encounter.advance(9.5)
	for _index in 95:
		other.advance(0.1)
	assert_eq(encounter.rounds, other.rounds)
	assert_eq(encounter.enemy_health, other.enemy_health)
	assert_eq(stats.health, other.stats.health)
	assert_almost_eq(encounter.until_round, other.until_round, 0.0001)

func test_victory_prevents_retaliation_and_further_spending() -> void:
	if encounter == null: return
	stats.hitroll = 1000
	stats.damroll = 1000
	encounter.start()
	encounter.advance(3.0)
	assert_eq(encounter.state, &"victory")
	assert_eq(stats.health, 2000)
	assert_eq(encounter.enemy_health, 0)
	assert_false(encounter.use_skill(&"spark"))
	assert_eq(stats.mana, 1000)

func test_defeat_is_nonlethal_and_withdrawal_stops_rounds() -> void:
	if encounter == null: return
	encounter.start()
	stats.health = 2
	encounter.enemy_health = 100000
	for _round in 10:
		encounter.advance(3.0)
		if encounter.state != &"active":
			break
	assert_eq(encounter.state, &"defeat")
	assert_eq(stats.health, 1)
	assert_false(encounter.use_skill(&"heavy_strike"))
	encounter.start()
	encounter.withdraw()
	var rounds_before: int = encounter.rounds
	encounter.advance(6.0)
	assert_eq(encounter.state, &"withdrawn")
	assert_eq(encounter.rounds, rounds_before)

func test_recovery_is_bounded_and_frame_independent() -> void:
	if encounter == null: return
	stats.health = 1
	stats.mana = 0
	stats.vigor = 0
	for _index in 10:
		encounter.advance(0.01)
	assert_eq(stats.health, 21)
	assert_eq(stats.mana, 10)
	assert_eq(stats.vigor, 10)
	encounter.advance(100.0)
	assert_eq(stats.health, 2000)
	assert_eq(stats.mana, 1000)
	assert_eq(stats.vigor, 1000)
	encounter.advance(-1.0)
	assert_eq(stats.health, 2000)

func test_hitroll_and_damroll_have_separate_effects() -> void:
	if encounter == null: return
	stats.hitroll = -100
	assert_eq(encounter.hit_chance(), 5)
	stats.hitroll = 100
	assert_eq(encounter.hit_chance(), 95)
	stats.damroll = 20
	assert_eq(encounter.melee_damage(), 120)
func test_restarting_an_active_fight_cannot_reset_its_clock_or_target() -> void:
	if encounter == null: return
	encounter.start()
	encounter.advance(1.0)
	encounter.use_skill(&"spark")
	assert_false(encounter.start())
	assert_eq(encounter.until_round, 2.0)
	assert_eq(encounter.enemy_health, 440)
	assert_eq(stats.mana, 900)

func test_training_win_from_skill_and_vigor_cost_are_exact() -> void:
	if encounter == null: return
	encounter.start()
	encounter.enemy_health = 140
	assert_true(encounter.use_skill(&"heavy_strike"))
	assert_eq(encounter.state, &"victory")
	assert_eq(stats.vigor, 920)
	assert_false(encounter.use_skill(&"heavy_strike"))
	assert_eq(stats.vigor, 920)

func test_minimum_resource_and_lag_boundary() -> void:
	if encounter == null: return
	encounter.start()
	stats.vigor = 80
	encounter.use_skill(&"heavy_strike")
	assert_eq(stats.vigor, 0)
	encounter.advance(1.49)
	assert_false(encounter.use_skill(&"spark"))
	encounter.advance(0.01)
	assert_true(encounter.use_skill(&"spark"))
	assert_eq(stats.mana, 900)