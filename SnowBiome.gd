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

# Applys snow effect entering snow or going backwards to snow from cave
func apply_effect_to_player(player) -> void:
	player.apply_biome_effect(
		biome_name,
		speed_multiplier,
		jump_multiplier,
		gravity_multiplier,
		effect_description
	)

# PLAYER ENTERS SNOW
func _on_body_entered(body) -> void:
	if body.name == "Player":
		# Apply Snow effect whenever Player enters SnowBiome.
		apply_effect_to_player(body)

# PLAYER LEAVES SNOW
func _on_body_exited(body) -> void:
	if body.name == "Player":
		# Only reset to Desert if Player is not also in CaveBiome.
		# This prevents Snow's exit from overriding Cave when moving
		# forward from Snow to Cave.
		var cave_biome: Area2D = get_parent().get_node("CaveBiome")

		if not cave_biome.overlaps_body(body):
			body.reset_biome_effects()
