extends Area3D

signal just_interacted

@export var can_hold: bool = false

func interact() -> void:
	just_interacted.emit()
