class_name Cauldron
extends Area3D

@onready var splash_particles: CPUParticles3D = %SplashParticles
@onready var splash_trigger: Area3D = %SplashTrigger

var items_in_mix: Array[ItemData] = []

func _ready() -> void:
	splash_trigger.body_entered.connect(_on_splash_trigger_body_entered)
	# set up splash particles
	splash_particles.emitting = false
	splash_particles.one_shot = true

func splash() -> void:
	splash_particles.emitting = true

func interact(with_item: Item) -> void:
	if !with_item:
		print("I'm not holding anything to add.")
		return
	with_item.consumed = true
	await animate_item_addition(with_item).finished
	add_item_to_mix(with_item)

func add_item_to_mix(item: Item) -> void:
	items_in_mix.append(item.data)
	print("added to cauldron: ", item.data.item_name)
	print("cauldron mix: ", get_mix_content())
	item.queue_free()

func get_mix_content() -> Array[String]:
	var contents: Array[String]
	for i: ItemData in items_in_mix:
		contents.append(i.item_name)
	return contents

func animate_item_addition(item: Item) -> Tween:
	var duration : float = 0.8
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	var vertical_tween = create_tween().set_trans(Tween.TRANS_SINE)
	var spin_tween = create_tween()
	# Spin only
	spin_tween.tween_property(item, "global_rotation:z", 6, duration)
	# Vertical movement only 
	vertical_tween.set_ease(Tween.EASE_OUT)
	vertical_tween.tween_property(item, "global_position:y", global_position.y + 1.5, duration * 0.4)
	vertical_tween.set_ease(Tween.EASE_IN)
	vertical_tween.tween_property(item, "global_position:y", global_position.y, duration * 0.6)
	# Main tween
	tween.tween_subtween(vertical_tween)
	tween.parallel().tween_subtween(spin_tween)
	tween.parallel().tween_property(item, "global_position:x", global_position.x, duration)
	tween.parallel().tween_property(item, "global_position:z", global_position.z, duration)
	return tween


# SIGNALS ----------------------------------------------------------------------
func _on_splash_trigger_body_entered(body: PhysicsBody3D) -> void:
	if body is Item and body.consumed:
		splash()
