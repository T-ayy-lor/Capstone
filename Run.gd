extends Node2D

const COIN_GROUP: String = "coins"

# The level loaded when a run begins. Set this in the Inspector.
export(PackedScene) var starting_level

var score: int = 0

var _current_level: Node2D = null

onready var _level_slot: Node2D = $LevelSlot
onready var _player: KinematicBody2D = $Player
onready var _camera: Camera2D = $Player/Camera2D
onready var _score_label: Label = $HUD/ScoreLabel

func _ready() -> void:
	_refresh_score()
	if starting_level != null:
		load_level(starting_level)

func load_level(level_scene: PackedScene) -> void:
	# Detach immediately so the old level's coins leave the group this
	# frame, then queue the actual free.
	if _current_level != null:
		_level_slot.remove_child(_current_level)
		_current_level.queue_free()
		_current_level = null

	_current_level = level_scene.instance()
	_level_slot.add_child(_current_level)

	_player.global_position = _current_level.spawn_point.global_position
	_player.velocity = Vector2.ZERO

	_apply_camera_limits(_current_level)
	_connect_coins()
	_connect_portal(_current_level)

func _apply_camera_limits(level: Node2D) -> void:
	_camera.limit_left = level.bounds_left
	_camera.limit_right = level.bounds_right
	_camera.limit_top = level.bounds_top
	_camera.limit_bottom = level.bounds_bottom
	_camera.force_update_scroll()

func _connect_coins() -> void:
	for coin in get_tree().get_nodes_in_group(COIN_GROUP):
		if not coin.is_connected("collected", self, "_on_coin_collected"):
			coin.connect("collected", self, "_on_coin_collected")

func _connect_portal(level: Node2D) -> void:
	var portal: Node = level.get_node_or_null("Portal")
	if portal == null:
		return
	if not portal.is_connected("entered", self, "_on_portal_entered"):
		portal.connect("entered", self, "_on_portal_entered")

func _on_coin_collected() -> void:
	score += 1
	_refresh_score()

func _on_portal_entered() -> void:
	# With one level built, this reloads the same one. Replace with
	# selection from the level arrays once a second level exists.
	load_level(starting_level)

func _refresh_score() -> void:
	_score_label.text = str(score)
