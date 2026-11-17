extends TextureProgressBar

var value_tween: Tween
var alpha_tween: Tween
var value_tween_duration: float = 0.25
var alpha_tween_duration: float = 0.3

func _ready() -> void:
	fade(0.0, true)
	fade(1.0)

func tween_value(to_value: float) -> void:
	if value_tween: value_tween.kill()
	value_tween = create_tween()
	value_tween.tween_property(self, "value", to_value, value_tween_duration)

func fade(to_value: float, immediate: bool = false) -> void:
	if alpha_tween: alpha_tween.kill()
	if immediate:
		modulate.a = to_value
	else:
		alpha_tween = create_tween()
		alpha_tween.tween_property(self, "modulate:a", to_value, alpha_tween_duration)
