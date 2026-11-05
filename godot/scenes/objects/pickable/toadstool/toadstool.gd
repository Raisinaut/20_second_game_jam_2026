@tool

class_name Pickable
extends PhysicsBody3D

const MIN_SCALE = Vector3.ONE * 0.001

@onready var cap = $toadstool/Cap
@onready var spawn_xform = global_transform

@export var cap_color: Color = Color.WHITE : set = set_cap_color

var scale_tween: Tween = null
var rot_tween: Tween = null
var holding_node: Node3D = null : set = set_holding_node
var hold_snap_speed: float = 12
var reset_duration: float = 0.4


func _physics_process(delta: float) -> void:
	if holding_node:
		var target_xform = holding_node.global_transform
		global_transform = lerp(global_transform, target_xform, hold_snap_speed * delta)

func return_to_spawn() -> void:
	await spin().finished # remove await here if using shrink tween
	#await shrink().finished
	holding_node = null
	ParticleManager.spawn_particle(ParticleManager.ParticleType.SMOKE_PUFF, self)
	reset_xform()
	ParticleManager.spawn_particle(ParticleManager.ParticleType.SMOKE_PUFF, self)
	grow()

func grow() -> Tween:
	scale = MIN_SCALE
	var spawn_scale: Vector3 = spawn_xform.basis.get_scale()
	return tween_scale(spawn_scale, reset_duration, Tween.EaseType.EASE_OUT)

func shrink() -> Tween:
	return tween_scale(MIN_SCALE, reset_duration, Tween.EaseType.EASE_IN)

func tween_scale(value: Vector3, duration: float, ease_type : Tween.EaseType) -> Tween:
	if scale_tween: scale_tween.kill()
	scale_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(ease_type)
	scale_tween.tween_property(self, "scale", value, duration)
	return scale_tween

func spin() -> Tween:
	if rot_tween: scale_tween.kill()
	var rot_delta := Vector3(0,0,8)
	rot_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	rot_tween.tween_property(self, "rotation", rotation + rot_delta, reset_duration)
	return rot_tween

func reset_xform() -> void:
	global_transform = spawn_xform


# SIGNALS ----------------------------------------------------------------------
func _on_pickable_area_hold_started(destination_node: Node3D) -> void:
	holding_node = destination_node


# SETTERS ----------------------------------------------------------------------
func set_holding_node(node: Node3D) -> void:
	holding_node = node

func set_cap_color(c: Color) -> void:
	if not is_node_ready():
		return
	cap_color = c
	var mat = StandardMaterial3D.new()
	mat.albedo_color = c
	mat.roughness = 0.5
	$toadstool/Cap.material_override = mat
	print(mat.albedo_color)
