extends GutTest

func test_skill_events_match_damage_and_rejected_skills_emit_nothing() -> void:
	var model := TrainingEncounter.new(CharacterStats.new(), 1)
	assert_true(model.has_signal("combat_event"))
	if not model.has_signal("combat_event"): return
	var events: Array[Dictionary] = []
	model.connect("combat_event", func(event: Dictionary) -> void: events.append(event))
	model.start()
	assert_eq(events[0].kind, &"started")
	model.use_skill(&"spark")
	assert_eq(events[-1].actor, &"player")
	assert_eq(events[-1].target, &"enemy")
	assert_eq(events[-1].damage, 160)
	assert_eq(events[-1].skill, &"spark")
	var count := events.size()
	model.use_skill(&"heavy_strike")
	assert_eq(events.size(), count)

func test_killing_hit_finishes_without_retaliation() -> void:
	var stats := CharacterStats.new()
	stats.hitroll = 100
	var model := TrainingEncounter.new(stats, 2)
	if not model.has_signal("combat_event"):
		fail_test("Missing structured events")
		return
	var events: Array[Dictionary] = []
	model.connect("combat_event", func(event: Dictionary) -> void: events.append(event))
	model.start()
	model.enemy_health = 1
	model.advance(3.0)
	assert_eq(events.size(), 3)
	assert_eq(events[1].damage, 1)
	assert_eq(events[2].kind, &"finished")
	assert_eq(events[2].outcome, &"victory")
	assert_eq(stats.health, 2000)

func test_round_events_cover_both_sides_and_misses() -> void:
	var found_miss := false
	var found_enemy_hit := false
	for seed_value in range(30):
		var model := TrainingEncounter.new(CharacterStats.new(), seed_value)
		if not model.has_signal("combat_event"):
			fail_test("Missing structured events")
			return
		var events: Array[Dictionary] = []
		model.connect("combat_event", func(event: Dictionary) -> void: events.append(event))
		model.start()
		model.advance(3.0)
		assert_eq(events[1].actor, &"player")
		assert_eq(events[2].actor, &"enemy")
		assert_eq(events[2].target, &"player")
		for event in events:
			if event.kind == &"miss":
				found_miss = true
				assert_eq(event.damage, 0)
			if event.kind == &"hit" and event.actor == &"enemy":
				found_enemy_hit = true
				assert_eq(event.damage, 90)
	assert_true(found_miss)
	assert_true(found_enemy_hit)

func test_defeat_event_reports_actual_nonlethal_damage() -> void:
	var stats := CharacterStats.new()
	stats.health = 25
	var model := TrainingEncounter.new(stats, 2)
	var events: Array[Dictionary] = []
	model.combat_event.connect(func(event: Dictionary) -> void: events.append(event))
	model.start()
	for round_index in range(10):
		model.enemy_health = 600
		model.advance(3.0)
		if model.state == &"defeat": break
	assert_eq(stats.health, 1)
	assert_eq(events[-2].actor, &"enemy")
	assert_eq(events[-2].damage, 24)
	assert_eq(events[-1].outcome, &"defeat")

func test_insufficient_resources_and_unknown_skills_emit_no_hit() -> void:
	var stats := CharacterStats.new()
	stats.mana = 0
	stats.vigor = 0
	var model := TrainingEncounter.new(stats)
	var events: Array[Dictionary] = []
	model.combat_event.connect(func(event: Dictionary) -> void: events.append(event))
	model.start()
	assert_false(model.use_skill(&"spark"))
	assert_false(model.use_skill(&"heavy_strike"))
	assert_false(model.use_skill(&"unknown"))
	assert_eq(events.size(), 1)
