extends Node3D

@onready var resting_position: Vector3 = position

var pos_tween: Tween = null
var poke_duration: float = 0.2
var poke_distance: float = 0.5

func poke() -> void:
	if pos_tween: pos_tween.kill()
	var poke_position: Vector3 = resting_position + Vector3(0, 0, -poke_distance)
	pos_tween = create_tween()
	pos_tween.tween_property(self, "position", poke_position, poke_duration * 0.5)
	pos_tween.tween_property(self, "position", resting_position, poke_duration * 0.5)
