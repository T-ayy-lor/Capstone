extends KinematicBody2D

# -----------------------------------------------------------
# PLAYER MOVEMENTS SETTINGS
# "export" makes these editable in the Godot Inspector.
# You can change them there without editing the code
# -----------------------------------------------------------

#Horizontal movement speed in pixles per sec.
export var speed: float = 60.0

# Normal jump strength.
# The player jumps upward by setting velocity.y to -jump_force.
export var jump_force: float = 220.0

# Downward force added while player is in the air.
export var gravity: float = 700.0


# ------------------------------------------------------------
# BASE VALUES
# These save the original player settings when the game starts.
# Biomes use these values as their starting point
# ------------------------------------------------------------

var base_speed: float
var base_jump_force: float
var base_gravity: float

# ------------------------------------------------------------
# PLAYER STATE VARIABLES
# ------------------------------------------------------------

# Stores horizontal and vertical movement.
# velocity.x = left/right movement
# velocity.y = falling/jumping movement
var velocity: Vector2 = Vector2.ZERO

# Gets the AnimatedSprite child node from Player.tscn.
onready var sprite: AnimatedSprite = $AnimatedSprite

# ------------------------------------------------------------
# READY
# Runs once the Player is added to the Main scene.
# ------------------------------------------------------------

func _ready() -> void:
	# save def vals when the Player is added to the Main scene.
	base_speed = speed
	base_jump_force = jump_force
	base_gravity = gravity


# ------------------------------------------------------------
# PHYSICS PROCESS
# Runs on Godot's fixed physics update.
# ------------------------------------------------------------

func _physics_process(delta: float) -> void:
		# direction:
	# -1 = player holding left
	#  0 = player not moving horizontally
	#  1 = player holding right
	var direction: float = 0.0
	# Move right for move_right input pressed
	if Input.is_action_pressed("move_right"):
		direction += 1.0
		# Move left for move_left input pressed
	if Input.is_action_pressed("move_left"):
		direction -= 1.0
	
	# Horizontal movement
	velocity.x = direction * speed
	# Apply gravity every physics frame.
	# Positive Y means downward in Godot 2D.
	velocity.y += gravity * delta

	# Allow a jump only while standing on the floor.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force

	# Move the player and detect collisions with Ground/Platforms/Walls.
	# Vector2.UP tells Godot which direction should count as a floor.
	velocity = move_and_slide(velocity, Vector2.UP)

	# Update the idle/walk animation after movement is calculated.
	_update_animation(direction)


# -----------------------------------------------------------
# PLAYER ANIMATION
# -----------------------------------------------------------


func _update_animation(direction: float) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	var next_anim: String = "idle"
	
	if direction != 0.0:
		next_anim = "walk"

	if sprite.animation != next_anim:
		sprite.play(next_anim)
	
# -----------------------------------------------------------
# BIOME EFFECT FUCT
# SnowBiome.gd and CaveBiome.gd call apply apply_biome_effect().
# -----------------------------------------------------------

func apply_biome_effect(
	biome_name: String,
	speed_multiplier: float,
	jump_multiplier: float,
	gravity_multiplier: float,
	effect_description: String
) -> void:
	# Apply changes from original player values.
	# Example snow speed:
	# base_speed 60 × 1.15 = 69.
	speed = base_speed * speed_multiplier

	# Example snow jump:
	# base_jump_force 220 × 0.75 = 165, so jump is weaker.
	jump_force = base_jump_force * jump_multiplier

	# Example space gravity could use 0.35 for floaty jumping.
	gravity = base_gravity * gravity_multiplier

	# Ask Main.gd to update score/biome/effect text on the HUD.
	# Player is a direct child of Main.
	get_parent().set_biome_hud(biome_name, effect_description)

	# Print results in Godot's Output panel for debugging.
	print("Entered biome: ", biome_name)
	print("Effect: ", effect_description)
	print("Speed: ", speed)
	print("Jump force: ", jump_force)
	print("Gravity: ", gravity)


func reset_biome_effects() -> void:
	# Restore the default Desert movement values.
	speed = base_speed
	jump_force = base_jump_force
	gravity = base_gravity

	# Reset visible HUD text to default Desert information.
	get_parent().set_biome_hud("Desert", "Normal movement")

	print("Returned to Desert / normal movement")
