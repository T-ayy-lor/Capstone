extends Node2D

# Camera bounds for this level, in its own coordinates.
# Left and top are normally 0; right is the level's width.
export var bounds_left: int = 0
export var bounds_right: int = 1200
export var bounds_top: int = 0
export var bounds_bottom: int = 205

onready var spawn_point: Position2D = $SpawnPoint
