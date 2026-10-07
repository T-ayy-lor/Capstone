extends Node2D

# Needed by Run.gd, same as levels/level.gd.
export var bounds_left: int = 0
export var bounds_right: int = 1800
export var bounds_top: int = 0
export var bounds_bottom: int = 400

onready var spawn_point: Position2D = $SpawnPoint

# Dance settings (tweak these in the Inspector).
export var rounds: int = 3                     # how many routines to complete
export var start_length: int = 3               # moves in round 1 (+1 each round)
export var reshuffle_on_mistake: bool = false  # false = redo the same moves, true = new moves
export var arrow_scale: float = 0.6            # arrow size (1.0 = 44px wide)
export var arrow_gap: float = 36.0             # space between arrows on screen
export var show_words: bool = true             # write LEFT / JUMP / RIGHT under each arrow
export var word_scale: float = 0.6             # size of those words
export var arrows_y: float = 55.0              # screen y of the arrow row
export var ready_time: float = 2.0
export var round_pause: float = 1.0

enum State { IDLE, READY, PLAYING, PAUSE, DONE }

onready var stage_point: Position2D = $StagePoint
onready var exit_point: Position2D = $ExitPoint
onready var portal: Area2D = $Portal
onready var hud: CanvasLayer = $HUD
onready var dance_label: Label = $HUD/DanceLabel
# Optional: a ColorRect directly under DanceFloor that flashes random colors.
onready var floor_tint: ColorRect = get_node_or_null("DanceFloor/ColorRect")

# Lane 0 = left, lane 1 = up (jump), lane 2 = right.
var lane_actions: Array = ["move_left", "jump", "move_right"]
var lane_words: Array = ["LEFT", "JUMP", "RIGHT"]
var lane_colors: Array = [Color(1.0, 0.35, 0.65), Color(0.35, 1.0, 0.5), Color(0.4, 0.65, 1.0)]

var player = null
var sprite: AnimatedSprite = null
var sprite_base_pos: Vector2 = Vector2.ZERO
var tween: Tween
var arrows_root: Node2D

var state: int = State.IDLE
var triggered: bool = false
var sequence: Array = []      # lane numbers the player must press, in order
var arrow_nodes: Array = []
var step: int = 0             # which arrow the player is on
var round_index: int = 0
var timer: float = 0.0


func _ready() -> void:
	# Created in code, so the scene doesn't need these nodes.
	tween = Tween.new()
	add_child(tween)
	arrows_root = Node2D.new()
	hud.add_child(arrows_root)

	dance_label.visible = false
	# Locked until the dance is finished. Deferred because the level is
	# still being added to the tree.
	portal.set_deferred("monitoring", false)


# Connect DanceFloor's "body_entered" signal to this function.
func _on_DanceFloor_body_entered(body) -> void:
	if body.name != "Player" or triggered or is_a_parent_of(body):
		return
	triggered = true
	# Deferred, because this signal fires inside a physics callback.
	call_deferred("_start_event", body)


func _start_event(body) -> void:
	player = body
	player.event_mode = true
	player.global_position = stage_point.global_position

	sprite = player.get_node_or_null("AnimatedSprite")
	if sprite != null:
		sprite_base_pos = sprite.position

	round_index = 0
	_start_round(ready_time)


func _start_round(wait: float) -> void:
	_generate_sequence()
	_build_arrows()
	step = 0
	_refresh_arrows()
	timer = wait
	state = State.READY
	dance_label.visible = true


func _process(delta: float) -> void:
	match state:
		State.READY:
			timer -= delta
			dance_label.text = "ROUND %d/%d\nGET READY!" % [round_index + 1, rounds]
			if timer <= 0.0:
				state = State.PLAYING
				_update_label()
		State.PAUSE:
			timer -= delta
			if timer <= 0.0:
				_start_round(0.8)


func _input(event: InputEvent) -> void:
	if state != State.PLAYING or event.is_echo():
		return
	for lane in range(3):
		if event.is_action_pressed(lane_actions[lane]):
			_press(lane)
			return


func _press(lane: int) -> void:
	if lane == sequence[step]:
		# Correct move: the player busts a move.
		_dance_move(lane)
		_tint_floor()
		step += 1
		if step >= sequence.size():
			_finish_round()
		else:
			_refresh_arrows()
			_update_label()
	else:
		_mistake()


func _mistake() -> void:
	step = 0
	if reshuffle_on_mistake:
		_generate_sequence()
		_build_arrows()
	_refresh_arrows()
	dance_label.text = "OOPS! FROM THE TOP"
	_shake_arrows()


func _finish_round() -> void:
	_refresh_arrows()
	round_index += 1
	if round_index >= rounds:
		_complete_event()
	else:
		state = State.PAUSE
		timer = round_pause
		dance_label.text = "NICE MOVES!"


