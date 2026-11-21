extends TextureRect

signal blink_close_started
signal blink_close_finished
signal blink_open_started
signal blink_open_finished

@onready var blink_shader: ShaderMaterial = material

var blink_tween: Tween = null
var blink_closed_duration_slow: float = 2.0
var blink_closed_duration_fast: float = 0.8
var blink_open_duration: float = 0.8

func blink_open(immediate: bool = false) -> void:
	if immediate:
		snap_blink(1.0)
	else:
		tween_blink(1.0, blink_open_duration)
		blink_open_started.emit()
		# CONNECT to opening signals
		if not blink_tween.finished.is_connected(blink_open_finished.emit):
			blink_tween.finished.connect(blink_open_finished.emit)
		# DISCONNECT from closing signals
		if blink_tween.finished.is_connected(blink_close_started.emit):
			blink_tween.finished.disconnect(blink_close_started.emit)

func blink_closed(fast: bool = false, immediate: bool = false) -> void:
	if immediate:
		snap_blink(0.0)
	else:
		if fast:
			tween_blink(0.0, blink_closed_duration_fast)
		else:
			tween_blink(0.0, blink_closed_duration_slow)
		blink_close_started.emit()
		# CONNECT to closing signals
		if not blink_tween.finished.is_connected(blink_close_finished.emit):
			blink_tween.finished.connect(blink_close_finished.emit)
		# DISCONNECT from opening signals
		if blink_tween.finished.is_connected(blink_open_finished.emit):
			blink_tween.finished.disconnect(blink_open_finished.emit)

func tween_blink(to_value: float, duration) -> Tween:
	var starting_value: float = blink_shader.get_shader_parameter("open_amount")
	if blink_tween: blink_tween.kill()
	blink_tween = create_tween()
	blink_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	blink_tween.tween_method(set_blink_amount, starting_value, to_value, duration)
	return blink_tween

func snap_blink(to_value: float) -> void:
	set_blink_amount(to_value)
	if to_value == 0.0:
		blink_close_started.emit()
		blink_close_finished.emit()
	elif to_value == 1.0:
		blink_open_started.emit()
		blink_open_finished.emit()

func set_blink_amount(value: float) -> void:
	blink_shader.set_shader_parameter("open_amount", value)

func get_open_amount() -> float:
	return blink_shader.get_shader_parameter("open_amount")

func is_blinking() -> bool:
	return blink_tween and blink_tween.is_running()
