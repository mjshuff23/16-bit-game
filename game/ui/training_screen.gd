extends Control
signal leave_requested
var encounter: TrainingEncounter
var bars: ResourceBars

func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = 14
	var backdrop := ColorRect.new()
	backdrop.size = Vector2(640, 360)
	backdrop.color = Color("101c19")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_label("Title", "TEMPLE TRAINING", Rect2(16, 8, 608, 30), 24)
	_label("Hint", "Automatic melee every 3s. Skills never reset the round.", Rect2(16, 42, 608, 22), 14)
	bars = ResourceBars.new()
	bars.position = Vector2(16, 68)
	add_child(bars)
	_label("Enemy", "", Rect2(16, 100, 416, 22), 16)
	var enemy_bar := ProgressBar.new()
	enemy_bar.name = "EnemyBar"
	enemy_bar.position = Vector2(16, 124)
	enemy_bar.size = Vector2(416, 28)
	enemy_bar.max_value = TrainingEncounter.ENEMY_MAX_HEALTH
	enemy_bar.show_percentage = false
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = Color("293930")
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color("a4494b")
	enemy_bar.add_theme_stylebox_override("background", bar_background)
	enemy_bar.add_theme_stylebox_override("fill", bar_fill)
	add_child(enemy_bar)
	_label("Timing", "", Rect2(16, 158, 608, 22), 14)
	_label("Log", "", Rect2(16, 186, 608, 76), 14)
	_button("Start", "Start (Enter)", Rect2(460, 103, 164, 36), _start)
	_button("HeavyStrike", "1  Heavy Strike\n80 Vigor / 1.5s lag", Rect2(16, 272, 236, 44), _heavy)
	_button("Spark", "2  Spark\n100 Mana / 2s lag", Rect2(264, 272, 216, 44), _spark)
	_button("Leave", "Leave (Esc)", Rect2(492, 272, 132, 44), func() -> void: leave_requested.emit())
	_label("Footer", "Nonlethal. No XP rewards. Recover outside combat. C: character", Rect2(16, 326, 608, 24), 13)

func open(model: TrainingEncounter) -> void:
	encounter = model
	refresh()

func refresh() -> void:
	if encounter == null:
		return
	bars.update_values(encounter.stats)
	$Enemy.text = "Practice opponent: %d / %d" % [encounter.enemy_health, TrainingEncounter.ENEMY_MAX_HEALTH]
	$EnemyBar.value = encounter.enemy_health
	$Log.text = "\n".join(encounter.messages)
	$Start.disabled = encounter.state == &"active"
	$Start.text = "In training" if encounter.state == &"active" else "Start (Enter)"
	$HeavyStrike.disabled = not encounter.skill_available(&"heavy_strike")
	$Spark.disabled = not encounter.skill_available(&"spark")
	if encounter.state == &"active":
		$Timing.text = "Next melee: %.1fs    Action lag: %.1fs    Round: %d" % [encounter.until_round, encounter.lag_remaining, encounter.rounds]
	else:
		$Timing.text = "%s - resources recovering" % String(encounter.state).capitalize()

func _start() -> void:
	if encounter != null:
		encounter.start()
		refresh()
func _heavy() -> void:
	if encounter != null:
		encounter.use_skill(&"heavy_strike")
		refresh()
func _spark() -> void:
	if encounter != null:
		encounter.use_skill(&"spark")
		refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("training_heavy"):
		_heavy()
	elif event.is_action_pressed("training_spark"):
		_spark()
	elif event.is_action_pressed("ui_accept"):
		_start()
	elif event.is_action_pressed("ui_cancel"):
		leave_requested.emit()
	else:
		return
	get_viewport().set_input_as_handled()

func _label(node_name: String, text: String, rect: Rect2, font_size: int) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("line_spacing", 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(label)

func _button(node_name: String, text: String, rect: Rect2, action: Callable) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)