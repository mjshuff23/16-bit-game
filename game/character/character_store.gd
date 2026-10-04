class_name CharacterStore
extends RefCounted
## Version 1 persists identity and temple class choice. No world/combat save yet.
var path: String
var profiles: Array[Dictionary] = []
var error_message: String = ""
var _writable := true

func _init(save_path: String = "user://characters.json") -> void:
	path = save_path

func load_profiles() -> bool:
	error_message = ""
	_writable = true
	if not FileAccess.file_exists(path):
		profiles = []
		return true
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1048576:
		return _reject("Cannot read character file. Existing data kept.")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or parsed.get("version") != 1 or not parsed.get("profiles") is Array:
		return _reject("Unsupported character file. Existing data kept.")
	var validated: Array[Dictionary] = []
	var ids: Dictionary = {}
	for record: Variant in parsed.profiles:
		if not _valid_record(record) or ids.has(record.id):
			return _reject("Invalid character file. Existing data kept.")
		ids[record.id] = true
		validated.append(record.duplicate())
	profiles = validated
	return true

func _reject(message: String) -> bool:
	error_message = message
	_writable = false
	return false

func can_save() -> bool:
	return _writable

func save_profile(character: CharacterSession) -> bool:
	if not _writable:
		return false
	var record := {"id": character.character_id, "name": character.character_name,
		"race": String(character.race_id), "class": String(character.class_id)}
	if not _valid_record(record):
		error_message = "Character is incomplete. Choose a name and race."
		return false
	var updated: Array[Dictionary] = profiles.duplicate(true)
	var found := false
	for index in updated.size():
		if updated[index].id == record.id:
			updated[index] = record
			found = true
			break
	if not found:
		updated.append(record)
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		error_message = "Cannot save character. Check folder access."
		return false
	file.store_string(JSON.stringify({"version": 1, "profiles": updated}, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or DirAccess.rename_absolute(path + ".tmp", path) != OK:
		error_message = "Could not finish saving. Previous data kept."
		return false
	profiles = updated
	error_message = ""
	return true

func restore(id: String) -> CharacterSession:
	for record in profiles:
		if record.id == id:
			var character := CharacterSession.new()
			character.character_id = record.id
			character.character_name = record.name
			character.race_id = StringName(record.race)
			character.class_id = StringName(record["class"])
			return character
	return null

func _valid_record(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	for key in ["id", "name", "race", "class"]:
		if not value.get(key) is String:
			return false
	return (not value.id.is_empty() and value.id.length() <= 64
		and CharacterSession.valid_name(value.name)
		and RaceCatalog.contains(StringName(value.race))
		and (value["class"] == "" or ClassCatalog.contains(StringName(value["class"]))))
