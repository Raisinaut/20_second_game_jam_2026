extends PanelContainer

@onready var instructions = %Instructions
@onready var distortion: TextureRect = %Distortion
@onready var distortion_shader: ShaderMaterial = distortion.material
@onready var text_background: TextureRect = %TextBackground

var max_distortion: float = 0.025
var max_tint_alpha: float = 0.7
var distortion_tween: Tween = null


func _ready() -> void:
	stop_effects()

func stop_effects() -> void:
	distortion.hide()
	animate_distortion(0, 0)

func animate() -> void:
	distortion.show()
	await animate_distortion(1.0, 1.5).finished
	await instructions.animate()
	await animate_distortion(0.0, 1.5).finished
	distortion.hide()


# ANIMATION --------------------------------------------------------------------
func animate_distortion(to_value: float, duration: float) -> Tween:
	var initial_strength = get_distortion_strength()
	var initial_tint_alpha = get_distortion_tint()
	var mapped_tint_alpha = lerp(0.0, max_tint_alpha, to_value)
	var new_tint = Color(get_distortion_tint(), mapped_tint_alpha)
	if distortion_tween: distortion_tween.kill()
	distortion_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	distortion_tween.tween_method(set_distortion_strength, initial_strength, to_value, duration)
	distortion_tween.parallel().tween_method(set_distortion_tint_alpha, initial_tint_alpha, new_tint, duration)
	return distortion_tween


# SHADER METHODS ---------------------------------------------------------------
func set_distortion_strength(value: float) -> void:
	var mapped_value: float = lerp(0.0, max_distortion, value)
	distortion_shader.set_shader_parameter("refraction_strength", mapped_value)

func get_distortion_strength() -> float:
	return distortion_shader.get_shader_parameter("refraction_strength")

func set_distortion_tint_alpha(color: Color) -> void:
	distortion_shader.set_shader_parameter("water_tint", color)

func get_distortion_tint() -> Color:
	return distortion_shader.get_shader_parameter("water_tint")
