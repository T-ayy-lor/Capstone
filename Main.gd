extends Node2D

const BOUNDS_GROUP: String = "chunk_bounds"

# Backgrounds live in a ParallaxBackground now, so they are not in world
# space and cannot define the world. Horizontal extent comes from the ground
# chunks; vertical is fixed, since every biome is one sky tall.
export var world_top: int = 0
export var world_bottom: int = 225

var score: int = 0

var _elapsed: float = 0.0
var _shown_seconds: int = -1

onready var _camera: Camera2D = $Player/Camera2D
onready var _coins: Node2D = $Coins
onready var _score_label: Label = $HUD/ScoreLabel
onready var _timer_label: Label = $HUD/TimerLabel


func _ready() -> void:
	apply_camera_limits()
	_connect_coins()
	_refresh_score()
	_refresh_timer()


func _process(delta: float) -> void:
	_elapsed += delta
	_refresh_timer()


# Each coin emits "collected" from CoinCollect.gd. Connecting by iteration
# rather than by name means adding or removing coins in the editor needs
# no script change.
func _connect_coins() -> void:
	for coin in _coins.get_children():
		if not coin.is_connected("collected", self, "_on_coin_collected"):
			coin.connect("collected", self, "_on_coin_collected")


func _on_coin_collected() -> void:
	score += 1
	_refresh_score()


func _refresh_score() -> void:
	_score_label.text = str(score)


# Only rewrites the label when the whole second changes, rather than
# rebuilding the string every frame.
func _refresh_timer() -> void:
	var total: int = int(_elapsed)
	if total == _shown_seconds:
		return

	_shown_seconds = total
	_timer_label.text = "%02d:%02d" % [total / 60, total % 60]


# Call again after adding or removing ground chunks at runtime.
func apply_camera_limits() -> void:
	var left: float = 0.0
	var right: float = 0.0
	var found: bool = false

	for node in get_tree().get_nodes_in_group(BOUNDS_GROUP):
		if not (node is Sprite) or node.texture == null:
			continue

		var x0: float = node.global_position.x
		var x1: float = x0 + node.texture.get_size().x * node.global_scale.x

		if found:
			left = min(left, x0)
			right = max(right, x1)
		else:
			left = x0
			right = x1
			found = true

	if not found:
		return

	_camera.limit_left = int(left)
	_camera.limit_top = world_top
	_camera.limit_right = int(right)
	_camera.limit_bottom = world_bottom
	_camera.force_update_scroll()
