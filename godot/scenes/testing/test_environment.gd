extends Node3D


enum MouseModes {
	CAMERA,
	CURSOR
}
var mouse_mode = MouseModes.CAMERA : set = set_mouse_mode

@onready var cauldron: Area3D = $Entities/Objects/Cauldron

func _ready() -> void:
	mouse_mode = mouse_mode
	print(cauldron)

func set_mouse_mode(mode: MouseModes) -> void:
	mouse_mode = mode
	match(mouse_mode):
		MouseModes.CAMERA:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		MouseModes.CURSOR:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
