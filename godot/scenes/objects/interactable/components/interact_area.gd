class_name InteractArea
extends Area3D


func interact(with_item: Node = null) -> void:
	var object = get_object()
	if object.has_method("interact"):
		object.interact(with_item)
	else:
		push_warning(object, " does not have an interact method.")

func attempt_hold(_holding_node: Node3D) -> Node3D:
	var object: Node3D = get_parent()
	print("Attempt to hold ", object)
	if object.has_method("hold"):
		object.hold(_holding_node)
		return object
	else:
		print(object, " does not have a hold method.")
		return null

func drop() -> void:
	get_object().drop()

func get_object() -> Node3D:
	return get_parent()

func can_hold() -> bool:
	var object_can_hold := false
	if get_object().has_method("hold"):
		object_can_hold = true
	return object_can_hold
