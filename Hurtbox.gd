extends Area2D

signal inArea
signal dmgReceived(dmg)

export(NodePath) var hp

func _ready():
	connect("area_entered", self, "insideArea")

func insideArea(hitbox):
	if hitbox != null:
		var health = get_node(hp)
		print("BEFORE HP: ", health.health)
		health.losehp(hitbox.dmg)
		print("AFTER HP: ", health.health)
