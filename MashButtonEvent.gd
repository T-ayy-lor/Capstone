extends Node2D

var jump_count: int = 0
var event_active: bool = false
var required_jumps: int = 20

var player = null
var saved_position: Vector2
onready var dimension_spawn: Position2D = get_node("../DimensionSpawn")
onready var mash_label: Label = $MashLabel


func _ready() -> void:
	mash_label.visible = false


func _on_Trigger_body_entered(body):
	if body.name == "Player" and not event_active:
		player = body
		saved_position = body.position

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

				player.position = get_node("../DimensionSpawn").position
				player.event_mode = false

				mash_label.visible = false

				print("Mash event complete!")
