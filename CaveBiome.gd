extends Area2D

# -----------------------------------------------------------
# CAVE BIOME SETTINGS
# The cave reduces visibility and slightly slows the player.
# -----------------------------------------------------------
# Name displayed in HUD
export(String) var biome_name = "Cave"

# Cave is slightly slower due to uneven ground/darkness.
export(float) var speed_multiplier = 0.90
export(float) var jump_multiplier = 1.0
export(float) var gravity_multiplier = 1.0

export(String) var effect_description = "Darkness: limited visibility"

# READY
func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

# PLAYER ENTERS CAVE
func _on_body_entered(body) -> void:
	if body.name == "Player":
		body.apply_biome_effect(
			biome_name,
			speed_multiplier,
			jump_multiplier,
			gravity_multiplier,
			effect_description
		)

		# Tell Main to turn on the darkness overlay.
		get_parent().set_cave_darkness(true)

# PLAYER LEAVES CAVE
func _on_body_exited(body) -> void:
	if body.name == "Player":
		# Restore normal movement only when leaving the cave.
		body.reset_biome_effects()

		# Turn the visibility effect off after leaving cave.
		get_parent().set_cave_darkness(false)
