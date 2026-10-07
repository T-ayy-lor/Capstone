extends ParallaxBackground

# Pixels per second each cloud band drifts to the left.
# Farther bands should be slower than nearer ones.
export var bot_drift: float = 2.0
export var mid_drift: float = 4.0
export var top_drift: float = 7.0

onready var _bot: ParallaxLayer = $BotClouds
onready var _mid: ParallaxLayer = $MidClouds
onready var _top: ParallaxLayer = $TopClouds


func _physics_process(delta: float) -> void:
	_drift(_bot, bot_drift, delta)
	_drift(_mid, mid_drift, delta)
	_drift(_top, top_drift, delta)


# motion_offset slides a layer independently of the camera, so it stacks on
# top of the parallax rather than replacing it. Mirroring already wraps the
# result; fmod just stops the accumulator growing large enough over a long
# session to lose float precision.
func _drift(layer: ParallaxLayer, speed: float, delta: float) -> void:
	var span: float = layer.motion_mirroring.x
	var ofs: Vector2 = layer.motion_offset

	ofs.x -= speed * delta
	if span > 0.0:
		ofs.x = fmod(ofs.x, span)

	layer.motion_offset = ofs
