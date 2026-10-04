extends Node

var session := CharacterSession.new()
var save_path := "user://characters.json"
var store: CharacterStore
var encounter: TrainingEncounter
var world_bars: ResourceBars

@onready var training: Control = $Interface/Training
@onready var summary: Control = $Interface/CharacterSummary
@onready var temple: Node2D = $Temple
@onready var picker: Control = $Interface/ClassPicker
@onready var characters: Control = $Interface/CharacterScreen

func _ready() -> void:
	world_bars = ResourceBars.new()
	world_bars.position = Vector2(16, 34)
	temple.get_node("HUD").add_child(world_bars)
	training.leave_requested.connect(_leave_training)
	temple.training_requested.connect(_open_training)
	store = CharacterStore.new(save_path)
	store.load_profiles()
	characters.store = store
	characters.character_selected.connect(_enter_world)
	picker.class_confirmed.connect(_complete_path)
	picker.selection_cancelled.connect(_cancel_choice)
	temple.class_selection_requested.connect(_open_choice)
	temple.characters_requested.connect(return_to_characters)
	return_to_characters()

func return_to_characters() -> void:
	if encounter != null:
		encounter.withdraw()
	encounter = null
	_set_screen(training, false)
	summary.hide()
	temple.close_inspection()
	_set_screen(temple, false)
	_set_screen(picker, false)
	_set_screen(characters, true)
	characters.refresh()

func _enter_world(character: CharacterSession) -> void:
	encounter = null
	session = character
	picker.session = session
	_set_screen(characters, false)
	_close_choice()
	temple.start(session.class_id)
	temple.get_node("HUD/Header/Location").text = "%s / %s" % [session.character_name, RaceCatalog.display_name(session.race_id)]

func _set_screen(screen: CanvasItem, active: bool) -> void:
	screen.visible = active
	screen.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

func _close_choice() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null:
		focused.release_focus()
	_set_screen(picker, false)
	_set_screen(temple, true)

func _complete_path(class_id: StringName) -> void:
	if not store.save_profile(session):
		session.class_id = &""
		picker.reset_selection()
		picker.get_node("Description").text = store.error_message
		return
	temple.set_class(class_id)
	_close_choice()

func _cancel_choice() -> void:
	picker.session.pending_class_id = &""
	_close_choice()

func _open_choice() -> void:
	summary.hide()
	if picker.session.class_id != &"":
		return
	_set_screen(temple, false)
	_set_screen(picker, true)
	picker.reset_selection()
func _input(event: InputEvent) -> void:
	if (not temple.visible and not training.visible) or characters.visible or picker.visible:
		return
	if event.is_action_pressed("character_summary"):
		get_viewport().set_input_as_handled()
		if event.is_echo() or (temple.visible and temple.inspection_open):
			return
		if summary.visible:
			summary.hide()
		else:
			summary.show_character(session)
	elif summary.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not event.is_echo():
			summary.hide()
	elif summary.visible and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
		summary.hide()


func _process(delta: float) -> void:
	if session.character_id.is_empty() or characters.visible:
		return
	if encounter != null:
		encounter.advance(delta)
	else:
		session.stats.recover(delta)
	world_bars.update_values(session.stats)
	if training.visible:
		training.refresh()
	if summary.visible:
		summary.show_character(session)

func _open_training() -> void:
	if session.class_id == &"":
		return
	summary.hide()
	encounter = TrainingEncounter.new(session.stats)
	_set_screen(temple, false)
	_set_screen(training, true)
	training.open(encounter)

func _leave_training() -> void:
	if encounter != null:
		encounter.withdraw()
	summary.hide()
	_set_screen(training, false)
	_set_screen(temple, true)
