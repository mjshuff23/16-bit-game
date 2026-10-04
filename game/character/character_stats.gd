class_name CharacterStats
extends RefCounted
## Shared starting values from Static Chaos. Combat formulas are not implemented.
## Move is a resource pool, distinct from the player's overworld movement speed.

var body: int = 10
var mind: int = 10
var spirit: int = 10
var willpower: int = 10
var max_health: int = 2000
var health: int = 2000
var max_mana: int = 1000
var mana: int = 1000
var max_move_points: int = 1000
var move_points: int = 1000
var primal: int = 0
var hitroll: int = 0
var damroll: int = 0
var armor: int = 100
