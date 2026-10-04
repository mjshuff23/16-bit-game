extends CharacterBody2D

const SPEED := 55.0
var race_id: StringName = &"saiyan"
var movement_enabled := true
var facing := Vector2.DOWN
var walk_time := 0.0

func _physics_process(delta: float) -> void:
	var horizontal := clampf(Input.get_axis("move_left", "move_right") + Input.get_axis("ui_left", "ui_right"), -1.0, 1.0)
	var vertical := clampf(Input.get_axis("move_up", "move_down") + Input.get_axis("ui_up", "ui_down"), -1.0, 1.0)
	# Horizontal wins ties so simultaneous inputs never create diagonal motion.
	var direction := Vector2(horizontal, 0) if horizontal != 0 else Vector2(0, vertical)
	if not movement_enabled:
		direction = Vector2.ZERO
	if direction != Vector2.ZERO:
		facing = direction
	velocity = direction * SPEED
	move_and_slide()
	walk_time = walk_time + delta if get_real_velocity().length_squared() > 1.0 else 0.0
	queue_redraw()

func _draw() -> void:
	var frame := RaceSprites.frame_at(walk_time)
	var region := RaceSprites.region(race_id, facing, frame)
	var anchor := RaceSprites.anchor(race_id, facing, frame)
	draw_texture_rect_region(RaceSprites.SHEETS[race_id], Rect2(-anchor * RaceSprites.ART_SCALE, region.size * RaceSprites.ART_SCALE), region)

func set_race(id: StringName) -> void:
	race_id = id if RaceSprites.SHEETS.has(id) else &"saiyan"
	walk_time = 0.0
	queue_redraw()
