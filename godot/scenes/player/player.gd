class_name Player
extends CharacterBody3D

signal blink_close_finished

const WALK_SPEED := 3.0
const SPRINT_SPEED := 4.5
const CROUCH_SPEED := 2.0
const ACCEL := 10.0
const DECEL := 20.0

@onready var head_position: Node3D = %HeadPosition
@onready var picker_ray: RayCast3D = %PickerRay
@onready var hand_position = %HandPosition
@onready var reticle = %Reticle
@onready var screen_blink = %ScreenBlink
@onready var blink_timer: Timer = %BlinkTimer

enum MovementModes {
	WALK,
	CROUCH,
	SPRINT
}

var mouse_sensitivity: float = 0.4
var mouse_smoothing: float = 50

var movement_mode := MovementModes.WALK : set = set_movement_mode
var rotation_velocity := Vector2.ZERO
var target_rotation := Vector2.ZERO
var current_speed: float = 0
var target_speed: float = WALK_SPEED
var input_direction := Vector2.ZERO
var target_direction := Vector3.ZERO
var input_disabled: bool = false
var input_damper: float = 0.0

var held_object: Item = null: set = set_held_object


func _ready() -> void:
	movement_mode = movement_mode
	blink_timer.start()
	# INITIAL SCREEN BLINK
	screen_blink.blink_closed(true)
	screen_blink.blink_open()
	# CONNECT SIGNALS
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	screen_blink.blink_close_finished.connect(_on_screen_blink_close_finished)

func _process(delta):
	update_input_direction()
	update_velocity(delta)
	update_reticle()

func _physics_process(delta):
	update_rotation(delta)
	move_and_slide()

## Dampen a variant value according to the blink closed amount
func blink_damper(variant: Variant) -> Variant:
	var damper = ease(screen_blink.get_open_amount(), 0.4)
	return variant * damper


# INPUT EVENTS -----------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event.is_action("blink") && not screen_blink.is_blinking():
		screen_blink.blink_closed(true)
	# Object interaction
	if event is InputEventMouseButton:
		handle_object_interaction(event)
	# Movement
	if event is InputEventMouseMotion:
		handle_rotation_event(event)
	handle_movement_event(event)

func handle_object_interaction(event: InputEvent) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("interact"):
		if picker_ray.is_colliding():
			var area : InteractArea = picker_ray.get_collider()
			interact_with_area(area)
	if event.is_action_pressed("drop"):
		if held_object:
			print("Dropped: ", held_object.name)
			held_object.return_to_spawn()
			held_object = null

func handle_movement_event(event: InputEvent) -> void:
	if not is_on_floor():
		return
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

func handle_rotation_event(event: InputEvent) -> void:
	target_rotation = -Vector2(event.screen_relative.y, event.screen_relative.x)
	target_rotation = blink_damper(target_rotation)

func interact_with_area(area: InteractArea) -> void:
	print()
	# Attempt to combine
	if held_object:
		print("Combine objects: ", held_object.name, " and ", area.get_object().name)
		hand_position.poke()
		area.interact(held_object)
	else:
		# Attempt to hold
		held_object = area.attempt_hold(hand_position)
		if held_object:
			print("Held: ", held_object)
		# Simply interact
		else:
			area.interact()
			print("Interacted with: ", area.name)


# UPDATE FUNCTIONS -------------------------------------------------------------
func update_input_direction() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	target_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	target_direction = blink_damper(target_direction)

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
func set_held_object(object: Item) -> void:
	var held_object_prev: Item = held_object
	held_object = object
	if held_object:
		print("Connect signals to ", object)
		# Connect signals
		held_object.just_consumed.connect(_on_held_object_just_consumed)
	# Disconnect signal from dropped item
	elif held_object_prev and held_object_prev.just_consumed.is_connected(_on_held_object_just_consumed):
		held_object_prev.just_consumed.disconnect(_on_held_object_just_consumed)

func set_movement_mode(mode: MovementModes) -> void:
	movement_mode = mode
	match(movement_mode):
		MovementModes.WALK:
			target_speed = WALK_SPEED
		MovementModes.CROUCH:
			target_speed = CROUCH_SPEED
		MovementModes.SPRINT:
			target_speed = SPRINT_SPEED


# SIGNALS ----------------------------------------------------------------------
func _on_held_object_just_consumed() -> void:
	held_object = null

func _on_blink_timer_timeout() -> void:
	if not screen_blink.is_blinking():
		screen_blink.blink_closed()

func _on_screen_blink_close_finished() -> void:
	blink_close_finished.emit()
