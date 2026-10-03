extends Node

export(int) var dmg = 1 setget setdmg, getdmg
export(int) var deathdmg = 3 setget setdeathdmg, getdeathdmg

func setdmg(value):
	dmg = value

func getdmg():
	return dmg
	
func setdeathdmg(value):
	deathdmg = value

func getdeathdmg():
	return deathdmg
