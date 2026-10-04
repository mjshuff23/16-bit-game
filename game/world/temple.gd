extends Node2D

signal class_selection_requested
signal characters_requested

const SPAWN := Vector2(160, 128)
const ALTAR := Vector2(160, 48)
const TREES: Array[Vector2] = [Vector2(24, 44), Vector2(50, 39), Vector2(79, 47), Vector2(247, 44), Vector2(276, 38), Vector2(301, 50), Vector2(29, 82), Vector2(65, 92), Vector2(258, 89), Vector2(294, 86), Vector2(20, 131), Vector2(54, 148), Vector2(88, 133), Vector2(232, 139), Vector2(274, 144), Vector2(302, 122)]
const WALLS: Array[Rect2] = [Rect2(104, 24, 112, 8), Rect2(104, 32, 8, 56), Rect2(208, 32, 8, 56), Rect2(104, 80, 40, 8), Rect2(176, 80, 40, 8)]

var selected_class: StringName = &""
var inspection_open := false

@onready var player: CharacterBody2D = $Player
@onready var prompt: Label = $HUD/Prompt
@onready var inspection: Panel = $HUD/Inspection

func _ready() -> void:
	# CanvasLayer keeps the HUD sharp and independent of the world camera.
	visibility_changed.connect(func() -> void: $HUD.visible = is_visible_in_tree())
	$HUD.visible = is_visible_in_tree()
	$HUD/Header/Location.clip_text = true
	$HUD/Header/Location.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_build_ground()
	for wall in WALLS:
		_add_obstacle(wall)
	for tree in TREES:
		_add_obstacle(Rect2(tree - Vector2(9, 10), Vector2(18, 14)))
	for boundary in [Rect2(0, 16, 8, 148), Rect2(312, 16, 8, 148), Rect2(0, 8, 320, 8), Rect2(0, 160, 320, 8)]:
		_add_obstacle(boundary)
	_add_obstacle(Rect2(150, 40, 20, 12))

func start(class_id: StringName) -> void:
	set_class(class_id)
	player.position = SPAWN
	player.velocity = Vector2.ZERO
	player.facing = Vector2.UP
	close_inspection()

func set_class(class_id: StringName) -> void:
	selected_class = class_id
	$HUD/Header/Class.text = ClassCatalog.display_name(class_id) if class_id != &"" else "Unclassed"
	$HUD/Objective.text = "First quest: choose a path at the altar" if class_id == &"" else "First quest complete: path chosen"
	prompt.text = "[E] Choose your path" if class_id == &"" else "[E] Inspect altar"

func _process(_delta: float) -> void:
	prompt.visible = not inspection_open and player.position.distance_to(ALTAR) <= 22.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("ui_cancel"):
		if inspection_open:
			close_inspection()
		else:
			characters_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if inspection_open:
			close_inspection()
		else:
			try_interact()
		get_viewport().set_input_as_handled()

func try_interact() -> bool:
	if player.position.distance_to(ALTAR) > 22.0 or inspection_open:
		return false
	if selected_class == &"":
		class_selection_requested.emit()
		return true
	inspection_open = true
	inspection.show()
	player.movement_enabled = false
	player.velocity = Vector2.ZERO
	return true

func close_inspection() -> void:
	inspection_open = false
	inspection.hide()
	player.movement_enabled = true

func _add_obstacle(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.position = rect.get_center()
	body.add_child(collider)
	$Obstacles.add_child(body)

func _build_ground() -> void:
	var atlas := TileSetAtlasSource.new()
	atlas.texture = preload("res://assets/tiles/forest_placeholder.svg")
	atlas.texture_region_size = Vector2i(16, 16)
	for tile in range(3):
		atlas.create_tile(Vector2i(tile, 0))
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(16, 16)
	tiles.add_source(atlas, 0)
	$Ground.tile_set = tiles
	for y in range(11):
		for x in range(20):
			var tile := 0
			if x >= 9 and x <= 10 and y >= 5:
				tile = 1
			if x >= 7 and x <= 12 and y >= 2 and y <= 4:
				tile = 2
			$Ground.set_cell(Vector2i(x, y), 0, Vector2i(tile, 0))

func _draw() -> void:
	# A roofless cutaway keeps the single-room temple readable from above.
	draw_rect(Rect2(100, 28, 120, 65), Color("1a302b"))
	# Restore floor above the foundation shadow; the TileMapLayer remains the terrain.
	draw_rect(Rect2(112, 32, 96, 48), Color("5c6c68"))
	for x in range(112, 209, 16):
		draw_line(Vector2(x, 32), Vector2(x, 80), Color("435a55"))
	for y in range(32, 81, 16):
		draw_line(Vector2(112, y), Vector2(208, y), Color("435a55"))
	for wall in WALLS:
		draw_rect(wall, Color("899586"))
		draw_rect(Rect2(wall.position, Vector2(wall.size.x, 2)), Color("bcc3a0"))
		draw_rect(Rect2(wall.position + Vector2(0, wall.size.y - 2), Vector2(wall.size.x, 2)), Color("435a50"))
		for x in range(int(wall.position.x) + 12, int(wall.end.x), 16):
			draw_line(Vector2(x, wall.position.y + 2), Vector2(x, wall.end.y - 2), Color("5c7060"))
	# Temple threshold, small columns, and an unmarked altar.
	for y in [88, 92, 96]:
		draw_rect(Rect2(140, y, 40, 3), Color("879080"))
	for x in [116, 196]:
		draw_rect(Rect2(x - 2, 70, 12, 10), Color("394f49"))
		draw_rect(Rect2(x, 56, 8, 20), Color("9fa88e"))
		draw_rect(Rect2(x - 2, 55, 12, 4), Color("c4c7a5"))
	draw_rect(Rect2(148, 43, 24, 12), Color("334944"))
	draw_rect(Rect2(150, 39, 20, 11), Color("879788"))
	draw_rect(Rect2(148, 37, 24, 5), Color("b9bba1"))
	draw_rect(Rect2(158, 37, 4, 2), Color("d9c88b"))
	for tree in TREES:
		_draw_tree(tree)
	# Tiny flowers and moss patches, deterministic so the map does not change per run.
	for spot in [Vector2(91, 105), Vector2(121, 119), Vector2(201, 136), Vector2(226, 104)]:
		draw_rect(Rect2(spot, Vector2(3, 2)), Color("c7b68d"))
		draw_rect(Rect2(spot + Vector2(4, 3), Vector2(2, 2)), Color("9cae75"))

func _draw_tree(p: Vector2) -> void:
	draw_rect(Rect2(p + Vector2(-12, -1), Vector2(25, 6)), Color("1c302a"))
	draw_rect(Rect2(p + Vector2(-3, -13), Vector2(6, 15)), Color("61523b"))
	draw_rect(Rect2(p + Vector2(-1, -10), Vector2(2, 11)), Color("9a7950"))
	draw_rect(Rect2(p + Vector2(-12, -24), Vector2(24, 15)), Color("182f2c"))
	draw_rect(Rect2(p + Vector2(-8, -30), Vector2(16, 25)), Color("234b3c"))
	draw_rect(Rect2(p + Vector2(-14, -22), Vector2(26, 10)), Color("2f6044"))
	draw_rect(Rect2(p + Vector2(-9, -27), Vector2(15, 11)), Color("48754c"))
	draw_rect(Rect2(p + Vector2(-6, -29), Vector2(10, 4)), Color("75905a"))
