extends Area2D

# -----------------------------------------------
# Snow Biome Settings 
# These values appear in inspector
# -----------------------------------------------
# Name displayed in HUD 
export(String) var biome_name = "Snow"

# Snow is slightly faster for now.
export(float) var speed_multiplier = 1.15

# Snow gives a weaker jump.
# 0.75 means the jump is 75% of normal strength.
export(float) var jump_multiplier = 0.75
# Keep normal gravity in the Snow biome.
export(float) var gravity_multiplier = 1.0

# Text shown in HUD/ScoreLabel.
export(String) var effect_description = "Icy ground: speed +15%, jump -25%"

# -------------------------------------------------------
# READY
# Connect Area2D signals once the node enters the scene.
# -------------------------------------------------------

func _ready() -> void:
	# Connect Area2D signals through code.
	connect("body_entered", self, "_on_body_entered")
	#when something leaves this Area2D
	connect("body_exited", self, "_on_body_exited")

# PLAYER ENTERS SNOW
func _on_body_entered(body) -> void:
	# Only change effects for the Player node.
	if body.name == "Player":
		body.apply_biome_effect(
			biome_name,
			speed_multiplier,
			jump_multiplier,
			gravity_multiplier,
			effect_description
		)

# PLAYER LEAVES SNOW
func _on_body_exited(body) -> void:
	# Do not reset here yet.
	# When the player leaves snow, they immediately enter cave.
	# The CaveBiome will replace the movement/HUD effect.
	pass
