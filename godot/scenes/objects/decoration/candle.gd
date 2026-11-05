extends Node3D

@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var starting_energy: float = omni_light_3d.light_energy

var energy_tween: Tween = null


func _ready() -> void:
	flicker()

func flicker() -> void:
	var duration: float = randf_range(0.2, 0.1)
	var energy_delta: float = randf_range(-0.05, 0.05)
	var new_energy: float = starting_energy + energy_delta
	if energy_tween: energy_tween.kill()
	energy_tween = create_tween()
	energy_tween.tween_property(omni_light_3d, "light_energy", new_energy, duration)
	energy_tween.finished.connect(flicker)
