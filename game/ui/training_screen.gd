extends Control
signal leave_requested
var encounter: TrainingEncounter
var bars: ResourceBars

var stage: BattleStage
var character: CharacterSession

func _ready() -> void:
	theme = Theme.new()
	theme.default_font_size = 14
	var backdrop := ColorRect.new()
	backdrop.size = Vector2(640, 360)
	backdrop.color = Color("101c19")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	stage = BattleStage.new()
	stage.name = "Stage"
	add_child(stage)
	_label("Title", "TEMPLE TRAINING", Rect2(16, 6, 265, 24), 18)
	_label("Identity", "", Rect2(340, 6, 284, 24), 14)
	_label("Enemy", "", Rect2(66, 31, 250, 20), 13)
	_meter("EnemyBar", Rect2(66, 53, 184, 10), Color("ae5656"))
	_label("Outcome", "", Rect2(320, 32, 300, 40), 13)
	bars = ResourceBars.new()
	bars.position = Vector2(16, 212)
	add_child(bars)
	_label("Timing", "", Rect2(16, 238, 288, 20), 13)
	_label("LagTiming", "", Rect2(320, 238, 304, 20), 13)
	_meter("MeleeMeter", Rect2(16, 260, 288, 5), Color("95bc99"))
	_meter("LagMeter", Rect2(320, 260, 304, 5), Color("c8a870"))
	_button("Start", "Start (Enter)", Rect2(16, 274, 108, 40), _start)
	_button("HeavyStrike", "1 Heavy Strike\n80 Vigor / 1.5s", Rect2(132, 274, 177, 40), _heavy)
	_button("Spark", "2 Spark\n100 Mana / 2s", Rect2(317, 274, 167, 40), _spark)
	_button("Leave", "Leave (Esc)", Rect2(492, 274, 132, 40), func() -> void: leave_requested.emit())
	_label("Log", "", Rect2(16, 318, 608, 32), 12)
	_label("Footer", "Nonlethal / No XP    Melee every 3s    C: character", Rect2(16, 346, 608, 14), 10)
	visibility_changed.connect(func() -> void:
		if not is_visible_in_tree(): close())

func _meter(node_name: String, rect: Rect2, color: Color) -> void:
	var meter := ProgressBar.new()
	meter.name = node_name
	meter.position = rect.position
	meter.size = rect.size
	meter.max_value = 1.0
	meter.show_percentage = false
	meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color("283b34")
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	meter.add_theme_stylebox_override("background", background)
	meter.add_theme_stylebox_override("fill", fill)
	add_child(meter)
	meter.size = rect.size

func open(model: TrainingEncounter, identity: CharacterSession) -> void:
	close()
	encounter = model
	character = identity
	stage.race_id = identity.race_id
	encounter.combat_event.connect(stage.present)
	refresh()

func close() -> void:
	if encounter != null and encounter.combat_event.is_connected(stage.present):
		encounter.combat_event.disconnect(stage.present)
	encounter = null
	if stage != null:
		stage.clear_effects()

func _exit_tree() -> void:
	close()

func refresh() -> void:
	if encounter == null:
		return
	bars.update_values(encounter.stats)
	$Identity.text = "%s / %s" % [character.character_name, ClassCatalog.display_name(character.class_id)]
	$Enemy.text = "Construct HP %d / %d" % [encounter.enemy_health, TrainingEncounter.ENEMY_MAX_HEALTH]
	$EnemyBar.value = float(encounter.enemy_health) / TrainingEncounter.ENEMY_MAX_HEALTH
	$Log.text = "\n".join(encounter.messages.slice(maxi(0, encounter.messages.size() - 2)))
	$Start.disabled = encounter.state == &"active"
	$Start.text = "Training" if encounter.state == &"active" else "Start (Enter)"
	$HeavyStrike.disabled = not encounter.skill_available(&"heavy_strike")
	$Spark.disabled = not encounter.skill_available(&"spark")
	$MeleeMeter.value = 1.0 - encounter.until_round / TrainingEncounter.ROUND_SECONDS if encounter.state == &"active" else 0.0
	$LagMeter.value = encounter.lag_remaining / 2.0
	$LagTiming.text = "Skill lag: %.1fs" % encounter.lag_remaining
	if encounter.state == &"active":
		$Timing.text = "Next melee: %.1fs  /  Round %d" % [encounter.until_round, encounter.rounds]
		$Outcome.text = "Skills do not interrupt melee."
	else:
		$Timing.text = "Resources recovering"
		var outcomes := {&"ready": "Ready — start when you want.", &"victory": "Victory! Start again or leave.", &"defeat": "Training ended safely at 1 HP.", &"withdrawn": "Withdrawn — rest to recover."}
		$Outcome.text = outcomes.get(encounter.state, "")

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
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(label)
	label.size = rect.size

func _button(node_name: String, text: String, rect: Rect2, action: Callable) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.add_theme_font_size_override("font_size", 12)
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)
	button.size = rect.size