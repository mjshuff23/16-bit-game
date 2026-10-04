class_name CharacterStats
extends RefCounted
## Shared starting values from Static Chaos. Vigor is its former Move pool.
## Walking is free. Recovery is applied only outside active training.

var body: int = 10
var mind: int = 10
var spirit: int = 10
var willpower: int = 10
var max_health: int = 2000
var health: int = 2000
var max_mana: int = 1000
var mana: int = 1000
var max_vigor: int = 1000
var vigor: int = 1000
var primal: int = 0
var hitroll: int = 0
var damroll: int = 0
var armor: int = 100

var _recovery := Vector3.ZERO

func recover(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	health = _recover_pool(health, max_health, delta, 0)
	mana = _recover_pool(mana, max_mana, delta, 1)
	vigor = _recover_pool(vigor, max_vigor, delta, 2)

func _recover_pool(current: int, maximum: int, delta: float, index: int) -> int:
	_recovery[index] += maximum * 0.1 * delta
	var whole := int(floor(_recovery[index] + 0.00001))
	_recovery[index] -= whole
	var recovered := mini(maximum, current + whole)
	if recovered >= maximum:
		_recovery[index] = 0.0
	return recovered
