class_name FlickerLight3D
extends Light3D

@export var fluctation: float = 0.5
@export var min_flicker_duration: float = 0.1
@export var max_flicker_duration: float = 0.2

@onready var starting_energy: float = light_energy

var light_energy_tween: Tween = null
var fade_out_time: float = 0.5

func _ready() -> void:
	flicker()

func flicker() -> void:
	var duration: float = randf_range(min_flicker_duration, max_flicker_duration)
	var energy_delta: float = randf_range(-fluctation, fluctation)
	var new_energy: float = starting_energy + energy_delta
	tween_light_energy(new_energy, duration).finished.connect(flicker)

func fade_out() -> Tween:
	return tween_light_energy(0, fade_out_time)

func tween_light_energy(val: float, duration: float) -> Tween:
	if light_energy_tween: light_energy_tween.kill()
	light_energy_tween = create_tween()
	light_energy_tween.tween_property(self, "light_energy", val, duration)
	return light_energy_tween
