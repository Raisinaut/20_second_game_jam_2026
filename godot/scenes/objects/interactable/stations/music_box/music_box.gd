class_name MusicBox
extends StaticBody3D

@export var data: ItemData

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var model_animation_player: AnimationPlayer = $music_box/AnimationPlayer
@onready var key: MeshInstance3D = $music_box/Base/Cylinder/Key


func _ready() -> void:
	key.hide()

func interact(with_item: Item) -> void:
	if !with_item:
		print("I'm not holding anything.")
		return
	if with_item.data.item_name == "Key":
		# Manipulate key
		with_item.consume()
		with_item.interaction_disabled = true
		await move_to_self(with_item).finished
		with_item.visible = false
		# Show music box key model
		key.show()
		# Play melody
		if not animation_player.is_playing():
			animation_player.play("play_melody")
		await animation_player.animation_finished
		# Hide music box key modelwWWwww
		key.hide()
		# Respawn key item
		with_item.visible = true
		with_item.return_to_spawn(false)

func move_to_self(node: Node3D) -> Tween:
	var move_duration: float = 0.0
	var t = create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(node, "global_position", key.global_position, move_duration)
	t.parallel().tween_property(node, "scale", node.scale * 0.6, move_duration)
	return t


# MODEL ANIMATIONS -------------------------------------------------------------
func open_lid() -> void:
	model_animation_player.play("LidAction")

func close_lid() -> void:
	model_animation_player.play_backwards("LidAction")

func spin_cylinder() -> void:
	model_animation_player.play("CylinderAction")

func stop_cylinder() -> void:
	model_animation_player.stop()
