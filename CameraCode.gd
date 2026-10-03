extends Camera2D

export var camSpeed: float = 60.0
export var camBoosted: float = 2.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
	
func _process(delta):
	var baseSpeed = camSpeed
	position.x += baseSpeed * delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
