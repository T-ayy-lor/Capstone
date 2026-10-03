extends Area2D

signal collected

export var boost_duration: float = 10

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node) -> void:
	if not (body is KinematicBody2D):
		return

	emit_signal("collected")
	visible = false
	set_deferred("monitoring", false)

	body.gravitySlowed = true

	yield(get_tree().create_timer(boost_duration), "timeout")

	if is_instance_valid(body):
		body.gravitySlowed = false

	queue_free()
