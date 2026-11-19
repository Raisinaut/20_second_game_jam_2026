class_name MusicBox
extends StaticBody3D

@export var data: ItemData

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func interact(with_item: Item) -> void:
	if !with_item:
		print("I'm not holding anything.")
		return
	if with_item.data.item_name == "Key":
		if not animation_player.is_playing():
			animation_player.play("play_melody")
