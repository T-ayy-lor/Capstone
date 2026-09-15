extends Sprite

export var scroll_speed: float = 8.0

const TEXTURE_WIDTH: float = 320.0


func _process(delta: float) -> void:
	var r: Rect2 = region_rect
	r.position.x = fmod(r.position.x + scroll_speed * delta, TEXTURE_WIDTH)
	region_rect = r
