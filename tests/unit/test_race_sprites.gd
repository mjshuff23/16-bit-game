extends GutTest

func test_every_race_has_four_directions_and_three_frames() -> void:
	var art = load("res://game/actors/race_sprites.gd")
	assert_not_null(art)
	if art == null:
		return
	for race in RaceCatalog.RACES:
		assert_true(art.SHEETS.has(race))
		for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
			for frame in range(3):
				var region: Rect2 = art.region(race, direction, frame)
				assert_gt(region.size.x, 0.0)
				assert_gt(region.size.y, 0.0)
				assert_true(Rect2(0, 0, 1086, 1448).encloses(region))

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
