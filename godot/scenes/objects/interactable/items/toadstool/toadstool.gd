@tool
extends Item

@export var cap_color: Color = Color.WHITE : set = set_cap_color


func set_cap_color(c: Color) -> void:
	if not is_node_ready():
		return
	cap_color = c
	var mat = StandardMaterial3D.new()
	mat.albedo_color = c
	mat.roughness = 0.5
	$toadstool/Cap.material_override = mat
	print("Toadstool cap color set to: ", mat.albedo_color)
