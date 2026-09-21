extends Node2D

var score: int = 0

onready var score_label: Label = $HUD/ScoreLabel

onready var cave_darkness: ColorRect = $WorldDarknessLayer/CaveDarkness

var current_biome: String = "Desert"
var current_effect: String = "Normal movement"



# READY
func _ready() -> void:
	# Connect every existing coin's "collected" signal.
	# Coins must be direct children of the Coins node.
	for coin in $Coins.get_children():
		coin.connect("collected", self, "_on_coin_collected")

	# Begin game with normal visibility.
	cave_darkness.visible = false

	# Display score and starting Desert biome information.
	update_hud()
	
	
# HUD UPDATE
# This is the ONLY function that should change ScoreLabel.text.
func update_hud() -> void:
	score_label.text = (
	"Score: " + str(score) + "\n"
	+ "Biome: " + current_biome + "\n"
	+ "Effect: " + current_effect
	)
	
# BIOME HUD UPDATE
# Called by SnowBiome.gd and CaveBiome.gd.
func set_biome_hud(biome_name: String, effect_description: String) -> void:
	# Save the current biome display text.
	current_biome = biome_name
	current_effect = effect_description

	# Update the ScoreLabel without changing the score.
	update_hud()
	
# CAVE DARKNESS
# Called by CaveBiome.gd when the Player enters/leaves the cave.
func set_cave_darkness(is_in_cave: bool) -> void:
	# true = show dark overlay
	# false = hide dark overlay
	cave_darkness.visible = is_in_cave
