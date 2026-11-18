@tool
extends Item

@export var color_name: String = "" : set = set_color_name
@export var cap_color: Color = Color.WHITE : set = set_cap_color

@onready var cap: MeshInstance3D = $toadstool/Cap


func _ready() -> void:
	cap_color = cap_color
	if Engine.is_editor_hint():
		return
	apply_data_modifiers()

func apply_data_modifiers() -> void:
	print("Toadstool color: ", color_name)
	if color_name:
		# prepend modifier to name
		data.item_name = data.item_name.insert(0, color_name + " ")
	else:
		push_error("No color name configured for ", self)


# SETTERS ----------------------------------------------------------------------
func set_cap_color(c: Color) -> void:
	cap_color = c
	if not is_node_ready():
		return
	var mat : StandardMaterial3D = cap.material_override
	mat.albedo_color = cap_color

func set_color_name(n: String) -> void:
	color_name = n
	if not Engine.is_editor_hint():
		return
	name = "Toadstool" + color_name
