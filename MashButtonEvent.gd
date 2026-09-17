extends Node2D

var jump_count: int = 0
var required_jumps: int = 20
var event_active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Trigger_body_entered(body):
	if body.name == "Player":
		event_active = true
		print ("HE ENTERED THE THINGGGGGGG")

func _process(delta: float) -> void:
	if event_active:
		if Input.is_action_just_pressed("jump"):
			jump_count += 1
			print("Jump presses: ", jump_count);
