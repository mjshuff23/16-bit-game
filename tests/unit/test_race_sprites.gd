extends GutTest

func test_every_race_has_four_directions_and_three_frames() -> void:
	var art = load("res://game/actors/race_sprites.gd")
	assert_not_null(art)
	if art == null:
		return
	for race in RaceCatalog.RACES:
		assert_true(art.SHEETS.has(race))
		assert_true(art.REGIONS.has(String(race)))
		assert_eq(art.REGIONS[String(race)].size(), 12)
		for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
			for frame in range(3):
				var region: Rect2 = art.region(race, direction, frame)
				assert_gt(region.size.x, 0.0)
				assert_gt(region.size.y, 0.0)
				assert_true(Rect2(0, 0, 1086, 1448).encloses(region))
				var row: int = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP].find(direction)
				assert_true(Rect2(frame * 362, row * 362, 362, 362).encloses(region), "Expected distinct sheet cell for direction and pose")

func test_idle_and_walk_cycle() -> void:
	var art = load("res://game/actors/race_sprites.gd")
	if art == null:
		fail_test("Race sprite implementation missing")
		return
	assert_eq(art.frame_at(0.0), 0)
	assert_eq(art.frame_at(0.13), 1)
	assert_eq(art.frame_at(0.26), 0)
	assert_eq(art.frame_at(0.39), 2)
	assert_eq(art.frame_at(0.51), 0)

func test_player_uses_selected_race_and_preserves_collision() -> void:
	var player = load("res://game/actors/player.tscn").instantiate()
	add_child_autofree(player)
	assert_true(player.has_method("set_race"))
	if not player.has_method("set_race"):
		return
	var shape = player.get_node("CollisionShape2D").shape
	for race in RaceCatalog.RACES:
		player.set_race(race)
		assert_eq(player.race_id, race)
		assert_same(player.get_node("CollisionShape2D").shape, shape)

func test_fractional_and_dominant_axis_directions() -> void:
	for race in RaceCatalog.RACES:
		for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
			assert_eq(RaceSprites.region(race, direction * 0.4, 1), RaceSprites.region(race, direction, 1))
		assert_eq(RaceSprites.region(race, Vector2(-0.8, 0.2), 0), RaceSprites.region(race, Vector2.LEFT, 0))
		assert_eq(RaceSprites.region(race, Vector2(0.2, -0.8), 0), RaceSprites.region(race, Vector2.UP, 0))
