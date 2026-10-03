extends Area2D

signal collected

export var jumpBoostDuration: float = 8
export var jumpHeight: float = 1.4

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node) -> void:
	if not (body is KinematicBody2D):
		return

	emit_signal("collected")
	visible = false
	set_deferred("monitoring", false)
	
	var baseJumpHeight = body.jump_force

	body.jump_force = baseJumpHeight * jumpHeight

	yield(get_tree().create_timer(jumpBoostDuration), "timeout")

	if is_instance_valid(body):
		body.jump_force = baseJumpHeight

	queue_free()
