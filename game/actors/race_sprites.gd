class_name RaceSprites
extends RefCounted
## Original sheets: rows down/left/right/up; columns idle/step/step.
const SHEETS := {
	&"saiyan": preload("res://assets/characters/saiyan.png"),
	&"fist": preload("res://assets/characters/fist.png"),
	&"mazoku": preload("res://assets/characters/mazoku.png"),
	&"witch_warlock": preload("res://assets/characters/witch_warlock.png"),
	&"patryn": preload("res://assets/characters/patryn.png"),
}
const REGIONS = preload("res://assets/characters/regions.gd").DATA
const ART_SCALE := 0.08

static func frame_at(time: float) -> int:
	return [0, 1, 0, 2][int(time * 8.0) % 4]

static func data(race: StringName, direction: Vector2, frame: int) -> Dictionary:
	var row := 0
	if direction.x != 0.0 and absf(direction.x) >= absf(direction.y):
		row = 1 if direction.x < 0.0 else 2
	elif direction.y < 0.0:
		row = 3
	return REGIONS.get(String(race), REGIONS["saiyan"])[row * 3 + clampi(frame, 0, 2)]

static func region(race: StringName, direction: Vector2, frame: int) -> Rect2:
	var values: Array = data(race, direction, frame)["rect"]
	return Rect2(values[0], values[1], values[2], values[3])

static func anchor(race: StringName, direction: Vector2, frame: int) -> Vector2:
	var values: Array = data(race, direction, frame)["anchor"]
	return Vector2(values[0], values[1])
