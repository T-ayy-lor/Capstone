extends Area2D

signal collected

export var respawn_time: float = 20.0

# Idle spin: hold frame 0 for a random pause, then run the remaining
# frames quickly before pausing again.
export var hold_time_min: float = 3.0
export var hold_time_max: float = 6.0
export var spin_frame_time: float = 0.1

export var bob_amplitude: float = 1.0
export var bob_speed: float = 0.4

var _timer: float = 0.0
var _base_y: float = 0.0
var _bob_time: float = 0.0

onready var _sprite: AnimatedSprite = $Coin

func _ready() -> void:
	randomize()
	connect("body_entered", self, "_on_body_entered")
	_sprite.playing = false
	_sprite.frame = 0
	_base_y = _sprite.position.y
	_bob_time = rand_range(0.0, 10.0)
	_timer = rand_range(hold_time_min, hold_time_max)

func _process(delta: float) -> void:
	_bob_time += delta
	_sprite.position.y = _base_y + round(
		sin(_bob_time * bob_speed * PI * 2.0) * bob_amplitude)

	_timer -= delta
	if _timer <= 0.0:
		var count: int = _sprite.frames.get_frame_count(_sprite.animation)
		_sprite.frame = (_sprite.frame + 1) % count
		_timer = rand_range(hold_time_min, hold_time_max) if _sprite.frame == 0 else spin_frame_time

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
