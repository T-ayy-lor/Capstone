extends KinematicBody2D

export var speed: float = 60.0
export var jump_force: float = 220.0
export var gravity: float = 700.0

# Surfaces steeper than this become walls instead of floors.
# Hand-authored terrain uses 45-degree ramps for each 1px step, so 50
# clears them with room to spare while still walling off real cliffs.
export var max_slope_degrees: float = 50.0

# How far below the feet to search for ground while walking, so the
# player stays attached on descents instead of launching off each dip.
export var snap_length: float = 8.0

# How long the landing pose holds before idle or walk resumes.
export var land_time: float = 0.12

var velocity: Vector2 = Vector2.ZERO

var _was_on_floor: bool = true
var _land_timer: float = 0.0

onready var sprite: AnimatedSprite = $AnimatedSprite


func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("move_right"):
		direction += 1.0
	if Input.is_action_pressed("move_left"):
		direction -= 1.0

	velocity.x = direction * speed
	velocity.y += gravity * delta

	var jumping: bool = false
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
		jumping = true

	# Snap must be cleared on the jump frame, or the snap search drags
	# the player straight back down to the floor.
	var snap: Vector2 = Vector2.DOWN * snap_length
	if jumping:
		snap = Vector2.ZERO

	velocity = move_and_slide_with_snap(
		velocity,
		snap,
		Vector2.UP,
		true,
		4,
		deg2rad(max_slope_degrees)
	)

	# Touchdown frame: airborne last frame, grounded this one.
	var on_floor: bool = is_on_floor()
	if on_floor and not _was_on_floor:
		_land_timer = land_time
	_was_on_floor = on_floor

	if _land_timer > 0.0:
		_land_timer -= delta

	_update_animation(direction, on_floor)


func _update_animation(direction: float, on_floor: bool) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	var next_anim: String
	if not on_floor:
		next_anim = "jump"
	elif _land_timer > 0.0:
		next_anim = "land"
	elif direction != 0.0:
		next_anim = "walk"
	else:
		next_anim = "idle"

	if sprite.animation != next_anim:
		sprite.play(next_anim)
