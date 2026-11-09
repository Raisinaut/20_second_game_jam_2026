class_name Item
extends RigidBody3D

signal just_consumed

const MIN_SCALE = Vector3.ONE * 0.001

@onready var spawn_xform = global_transform

var scale_tween: Tween = null
var rot_tween: Tween = null
var holding_node: Node3D = null : set = set_holding_node
var hold_move_speed: float = 2000
var hold_rotation_speed: float = 5
var reset_duration: float = 0.4

@export var data: ItemData = null
var consumed: bool = false:
	set(val):
		consumed = val
		if consumed:
			consume()


func _ready() -> void:
	# Safety Check
	if data == null:
		push_error("Add an item_data resource for this item.")

func consume() -> void:
	print(name, " consumed")
	just_consumed.emit()
	holding_node = null


# INTERACTION ------------------------------------------------------------------
func interact(_with_item: Node3D) -> void:
	print("No interactions programmed for ", name)

func hold(_holding_node: Node3D) -> void:
	holding_node = _holding_node

func drop() -> void:
	return_to_spawn()


# MOVEMENT ---------------------------------------------------------------------
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if holding_node:
		# Follow position
		var max_dist = 2
		var node_dist = global_position.distance_to(holding_node.global_position)
		var move_direction = global_position.direction_to(holding_node.global_position)
		move_direction *= node_dist / max_dist
		state.linear_velocity = move_direction * state.step * hold_move_speed
		# Follow rotation
		var current_quat = Quaternion(global_transform.basis)
		var target_quat = Quaternion(holding_node.global_transform.basis.orthonormalized())
		var new_quat = current_quat.slerp(target_quat, state.step * hold_rotation_speed)
		global_transform.basis = Basis(new_quat)
		# prevents odd spinning after collisions
		state.angular_velocity = Vector3.ZERO
	else:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO

func return_to_spawn() -> void:
	await spin().finished # remove await here if using shrink tween
	holding_node = null
	# Smoke puff before moving
	ParticleManager.spawn_particle(ParticleManager.ParticleType.SMOKE_PUFF, self)
	reset_xform()
	# Smoke puff after moving
	ParticleManager.spawn_particle(ParticleManager.ParticleType.SMOKE_PUFF, self)
	grow()

func reset_xform() -> void:
	global_transform = spawn_xform

func reset_velocities() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


# ANIMAITON --------------------------------------------------------------------
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


# SETTERS ----------------------------------------------------------------------
func set_holding_node(node: Node3D) -> void:
	holding_node = node
	if holding_node:
		can_sleep = false
		gravity_scale = 0.0
	else:
		can_sleep = true
