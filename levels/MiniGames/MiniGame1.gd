extends Node2D

export var bounds_left: int = -2000
export var bounds_right: int = 2000
export var bounds_top: int = -2000
export var bounds_bottom: int = 2000

onready var spawn_point: Position2D = $SpawnPoint

export var required_jumps: int = 20

onready var ice_block: ColorRect = $IceBlock
onready var mash_label: Label = $HUD/MashLabel
onready var exit_point: Position2D = $ExitPoint
onready var portal: Area2D = $Portal

var tween: Tween
var player = null
var triggered: bool = false
var event_active: bool = false
var jump_count: int = 0
var ice_base_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Created in code, so you don't need a Tween node in the scene.
	tween = Tween.new()
	add_child(tween)

	ice_block.visible = false
	mash_label.visible = false
	portal.monitoring = false
	# Temporary, just for testing this scene on its own:


func _on_Water_body_entered(body):
	if body.name != "Player" or triggered:
		return
	triggered = true
	event_active = true
	jump_count = 0
	player = body

	player.event_mode = true

	# Center the ice on the player and remember where it sits (for the shake).
	ice_block.modulate = Color(1, 1, 1, 1)
	ice_block.rect_global_position = player.global_position - ice_block.rect_size / 2.0
	ice_base_pos = ice_block.rect_position
	ice_block.visible = true

	_update_label()
	mash_label.visible = true


func _input(event: InputEvent) -> void:
	if not event_active:
		return
	if event.is_action_pressed("jump") and not event.is_echo():
		jump_count += 1
		_update_label()
		_crack_ice()

		if jump_count >= required_jumps:
			_break_out()


func _update_label() -> void:
	mash_label.text = "MASH JUMP! %d/%d" % [jump_count, required_jumps]


func _crack_ice() -> void:
	# More see-through the closer you are to breaking out.
	var progress: float = float(jump_count) / float(required_jumps)
	ice_block.modulate.a = lerp(1.0, 0.4, progress)
	# Small shake on every press.
	ice_block.rect_position = ice_base_pos + Vector2(rand_range(-3, 3), rand_range(-3, 3))


func _break_out() -> void:
	event_active = false
	mash_label.visible = false
	ice_block.rect_position = ice_base_pos

	# Fade the ice out, then release the player.
	tween.interpolate_property(ice_block, "modulate:a", ice_block.modulate.a, 0.0, 0.3)
	tween.interpolate_callback(self, 0.3, "_finish_event")
	tween.start()


func _finish_event() -> void:
	ice_block.visible = false
	player.global_position = exit_point.global_position
	player.event_mode = false
	portal.monitoring = true
	print("Broke out!")
	
	

