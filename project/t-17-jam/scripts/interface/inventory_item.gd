### Represents a single, selectable inventory item.
extends Control
class_name InventoryItem

@export var item: ItemResource

@export_group("Components")
@export var sprite: TextureRect
@export var label: Label

func set_item(new_item: ItemResource) -> void:
	item = new_item
	if !is_instance_valid(item):
		visible = false
		return
	
	visible = true
	sprite.texture = item.ui_texture
	label.text = item.item_name
