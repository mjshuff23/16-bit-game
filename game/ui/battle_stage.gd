class_name BattleStage
extends Control
## Presentation only: no combat clock, damage rules or input handling.
const PLAYER := Vector2(476, 189)
const ENEMY := Vector2(158, 181)
var race_id: StringName = &"saiyan"
var flashes: Dictionary[StringName, float] = {&"player": 0.0, &"enemy": 0.0}
var feedback: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func clear_effects() -> void:
	feedback.clear()
	flashes[&"player"] = 0.0
	flashes[&"enemy"] = 0.0
	queue_redraw()

func present(event: Dictionary) -> void:
	if event.kind == &"started":
		clear_effects()
	elif event.kind == &"hit" or event.kind == &"miss":
		var color := Color("eee6c5")
		var prefix := ""
		if event.skill == &"spark":
			color = Color("8ecbff")
			prefix = "Spark "
		elif event.skill == &"heavy_strike":
			color = Color("f4c478")
			prefix = "Heavy "
		var text := "Miss" if event.kind == &"miss" else prefix + str(event.damage)
		var origin: Vector2 = PLAYER if event.target == &"player" else ENEMY
		origin.y -= 74 + (feedback.size() % 3) * 16
		feedback.append({"text": text, "color": color, "origin": origin, "age": 0.0})
		if event.kind == &"hit":
			flashes[event.target] = 0.18
		queue_redraw()

func _process(delta: float) -> void:
	for target in flashes:
		flashes[target] = maxf(0.0, flashes[target] - delta)
	for item in feedback:
		item.age += delta
	feedback = feedback.filter(func(item: Dictionary) -> bool: return item.age < 0.9)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 208), Color("152c28"))
	# Distant forest silhouettes and temple stone terrace.
	for x in range(12, 640, 58):
		draw_rect(Rect2(x + 15, 48, 9, 78), Color("263d31"))
		draw_circle(Vector2(x + 18, 69), 28, Color("214b3c"))
		draw_circle(Vector2(x + 10, 58), 18, Color("315640"))
	draw_rect(Rect2(0, 135, 640, 73), Color("56615a"))
	for y in [137, 169, 201]:
		draw_line(Vector2(0, y), Vector2(640, y), Color("384c44"), 2)
		for x in range(0, 640, 64):
			draw_line(Vector2(x + (32 if y == 169 else 0), y), Vector2(x + (32 if y == 169 else 0), y + 30), Color("43564d"))
	for x in [28, 590]:
		draw_rect(Rect2(x, 60, 20, 106), Color("8c9580"))
		draw_rect(Rect2(x - 5, 54, 30, 9), Color("b6b995"))
	var wood := Color("fff0c8") if flashes[&"enemy"] > 0 else Color("ad7b48")
	draw_rect(Rect2(ENEMY + Vector2(-7, -76), Vector2(14, 77)), wood)
	draw_rect(Rect2(ENEMY + Vector2(-34, -48), Vector2(68, 10)), wood)
	draw_rect(Rect2(ENEMY + Vector2(-23, -4), Vector2(46, 7)), Color("795834"))
	draw_circle(ENEMY + Vector2(0, -76), 14, wood)
	draw_circle(ENEMY + Vector2(0, -42), 21, Color("d3b477"))
	draw_circle(ENEMY + Vector2(0, -42), 13, wood)
	draw_circle(ENEMY + Vector2(0, -42), 5, Color("784e39"))
	var region := RaceSprites.region(race_id, Vector2.LEFT, 0)
	var anchor := RaceSprites.anchor(race_id, Vector2.LEFT, 0)
	var tint := Color(2, 2, 2) if flashes[&"player"] > 0 else Color.WHITE
	draw_texture_rect_region(RaceSprites.SHEETS[race_id], Rect2(PLAYER - anchor * 0.25, region.size * 0.25), region, tint)
	var font := ThemeDB.fallback_font
	for item in feedback:
		var color: Color = item.color
		color.a = minf(1.0, (0.9 - item.age) * 4)
		var at: Vector2 = item.origin - Vector2(font.get_string_size(item.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x / 2, item.age * 22)
		draw_string_outline(font, at, item.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 4, Color("101c19"))
		draw_string(font, at, item.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, color)
