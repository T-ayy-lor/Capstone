extends AnimatedSprite

export var hold_time_min: float = 3.0
export var hold_time_max: float = 6.0
export var spin_frame_time: float = 0.1
export var bob_amplitude: float = 1.0
export var bob_speed: float = 0.4

var _timer: float = 0.0
var _base_y: float = 0.0
var _bob_time: float = 0.0


func _ready() -> void:
	randomize()
	playing = false
	frame = 0
	_base_y = position.y
	_bob_time = rand_range(0.0, 10.0)
	_timer = rand_range(hold_time_min, hold_time_max)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = _base_y + round(sin(_bob_time * bob_speed * PI * 2.0) * bob_amplitude)

	_timer -= delta
	if _timer <= 0.0:
		frame = (frame + 1) % frames.get_frame_count(animation)
		_timer = rand_range(hold_time_min, hold_time_max) if frame == 0 else spin_frame_time
