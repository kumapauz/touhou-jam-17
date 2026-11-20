### Represents a single, selectable inventory item in the item menu.
extends Control
class_name InventoryItem

@export var item: ItemResource
@export var null_item: ItemResource

@export_group("Components")
@export var sprite: TextureRect
@export var label: Label
@export var amount: Label

func set_item(new_item: ItemResource) -> void:
	item = new_item
	if !is_instance_valid(item):
		visible = false
		return
	
	visible = true
	sprite.texture = item.ui_texture
	label.text = item.item_name
	amount.visible = item != null_item
	if amount.visible:
		amount.text = "x%02d" % InventoryManager.instance.get_item_count(item)
