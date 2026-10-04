extends CharacterBody2D

const SPEED := 55.0
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
	var step := 1 if int(walk_time * 8.0) % 2 == 1 else 0
	draw_rect(Rect2(-6, 0, 12, 3), Color("1a2825"))
	draw_rect(Rect2(-4, -4, 3, 6 - step), Color("293038"))
	draw_rect(Rect2(1, -4, 3, 5 + step), Color("293038"))
	draw_rect(Rect2(-5, -11, 10, 9), Color("4c7582"))
	draw_rect(Rect2(-3, -11, 3, 8), Color("79a5a5"))
	draw_rect(Rect2(-5, -5, 10, 2), Color("c6a977"))
	draw_rect(Rect2(-4, -17, 8, 7), Color("d5ae83"))
	draw_rect(Rect2(-5, -18, 10, 3), Color("302e3e"))
	if facing == Vector2.UP:
		draw_rect(Rect2(-4, -16, 8, 5), Color("302e3e"))
	elif facing == Vector2.DOWN:
		draw_rect(Rect2(-3, -14, 1, 2), Color("252734"))
		draw_rect(Rect2(2, -14, 1, 2), Color("252734"))
	else:
		var eye_x := -3 if facing == Vector2.LEFT else 2
		draw_rect(Rect2(eye_x, -14, 1, 2), Color("252734"))
