extends Node2D

var score: int = 0

onready var score_label: Label = $HUD/ScoreLabel


func _ready() -> void:
	for coin in $Coins.get_children():
		coin.connect("collected", self, "_on_coin_collected")
	score_label.text = str(score)


func _on_coin_collected() -> void:
	score += 1
	score_label.text = str(score)
