extends Area2D

signal collected

export var respawn_time: float = 20.0


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	if not (body is KinematicBody2D):
		return

	emit_signal("collected")
	visible = false
	set_deferred("monitoring", false)
	get_tree().create_timer(respawn_time).connect("timeout", self, "_respawn")


func _respawn() -> void:
	visible = true
	monitoring = true
