extends Node2D

var jump_count: int = 0
var event_active: bool = false
var trigger_disabled: bool = false
var required_jumps: int = 20

var player = null
var saved_position: Vector2
onready var dimension_spawn: Position2D = get_node("../MashButtonDimensionSpawn")
onready var mash_label: Label = $MashLabel


func _ready() -> void:
	mash_label.visible = false


func _on_Trigger_body_entered(body):
	if body.name == "Player" and not event_active and not trigger_disabled:
		player = body
		saved_position = body.position
		
		body.position = dimension_spawn.position
		
		jump_count = 0
		event_active = true

		body.event_mode = true

		mash_label.text = "MASH SPACE! " + str(jump_count) + "/20"
		mash_label.visible = true


func _process(delta: float) -> void:
	if event_active:
		if Input.is_action_just_pressed("jump"):
			jump_count += 1

			mash_label.text = "MASH SPACE! " + str(jump_count) + "/20"

			print("Jump presses: ", jump_count)

			if jump_count >= required_jumps:
				event_active = false
				trigger_disabled = true

				player.position = saved_position
				player.event_mode = false

				mash_label.visible = false
				
				get_parent().score += 20
				get_parent().score_label.text = str(get_parent().score)
				print("Mash event complete!")

	if trigger_disabled and player != null:
		if player.position.distance_to(saved_position) > 100:
			trigger_disabled = false
			print("Mash trigger re-enabled!")

func _on_DimensionArea_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		player.position = saved_position
		player.event_mode = false
