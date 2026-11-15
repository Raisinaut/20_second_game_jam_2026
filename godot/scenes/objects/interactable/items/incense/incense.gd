extends Item

@onready var smoke: CPUParticles3D = %SmokeToon
@onready var light: FlickerLight3D = %Light

# COLLISION
@onready var physics_collision: CollisionShape3D = %CollisionShape3D
@onready var interaction_collision: CollisionShape3D = %InteractionCollision

# MESHES
@onready var stick: MeshInstance3D = $incense_holder_square/Stick
@onready var ashes: MeshInstance3D = $incense_holder_square/Ashes

# INTIAL VALUES
@onready var stick_initial_y_scale = stick.scale.y
@onready var initial_collision_height = physics_collision.shape.height
@onready var initial_collision_y_position = physics_collision.position.y
@onready var original_item_name: String = data.item_name

var min_collision_height: float = 0.05
var min_stick_y_scale: float = 0.1

var used_amount: float = 0.0 : set = set_used_amount
var burn_time: float = 4.0 # seconds
var burn_timer: SceneTreeTimer = null
var fully_burned: bool = false : set = set_fully_burned

func _ready() -> void:
	# Disable any burning related elements for safety
	stop_burning()

func _process(_delta: float) -> void:
	if is_burning():
		used_amount = get_burn_progress()

func interact(with_item: Item) -> void:
	if is_burning():
		return
	if with_item.data.item_name == "Candle":
		start_burning()

func set_stick_height(val: float) -> void:
	var actual_y_scale: float = lerp(stick_initial_y_scale, min_stick_y_scale, val)
	stick.scale.y = actual_y_scale

func update_smoke() -> void:
	light.position.y = get_collision_height()


# COLLISION --------------------------------------------------------------------
func set_collision_height(val: float) -> void:
	var actual_height: float = lerp(initial_collision_height, min_collision_height, val)
	var new_y_position: float = (actual_height - initial_collision_y_position / 4) / 2 # the division by 4 was not though through much
	interaction_collision.shape.height = actual_height
	interaction_collision.position.y = new_y_position
	physics_collision.shape.height = actual_height
	physics_collision.position.y = new_y_position

func get_collision_height() -> float:
	return physics_collision.shape.height


# SETTERS ----------------------------------------------------------------------
func set_used_amount(val: float) -> void:
	val = clamp(val, 0.0, 1.0)
	used_amount = val
	set_stick_height(used_amount)
	set_collision_height(used_amount)
	update_smoke()

func set_fully_burned(state: bool) -> void:
	fully_burned = state
	if fully_burned: # show only ashes
		ashes.visible = true
		stick.visible = false
		data.item_name = original_item_name + " Ashes"
	else: # show only stick
		ashes.visible = false
		stick.visible = true
		data.item_name = original_item_name


# BURNING ----------------------------------------------------------------------
func stop_burning() -> void:
	light.fade_out()
	smoke.emitting = false

func start_burning() -> void:
	light.fade_in()
	smoke.emitting = true
	burn_timer = get_tree().create_timer(burn_time)
	burn_timer.timeout.connect(_on_burn_timer_timeout)

func is_burning() -> bool:
	return burn_timer and burn_timer.time_left > 0

func get_burn_progress() -> float:
	return 1.0 - burn_timer.time_left / burn_time

func _on_burn_timer_timeout() -> void:
	stop_burning()
	set_fully_burned(true)
