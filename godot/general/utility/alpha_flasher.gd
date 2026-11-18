class_name AlphaFlasher
extends Node

@export_range(0, 1, 0.01) var max_opacity : float = 1.0
@export_range(0, 1, 0.01) var min_opacity : float = 0.0
@export var interval : float = 1.0

@onready var linked_node : Node = get_parent()

var time_passed : float = 0.0
var active: bool = false

func _process(delta: float) -> void:
	if active:
		progress_interval(delta)
	else:
		time_passed = 0.0
	update_opacity()

func update_opacity() -> void:
	linked_node.self_modulate.a = lerp(max_opacity, min_opacity, get_amount_scale())

func get_amount_scale() -> float:
	return sin(PI * get_interval_progress())

func get_interval_progress() -> float:
	return time_passed / interval

func progress_interval(delta) -> void:
	time_passed += delta
	if time_passed >= interval:
		time_passed = 0.0
