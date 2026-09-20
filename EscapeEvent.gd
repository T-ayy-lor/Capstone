extends Node2D

var player = null
var saved_position: Vector2
var event_active: bool = false
var trigger_disabled: bool = false

var sequence = []
var sequence_index: int = 0
var sequence_length: int = 5

onready var escape_spawn: Position2D = get_node("../EscapeEventSpawn")
onready var escape_label: Label = $EscapeEventLabel


func _ready() -> void:
	escape_label.visible = false
	randomize()


func _on_Trigger_body_entered(body):
	if body.name == "Player" and not event_active and not trigger_disabled:
		player = body
		saved_position = body.position

		body.position = escape_spawn.position
		event_active = true

		_generate_sequence()
		_update_sequence_label()

		escape_label.visible = true

		body.event_mode = true


func _check_input(input: String) -> void:
	if input == sequence[sequence_index]:
		sequence_index += 1

		if sequence_index >= sequence_length:
			_complete_event()
		else:
			_update_sequence_label()
	else:
		_generate_sequence()
		_update_sequence_label()


func _process(_delta: float) -> void:
	if event_active:
		if Input.is_action_just_pressed("move_left"):
			_check_input("left")

		elif Input.is_action_just_pressed("move_right"):
			_check_input("right")

		elif Input.is_action_just_pressed("jump"):
			_check_input("jump")

	if trigger_disabled and player != null:
		if player.position.distance_to(saved_position) > 100:
			trigger_disabled = false
			print("Escape trigger re-enabled!")


func _complete_event() -> void:
	event_active = false
	trigger_disabled = true

	player.position = saved_position
	player.event_mode = false

	escape_label.visible = false

	get_parent().score += 20
	get_parent().score_label.text = str(get_parent().score)

	print("Escape event complete!")


func _generate_sequence() -> void:
	sequence.clear()

	var possible_inputs = ["left", "right", "jump"]

	for _i in range(sequence_length):
		var random_input = possible_inputs[randi() % possible_inputs.size()]
		sequence.append(random_input)

	sequence_index = 0


func _update_sequence_label() -> void:
	var display_text = "ESCAPE THE QUICKSAND!\n\n"

	for i in range(sequence.size()):
		var input_name = sequence[i].to_upper()

		if i == sequence_index:
			display_text += "[ " + input_name + " ]"

		elif i < sequence_index:
			display_text += "✓ " + input_name

		else:
			display_text += input_name

		if i < sequence.size() - 1:
			display_text += "  →  "

	escape_label.text = display_text
