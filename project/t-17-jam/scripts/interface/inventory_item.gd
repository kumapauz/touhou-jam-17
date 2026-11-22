### Represents a single, selectable item in an item menu.
extends Control
class_name InventoryItem

@export var item: ItemResource
@export var null_item: ItemResource

@export_group("Components")
@export var sprite: TextureRect
@export var label: Label
@export var amount: Label
@export var price: Label

func set_item(new_item: ItemResource) -> void:
	item = new_item
	if !is_instance_valid(item):
		visible = false
		return
	
	visible = true
	sprite.texture = item.ui_texture
	label.text = item.item_name
	amount.visible = item != null_item
	price.get_parent().visible = item != null_item
	update_amount()

func update_amount() -> void:
	if amount.visible:
		amount.text = "x%02d" % InventoryManager.instance.get_item_count(item)

## Used for trend purchases.
func update_price(new_price: int = 0) -> void:
	if item == null_item:
		return
	price.text = str(item.price if new_price == 0 else new_price)
