extends Node3D

@onready var player: Player = %Player


enum MouseModes {
	CAMERA,
	CURSOR
}
var mouse_mode = MouseModes.CAMERA : set = set_mouse_mode

func _ready() -> void:
	mouse_mode = mouse_mode
	player.blink_close_finished.connect(_on_player_blink_close_finished)

func set_mouse_mode(mode: MouseModes) -> void:
	mouse_mode = mode
	match(mouse_mode):
		MouseModes.CAMERA:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		MouseModes.CURSOR:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_player_blink_close_finished() -> void:
	get_tree().reload_current_scene()
