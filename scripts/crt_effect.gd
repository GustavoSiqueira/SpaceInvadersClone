extends CanvasLayer

## Number of scanline pairs visible across the screen height.
@export_range(50.0, 1000.0) var scanline_count: float = 300.0:
	set(value):
		scanline_count = value
		_update_shader()

## Darkness of the scanline bands (0 = invisible, 1 = fully black).
@export_range(0.0, 1.0) var scanline_intensity: float = 0.35:
	set(value):
		scanline_intensity = value
		_update_shader()

## Darkness of the edge vignette (0 = invisible, 1 = fully black corners).
@export_range(0.0, 1.0) var vignette_intensity: float = 0.45:
	set(value):
		vignette_intensity = value
		_update_shader()

@onready var _overlay: ColorRect = $Overlay


func _ready() -> void:
	Settings.load()
	add_to_group("crt_effect")
	_overlay.size = get_viewport().get_visible_rect().size
	_update_shader()
	visible = Settings.get_crt_enabled()


func _update_shader() -> void:
	if not is_node_ready():
		return
	var mat := _overlay.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("scanline_count", scanline_count)
		mat.set_shader_parameter("scanline_intensity", scanline_intensity)
		mat.set_shader_parameter("vignette_intensity", vignette_intensity)
