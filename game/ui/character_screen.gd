extends Control

signal character_selected(character: CharacterSession)
var store: CharacterStore
var selected_race: StringName = &""
var _profile_ids: Array[String] = []

func _ready() -> void:
	# Menus render directly at 640 x 360, independently of the world scale.
	theme = Theme.new()
	theme.default_font_size = 18
	var backdrop := ColorRect.new()
	backdrop.color = Color("0e1916")
	backdrop.size = Vector2(640, 360)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_label(self, "Title", "CHOOSE YOUR CHARACTER", Rect2(24, 10, 592, 44), 28)
	var select := Control.new()
	select.name = "Select"
	add_child(select)
	var choices := OptionButton.new()
	choices.name = "Characters"
	choices.position = Vector2(48, 72)
	choices.size = Vector2(544, 48)
	select.add_child(choices)
	choices.item_selected.connect(func(_index: int) -> void: _show_summary())
	_label(select, "Summary", "", Rect2(48, 136, 544, 130))
	_button(select, "Continue", "Enter forest", Rect2(48, 286, 264, 40), _continue)
	_button(select, "New", "New character", Rect2(328, 286, 264, 40), _show_create)
	var create := Control.new()
	create.name = "Create"
	add_child(create)
	_label(create, "NameLabel", "Name", Rect2(32, 64, 80, 40))
	var name_input := LineEdit.new()
	name_input.name = "Name"
	name_input.position = Vector2(120, 62)
	name_input.size = Vector2(488, 44)
	name_input.max_length = 18
	name_input.placeholder_text = "Your character's name"
	create.add_child(name_input)
	name_input.text_changed.connect(func(_text: String) -> void: _refresh_create())
	var races := GridContainer.new()
	races.columns = 3
	races.name = "Races"
	races.position = Vector2(32, 116)
	races.add_theme_constant_override("h_separation", 12)
	races.add_theme_constant_override("v_separation", 4)
	create.add_child(races)
	var group := ButtonGroup.new()
	for id: StringName in RaceCatalog.RACES:
		var button := Button.new()
		button.name = String(id)
		button.text = RaceCatalog.display_name(id)
		button.custom_minimum_size = Vector2(184, 44)
		button.toggle_mode = true
		button.button_group = group
		button.pressed.connect(func() -> void: selected_race = id; _refresh_create())
		races.add_child(button)
	_label(create, "Details", "Choose your race. Class is learned at the temple.", Rect2(32, 212, 576, 66), 16)
	create.get_node("Details").add_theme_constant_override("line_spacing", 0)
	_button(create, "Begin", "Create & enter", Rect2(32, 286, 352, 40), _create)
	_button(create, "Back", "Back", Rect2(400, 286, 208, 40), refresh)
	_label(self, "Error", "", Rect2(24, 330, 592, 26), 12)

func refresh() -> void:
	$Error.text = store.error_message
	$Select/Characters.clear()
	_profile_ids.clear()
	for record in store.profiles:
		_profile_ids.append(record.id)
		$Select/Characters.add_item("%s — %s" % [record.name, RaceCatalog.display_name(StringName(record.race))])
	if _profile_ids.is_empty():
		_show_create()
	else:
		$Create.hide()
		$Select.show()
		$Select/Characters.select(0)
		_show_summary()
		$Select/Continue.grab_focus()

func _show_create() -> void:
	$Select.hide()
	$Create.show()
	$Create/Back.disabled = store.profiles.is_empty()
	$Create/Name.text = ""
	selected_race = &""
	for button: Button in $Create/Races.get_children():
		button.set_pressed_no_signal(false)
	_refresh_create()
	$Create/Name.grab_focus()

func _refresh_create() -> void:
	$Create/Begin.disabled = not CharacterSession.valid_name($Create/Name.text.strip_edges()) or selected_race == &"" or not store.can_save()
	if selected_race == &"":
		$Create/Details.text = "Choose your race. Class is learned at the temple."
		return
	$Create/Details.text = "%s\nCaps: Body %d  Int %d  Will %d  Spirit %d\nStart: 10 each. XP training planned." % [RaceCatalog.RACES[selected_race].description,
		RaceCatalog.attribute_cap(selected_race, &"body"), RaceCatalog.attribute_cap(selected_race, &"mind"),
		RaceCatalog.attribute_cap(selected_race, &"willpower"), RaceCatalog.attribute_cap(selected_race, &"spirit")]

func _show_summary() -> void:
	var character := store.restore(_profile_ids[$Select/Characters.selected])
	var path_name := ClassCatalog.display_name(character.class_id) if character.class_id != &"" else "Unclassed — visit the temple altar"
	$Select/Summary.text = "%s  /  %s\n%s\nBody %d   Intellect %d   Will %d   Spirit %d\nIdentity and class saved locally." % [character.character_name,
		RaceCatalog.display_name(character.race_id), path_name, character.stats.body, character.stats.mind, character.stats.willpower, character.stats.spirit]

func _create() -> void:
	var character := CharacterSession.new()
	if not character.create_identity($Create/Name.text, selected_race):
		return
	if not store.save_profile(character):
		$Error.text = store.error_message
		return
	character_selected.emit(character)

func _continue() -> void:
	if $Select/Characters.selected >= 0 and not _profile_ids.is_empty():
		character_selected.emit(store.restore(_profile_ids[$Select/Characters.selected]))

func _label(parent: Node, node_name: String, text: String, rect: Rect2, font_size: int = 18) -> void:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)

func _button(parent: Node, node_name: String, text: String, rect: Rect2, action: Callable) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.pressed.connect(action)
	parent.add_child(button)
