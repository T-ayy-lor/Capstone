extends Area2D

signal entered

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node) -> void:
	if not (body is KinematicBody2D):
		return
	emit_signal("entered")
