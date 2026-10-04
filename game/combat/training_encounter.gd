class_name TrainingEncounter
extends RefCounted
signal combat_event(event: Dictionary)
## Pure timed simulation. The UI advances time and sends commands; it owns no rules.
const ROUND_SECONDS := 3.0
const ENEMY_MAX_HEALTH := 600
const SKILLS: Dictionary[StringName, Dictionary] = {
	&"heavy_strike": {"name": "Heavy Strike", "vigor": 80, "mana": 0, "lag": 1.5},
	&"spark": {"name": "Spark", "vigor": 0, "mana": 100, "lag": 2.0},
}
var stats: CharacterStats
var state: StringName = &"ready"
var enemy_health := ENEMY_MAX_HEALTH
var until_round := ROUND_SECONDS
var lag_remaining := 0.0
var rounds := 0
var messages: Array[String] = ["Ready. Start when you want to practice."]
var _rng := RandomNumberGenerator.new()

func _init(character_stats: CharacterStats, seed_value: int = -1) -> void:
	stats = character_stats
	if seed_value < 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value

func start() -> bool:
	if state == &"active":
		return false
	state = &"active"
	enemy_health = ENEMY_MAX_HEALTH
	until_round = ROUND_SECONDS
	lag_remaining = 0.0
	rounds = 0
	messages.clear()
	_note("Training started. Automatic melee every 3 seconds.")
	_event(&"started")
	return true

func advance(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	var remaining := delta
	while state == &"active" and remaining > 0.0:
		var step := minf(remaining, until_round)
		lag_remaining = maxf(0.0, lag_remaining - step)
		until_round -= step
		remaining -= step
		if until_round <= 0.000001:
			until_round = ROUND_SECONDS
			_resolve_round()
	if state != &"active" and remaining > 0.0:
		stats.recover(remaining)

func skill_available(id: StringName) -> bool:
	if state != &"active" or lag_remaining > 0.000001 or not SKILLS.has(id):
		return false
	var skill: Dictionary = SKILLS[id]
	return stats.mana >= skill.mana and stats.vigor >= skill.vigor

func use_skill(id: StringName) -> bool:
	if not skill_available(id):
		if state == &"active":
			_note("Not ready: check action lag and resource costs.")
		return false
	var skill: Dictionary = SKILLS[id]
	stats.mana -= int(skill.mana)
	stats.vigor -= int(skill.vigor)
	lag_remaining = float(skill.lag)
	var damage := 120 + (2 * stats.body if id == &"heavy_strike" else 4 * stats.willpower)
	var dealt := mini(damage, enemy_health)
	_damage_enemy(damage)
	_event(&"hit", &"player", &"enemy", dealt, id)
	_note("%s deals %d damage." % [skill.name, damage])
	if enemy_health == 0:
		_finish(&"victory", "Victory! Rest here or leave to recover.")
	return true

func hit_chance() -> int:
	return clampi(75 + stats.hitroll, 5, 95)

func melee_damage() -> int:
	return maxi(1, 80 + 2 * stats.body + stats.damroll)

func withdraw() -> void:
	if state == &"active":
		_finish(&"withdrawn", "Training stopped. Resources recover outside combat.")

func _resolve_round() -> void:
	rounds += 1
	if _rng.randi_range(1, 100) <= hit_chance():
		var damage := melee_damage()
		var dealt := mini(damage, enemy_health)
		_damage_enemy(damage)
		_event(&"hit", &"player", &"enemy", dealt)
		_note("Round %d: your melee hits for %d." % [rounds, damage])
	else:
		_note("Round %d: your melee misses." % rounds)
		_event(&"miss", &"player", &"enemy")
	if enemy_health == 0:
		_finish(&"victory", "Victory! Rest here or leave to recover.")
		return
	if _rng.randi_range(1, 100) <= 65:
		var dealt := maxi(0, mini(90, stats.health - 1))
		if stats.health <= 90:
			stats.health = 1
			_event(&"hit", &"enemy", &"player", dealt)
			_finish(&"defeat", "Training ends safely at 1 Health. Rest to recover.")
		else:
			stats.health -= 90
			_event(&"hit", &"enemy", &"player", dealt)
			_note("The practice opponent hits for 90.")
	else:
		_note("The practice opponent misses.")
		_event(&"miss", &"enemy", &"player")

func _damage_enemy(amount: int) -> void:
	enemy_health = maxi(0, enemy_health - maxi(0, amount))

func _finish(outcome: StringName, message: String) -> void:
	state = outcome
	lag_remaining = 0.0
	_note(message)
	_event(&"finished", &"", &"", 0, &"", outcome)

func _note(message: String) -> void:
	messages.append(message)
	while messages.size() > 4:
		messages.pop_front()
func _event(kind: StringName, actor: StringName = &"", target: StringName = &"", damage: int = 0, skill: StringName = &"", outcome: StringName = &"") -> void:
	combat_event.emit({"kind": kind, "actor": actor, "target": target, "damage": damage, "skill": skill, "outcome": outcome})
