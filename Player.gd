extends KinematicBody2D

export var speed: float = 60.0
export var jump_force: float = 220.0
export var gravity: float = 700.0

var velocity: Vector2 = Vector2.ZERO

onready var sprite: AnimatedSprite = $AnimatedSprite


func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("move_right"):
		direction += 1.0
	if Input.is_action_pressed("move_left"):
		direction -= 1.0

	velocity.x = direction * speed
	velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force

	velocity = move_and_slide(velocity, Vector2.UP)

	_update_animation(direction)


func _update_animation(direction: float) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	var next_anim: String = "idle"
	if direction != 0.0:
		next_anim = "walk"

	if sprite.animation != next_anim:
		sprite.play(next_anim)
