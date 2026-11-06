class_name FlickerLight3D
extends Light3D

@export var fluctation: float = 0.5
@export var min_flicker_duration: float = 0.1
@export var max_flicker_duration: float = 0.2

@onready var starting_energy: float = light_energy

var energy_tween: Tween = null

func _ready() -> void:
	flicker()

func flicker() -> void:
	var duration: float = randf_range(min_flicker_duration, max_flicker_duration)
	var energy_delta: float = randf_range(-fluctation, fluctation)
	var new_energy: float = starting_energy + energy_delta
	if energy_tween: energy_tween.kill()
	energy_tween = create_tween()
	energy_tween.tween_property(self, "light_energy", new_energy, duration)
	energy_tween.finished.connect(flicker)
