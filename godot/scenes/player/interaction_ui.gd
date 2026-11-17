extends MarginContainer

@onready var interaction_label: Label = $InteractionLabel


func _ready() -> void:
	clear_text()

func describe_combination(item: Item, interact_area: InteractArea) -> void:
	var item_name: String = item.data.item_name.to_upper()
	var object_name: String = interact_area.get_object().data.item_name.to_upper()
	interaction_label.text = "Use {0} with {1}".format([item_name, object_name])

func describe_object(interact_area: InteractArea) -> void:
	var object_name = interact_area.get_object().data.item_name.to_upper()
	if interact_area.can_hold():
		interaction_label.text = "Hold {0}".format([object_name])
	else:
		interaction_label.text = "{0}".format([object_name])

func clear_text() -> void:
	interaction_label.text = ""
