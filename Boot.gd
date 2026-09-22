extends Node

# The project's base resolution is also the size an exported window opens
# at. Scale it by a whole number so the pixel grid stays square.
const SCALE: int = 4


func _ready() -> void:
	# In the editor, Test Width/Height already handles this.
	if OS.has_feature("editor"):
		return

	var base: Vector2 = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)

	OS.window_size = base * SCALE
	OS.center_window()
