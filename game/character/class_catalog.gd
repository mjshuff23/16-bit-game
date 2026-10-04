class_name ClassCatalog
extends RefCounted
## Familiar archetypes with original flavor text; mechanics come later.

const CLASSES: Dictionary[StringName, Dictionary] = {
	&"barbarian": {"name": "Barbarian", "description": "Meet danger with raw strength and fierce resolve."},
	&"bard": {"name": "Bard", "description": "Shape the moment through music, stories, and wit."},
	&"cleric": {"name": "Cleric", "description": "Channel sacred power through devotion and conviction."},
	&"druid": {"name": "Druid", "description": "Follow the wild and the changing rhythms of nature."},
	&"fighter": {"name": "Fighter", "description": "Master weapons through discipline and experience."},
	&"monk": {"name": "Monk", "description": "Hone body and spirit into a single focused force."},
	&"paladin": {"name": "Paladin", "description": "Carry an oath into battle and stand by your word."},
	&"ranger": {"name": "Ranger", "description": "Read the wilderness and track what others overlook."},
	&"rogue": {"name": "Rogue", "description": "Find an opening through stealth, skill, and cunning."},
	&"sorcerer": {"name": "Sorcerer", "description": "Draw on magic that wells up from within you."},
	&"warlock": {"name": "Warlock", "description": "Wield power gained through an otherworldly pact."},
	&"wizard": {"name": "Wizard", "description": "Unravel magic through study and experimentation."},
}

static func contains(id: StringName) -> bool:
	return CLASSES.has(id)

static func display_name(id: StringName) -> String:
	return str(CLASSES.get(id, {}).get("name", ""))

static func description(id: StringName) -> String:
	return str(CLASSES.get(id, {}).get("description", ""))