func _complete_event() -> void:
	state = State.DONE
	dance_label.visible = false
	for a in arrow_nodes:
		if is_instance_valid(a):
			a.queue_free()
	arrow_nodes.clear()

	tween.remove_all()
	arrows_root.position = Vector2.ZERO
	if sprite != null:
		sprite.rotation_degrees = 0.0
		sprite.position = sprite_base_pos

	player.global_position = exit_point.global_position
	player.event_mode = false

	# Wait a physics frame, then unlock the exit portal.
	yield(get_tree(), "physics_frame")
	portal.monitoring = true
	print("Dance event complete!")


# --- Sequence and arrows ---

func _generate_sequence() -> void:
	sequence.clear()
	var length: int = start_length + round_index
	for _i in range(length):
		sequence.append(randi() % 3)


func _build_arrows() -> void:
	for a in arrow_nodes:
		if is_instance_valid(a):
			a.queue_free()
	arrow_nodes.clear()

	var center_x: float = get_viewport().get_visible_rect().size.x / 2.0
	var n: int = sequence.size()
	for i in range(n):
		var lane: int = sequence[i]
		var arrow := Polygon2D.new()
		arrow.polygon = _arrow_points(lane)
		arrow.color = lane_colors[lane]
		if show_words:
			arrow.add_child(_make_word_label(lane))
		arrow.position = Vector2(center_x + (float(i) - float(n - 1) / 2.0) * arrow_gap, arrows_y)
		arrows_root.add_child(arrow)
		arrow_nodes.append(arrow)


func _make_word_label(lane: int) -> Label:
	# Child of the arrow, so it grows, fades and moves with it.
	var label := Label.new()
	label.text = lane_words[lane]
	label.align = Label.ALIGN_CENTER
	label.rect_size = Vector2(100, 20)
	label.rect_position = Vector2(-50, 28)
	label.rect_pivot_offset = Vector2(50, 0)
	label.rect_scale = Vector2.ONE * (word_scale / arrow_scale)
	# Same font as DanceLabel, so it matches the rest of your UI.
	label.add_font_override("font", dance_label.get_font("font"))
	label.add_color_override("font_color", lane_colors[lane])
	return label


func _refresh_arrows() -> void:
	var normal: Vector2 = Vector2(arrow_scale, arrow_scale)
	for i in range(arrow_nodes.size()):
		var arrow: Polygon2D = arrow_nodes[i]
		if i < step:
			# Already done: small and faded.
			arrow.scale = normal
			arrow.modulate = Color(1, 1, 1, 0.25)
		elif i == step:
			# Current move: bigger and bright.
			arrow.scale = normal * 1.35
			arrow.modulate = Color(1, 1, 1, 1)
		else:
			# Coming up.
			arrow.scale = normal
			arrow.modulate = Color(1, 1, 1, 0.7)


func _update_label() -> void:
	dance_label.text = "ROUND %d/%d\nFollow the arrows! %d/%d" % [round_index + 1, rounds, step, sequence.size()]


func _shake_arrows() -> void:
	tween.remove(arrows_root, "position")
	arrows_root.position = Vector2(6, 0)
	tween.interpolate_property(arrows_root, "position", arrows_root.position, Vector2.ZERO, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()


# --- Goofy visuals ---

func _dance_move(lane: int) -> void:
	if sprite == null:
		return
	tween.remove(sprite, "rotation_degrees")
	tween.remove(sprite, "position")

	match lane:
		0:  # left: flip and tilt
			sprite.flip_h = true
			sprite.rotation_degrees = -25.0
		1:  # up: hop
			sprite.position = sprite_base_pos + Vector2(0, -14)
		2:  # right: flip the other way and tilt
			sprite.flip_h = false
			sprite.rotation_degrees = 25.0

	tween.interpolate_property(sprite, "rotation_degrees", sprite.rotation_degrees, 0.0, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "position", sprite.position, sprite_base_pos, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()


func _tint_floor() -> void:
	if floor_tint != null:
		floor_tint.color = Color.from_hsv(randf(), 0.6, 1.0, 0.7)


func _arrow_points(lane: int) -> PoolVector2Array:
	match lane:
		0:  # left
			return PoolVector2Array([
				Vector2(-22, 0), Vector2(0, -22), Vector2(0, -9), Vector2(22, -9),
				Vector2(22, 9), Vector2(0, 9), Vector2(0, 22)])
		1:  # up
			return PoolVector2Array([
				Vector2(0, -22), Vector2(22, 0), Vector2(9, 0), Vector2(9, 22),
				Vector2(-9, 22), Vector2(-9, 0), Vector2(-22, 0)])
		_:  # right
			return PoolVector2Array([
				Vector2(22, 0), Vector2(0, 22), Vector2(0, 9), Vector2(-22, 9),
				Vector2(-22, -9), Vector2(0, -9), Vector2(0, -22)])
