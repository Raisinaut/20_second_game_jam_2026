extends Item

@onready var light: FlickerLight3D = %Light

# Override to smoothly fade out light when consuming
func consume() -> void:
	super()
	light.fade_out()
