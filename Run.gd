extends Node2D

const COIN_GROUP: String = "coins"

# The level loaded when a run begins. Set this in the Inspector.
export(PackedScene) var starting_level

# Every biome a run can visit, and every minigame played between biomes.
# Set both in the Inspector. Include the starting biome in "biomes".
export(Array, PackedScene) var biomes = []
export(Array, PackedScene) var minigames = []

var score: int = 0

var _current_level: Node2D = null
var _current_biome: PackedScene = null
var _in_minigame: bool = false
var _switching: bool = false

onready var _level_slot: Node2D = $LevelSlot
onready var _player: KinematicBody2D = $Player
onready var _camera: Camera2D = $Player/Camera2D
onready var _score_label: Label = $HUD/ScoreLabel

func _ready() -> void:
	randomize()
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

	# Remember which biome we're in, so the next one can be different.
	_in_minigame = minigames.has(level_scene)
	if not _in_minigame:
		_current_biome = level_scene

	_player.event_mode = false
	_player.global_position = _current_level.spawn_point.global_position
	_player.velocity = Vector2.ZERO

	_apply_camera_limits(_current_level)
	_connect_coins()
	_connect_portal(_current_level)
	_switching = false

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
	print("2. Run got portal signal | switching=", _switching)
	# Ignore repeat triggers while a level swap is pending.
	if _switching:
		return
	_switching = true
	# Deferred, because this signal fires inside a physics callback.
	call_deferred("_go_to_next_level")

func _go_to_next_level() -> void:
	print("3. picking next | in_minigame=", _in_minigame, " biomes=", biomes.size(), " minigames=", minigames.size())
	var next_scene: PackedScene = _pick_next_level()
	if next_scene == null:
		_switching = false
		return
	load_level(next_scene)

func _pick_next_level() -> PackedScene:
	# After a minigame: a random biome that isn't the one we just left.
	if _in_minigame or minigames.empty():
		return _pick_random_biome()
	# After a biome: a minigame.
	return minigames[randi() % minigames.size()]

func _pick_random_biome() -> PackedScene:
	if biomes.empty():
		return null
	var pool: Array = biomes.duplicate()
	pool.erase(_current_biome)
	if pool.empty():
		pool = biomes.duplicate()
	return pool[randi() % pool.size()]

func _refresh_score() -> void:
	_score_label.text = str(score)
