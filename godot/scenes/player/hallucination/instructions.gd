extends MarginContainer

signal animation_finished

@export var items_to_show : Array[Control]

var alpha_tween: Tween = null


func _ready() -> void:
	visible = true
	reset_all_alphas()

func reset_all_alphas() -> void:
	self.modulate.a = 0
	for i in items_to_show:
		i.modulate.a = 0

func animate() -> void:
	#await tween_alpha(self, 1.0, 1.0).finished
	self.modulate.a = 1.0
	for i in items_to_show:
		await tween_alpha(i, 1.0, 1.5).finished
	await get_tree().create_timer(1.5).timeout
	await tween_alpha(self, 0, 1.5).finished
	animation_finished.emit()

func tween_alpha(node: Control, to_value: float, duration) -> Tween:
	if alpha_tween: alpha_tween.kill()
	alpha_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	alpha_tween.tween_property(node, "modulate:a", to_value, duration)
	return alpha_tween
