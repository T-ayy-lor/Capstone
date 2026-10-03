extends Node

signal maxhpChange(diff)
signal hpChange(diff)
signal healthEmpty

export(int) var maxhp = 3
export(int) var health = maxhp

func losehp(dmg):
	health -=dmg

	emit_signal("hpChange", -dmg)
	
	if health <= 0:
		health = 0
		emit_signal("healthEmpty")

func instaDeath(deathdmg):
	health = 0
	emit_signal("healthEmpty")
