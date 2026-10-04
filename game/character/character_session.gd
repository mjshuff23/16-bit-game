class_name CharacterSession
extends RefCounted
## Identity and class are independent; class is earned at the temple.

var character_id: String = ""
var character_name: String = ""
var race_id: StringName = &""

var class_id: StringName = &""
var pending_class_id: StringName = &""
var stats := CharacterStats.new()

func preview_class(id: StringName) -> bool:
	if class_id != &"" or not ClassCatalog.contains(id):
		return false
	pending_class_id = id
	return true

func confirm_class() -> bool:
	if class_id != &"" or not ClassCatalog.contains(pending_class_id):
		return false
	class_id = pending_class_id
	return true

func reset() -> void:
	character_id = ""
	character_name = ""
	race_id = &""
	class_id = &""
	pending_class_id = &""
	stats = CharacterStats.new()

static func valid_name(value: String) -> bool:
	if value != value.strip_edges() or value.is_empty() or value.length() > 18:
		return false
	for index in value.length():
		if value.unicode_at(index) < 32 or value.unicode_at(index) == 127:
			return false
	return true

func create_identity(value: String, race: StringName) -> bool:
	var clean := value.strip_edges()
	if not character_id.is_empty() or not valid_name(clean) or not RaceCatalog.contains(race):
		return false
	character_id = Crypto.new().generate_random_bytes(16).hex_encode()
	character_name = clean
	race_id = race
	return true

func attribute_cap(attribute: StringName) -> int:
	return RaceCatalog.attribute_cap(race_id, attribute)