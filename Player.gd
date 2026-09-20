extends KinematicBody2D

# -----------------------------------------------------------
# PLAYER MOVEMENTS SETTINGS
# THESE values are shown in the INSPECTOR because of export"
# You can change them there without editing the code
# -----------------------------------------------------------

#Horizontal movement speed in pixles per sec.
export var speed: float = 60.0

# Strength of the upward jump
# Code uses "jump_force" because negative Y moves upward in 2D Godot.
export var jump_force: float = 220.0

# Downward acceleration top every physics frame.
export var gravity: float = 700.0

# ------------------------------------------------------------
# BIOME BASE VALUES
# These store the original/default player movement values.
# We need them so the player can return to normal after leaving
# a biome or can receive a different biome's effect.
# ------------------------------------------------------------

var base_speed: float
var base_jump_force: float
var base_gravity: float

# ------------------------------------------------------------
# PLAYER STATE VARIABLES
# ------------------------------------------------------------

# Velocity stores player movement:
# velocity.x = left/right movement
# velocity.y = upward/downward movement
var velocity: Vector2 = Vector2.ZERO

# Gets the AnimatedSprite child node from Player.tscn.
# This is used to play the idle and walk animations.
onready var sprite: AnimatedSprite = $AnimatedSprite

# ------------------------------------------------------------
# PHYSICS PROCESS
# Runs at a fixed physics rate.
# Player movement, gravity, jumping, and collision belong here.
# ------------------------------------------------------------

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
