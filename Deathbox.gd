extends Area2D

signal inArea
signal dmgReceived(dmg)

export(NodePath) var hp

func _ready():
	connect("deathAreaEntered", self, "deathArea")

func deathArea(hitbox):
	if hitbox != null:
		var health = get_node(hp)
		print("BEFORE HP: ", health.health)
		health.instaDeath(hitbox.dmg)  
		print("AFTER HP: ", health.health)
