extends Timer

@export var progress_bar: TextureProgressBar


func _ready() -> void:
	if !progress_bar:
		push_warning("No progress bar linked to ", self)

func _process(_delta: float) -> void:
	if is_stopped():
		return
	if progress_bar:
		progress_bar.value = time_left / wait_time

func deplete() -> void:
	stop()
	progress_bar.tween_value(0.0)
