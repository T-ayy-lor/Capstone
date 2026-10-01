tool
extends PathFollow2D

# Laps per second. Negative reverses direction.
export var speed: float = 0.35


func _process(delta: float) -> void:
	unit_offset = fmod(unit_offset + speed * delta, 1.0)
