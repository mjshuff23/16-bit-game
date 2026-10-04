extends Control

signal class_confirmed(class_id: StringName)
signal selection_cancelled

var session := CharacterSession.new()

@onready var classes: GridContainer = $Classes
@onready var description: Label = $Description
@onready var confirm: Button = $Confirm

func _ready() -> void:
	var group := ButtonGroup.new()
	for id: StringName in ClassCatalog.CLASSES:
		var button := Button.new()
		button.name = String(id)
		button.text = ClassCatalog.display_name(id)
		button.custom_minimum_size = Vector2(184, 36)
		button.toggle_mode = true
		button.button_group = group
		button.pressed.connect(_preview.bind(id))
		classes.add_child(button)
	confirm.pressed.connect(_confirm_choice)
	$Cancel.pressed.connect(func() -> void: selection_cancelled.emit())
	classes.get_child(0).grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		selection_cancelled.emit()
		get_viewport().set_input_as_handled()

func _preview(id: StringName) -> void:
	if not session.preview_class(id):
		return
	description.text = "%s: %s" % [ClassCatalog.display_name(id), ClassCatalog.description(id)]
	confirm.text = "Confirm %s" % ClassCatalog.display_name(id)
	confirm.disabled = false

func _confirm_choice() -> void:
	if session.class_id != &"":
		return
	elif session.confirm_class():
		description.text = "You have chosen %s.\nYour story starts here." % ClassCatalog.display_name(session.class_id)
		confirm.text = "Path chosen"
		confirm.disabled = true
		for button: Button in classes.get_children():
			button.disabled = true
		class_confirmed.emit(session.class_id)

func reset_selection() -> void:
	if session.class_id != &"":
		return
	session.pending_class_id = &""
	description.text = "Select a class to learn about it."
	confirm.text = "Choose a class"
	confirm.disabled = true
	for button: Button in classes.get_children():
		button.disabled = false
		button.set_pressed_no_signal(false)
	classes.get_child(0).grab_focus()
