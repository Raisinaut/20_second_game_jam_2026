class_name Player
extends CharacterBody3D

const WALK_SPEED := 3.0
const SPRINT_SPEED := 4.5
const CROUCH_SPEED := 2.0
const ACCEL := 10.0
const DECEL := 20.0

@onready var head_position: Node3D = %HeadPosition
@onready var picker_ray: RayCast3D = %PickerRay
@onready var hand_position: Node3D = %HandPosition
@onready var reticle: TextureRect = %Reticle

enum MovementModes {
	WALK,
	CROUCH,
	SPRINT
}

var movement_mode := MovementModes.WALK : set = set_movement_mode
var rotation_velocity := Vector2.ZERO
var target_rotation := Vector2.ZERO
var current_speed: float = 0
var target_speed: float = WALK_SPEED
var input_direction := Vector2.ZERO
var target_direction := Vector3.ZERO

var mouse_sensitivity: float = 0.3
var mouse_smoothing: float = 50

var held_object: Interactable = null

func _ready() -> void:
	movement_mode = movement_mode

func _process(delta):
	update_input_direction()
	update_velocity(delta)
	update_rotation(delta)
	update_reticle()

func _physics_process(_delta):
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Object interaction
	if event is InputEventMouseButton:
		if event.is_action_pressed("interact"):
			if picker_ray.is_colliding():
				var object : Interactable = picker_ray.get_collider()
				# Hold if not already held
				if object.can_hold:
					object.interact(hand_position)
					held_object = object
					print("Picked up: ", object.name)
				else:
					object.interact()
					print("Interacted with: ", object.name)
		if event.is_action_pressed("drop"):
			if held_object:
				print("Dropped: ", held_object.name)
				held_object.return_to_spawn()
				held_object = null
	
	# Movement control
	if event is InputEventMouseMotion:
		target_rotation = -Vector2(event.relative.y, event.relative.x)
	if is_on_floor():
		 # CROUCH
		if event.is_action_pressed("crouch") and !event.is_echo():
			if movement_mode != MovementModes.CROUCH:
				movement_mode = MovementModes.CROUCH
			else:
				movement_mode = MovementModes.WALK
		# SPRINT
		if event.is_action_pressed("sprint") and input_direction.y < 0:
			movement_mode = MovementModes.SPRINT
		if event.is_action_released("sprint"):
			if movement_mode != MovementModes.CROUCH:
				movement_mode = MovementModes.WALK


# UPDATE FUNCTIONS -------------------------------------------------------------
func update_input_direction() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	target_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

func update_velocity(delta: float) -> void:
	var new_velocity := Vector3(0, velocity.y, 0)
	current_speed = lerp(current_speed, target_speed, ACCEL * delta)
	if target_direction:
		new_velocity.x = target_direction.x * current_speed
		new_velocity.z = target_direction.z * current_speed
		velocity = lerp(velocity, new_velocity, ACCEL * delta)
	else:
		velocity = lerp(velocity, new_velocity, DECEL * delta)

func update_rotation(delta):
	rotation_velocity = lerp(rotation_velocity, target_rotation * mouse_sensitivity * 0.01, mouse_smoothing * delta)
	rotate_y(rotation_velocity.y)
	head_position.rotate_x(rotation_velocity.x)
	head_position.rotation.x = clamp(head_position.rotation.x, -PI/2, PI/2)
	target_rotation = Vector2.ZERO

func update_reticle() -> void:
	var alpha = 1.0 if picker_ray.is_colliding() else 0.2
	reticle.modulate.a = alpha


# SETTERS ----------------------------------------------------------------------
func set_movement_mode(mode: MovementModes) -> void:
	movement_mode = mode
	match(movement_mode):
		MovementModes.WALK:
			target_speed = WALK_SPEED
		MovementModes.CROUCH:
			target_speed = CROUCH_SPEED
		MovementModes.SPRINT:
			target_speed = SPRINT_SPEED
