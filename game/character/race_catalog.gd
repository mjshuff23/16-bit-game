class_name RaceCatalog
extends RefCounted
## Caps are training ceilings, not initial values or class bonuses.
## Mazoku retains the source's equal caps by explicit user choice.
const RACES: Dictionary[StringName, Dictionary] = {
	&"saiyan": {"name": "Saiyan", "description": "Power, Strength, Speed, Aegis.", "caps": {&"body": 100, &"mind": 75, &"willpower": 80, &"spirit": 90}},
	&"patryn": {"name": "Patryn", "description": "Rune affinity and living tattoos.", "caps": {&"body": 80, &"mind": 100, &"willpower": 85, &"spirit": 75}},
	&"mazoku": {"name": "Mazoku", "description": "Astral nature and changing forms.", "caps": {&"body": 95, &"mind": 95, &"willpower": 95, &"spirit": 95}},
	&"fist": {"name": "Fist", "description": "Martial body, ki, and precise strikes.", "caps": {&"body": 90, &"mind": 75, &"willpower": 80, &"spirit": 100}},
	&"witch_warlock": {"name": "Witch / Warlock", "description": "Innate magical aptitude and willpower.", "caps": {&"body": 75, &"mind": 90, &"willpower": 100, &"spirit": 80}},
}

static func contains(id: StringName) -> bool:
	return RACES.has(id)

static func display_name(id: StringName) -> String:
	return str(RACES.get(id, {}).get("name", ""))

static func attribute_cap(id: StringName, attribute: StringName) -> int:
	return int(RACES.get(id, {}).get("caps", {}).get(attribute, 0))
