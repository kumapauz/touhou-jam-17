### A place where the player can place an object.
### NPCs can also walk up to certain item holders to buy the object.
extends InteractableObject
class_name ItemHolder

signal item_sent_to_inventory(item: ItemResource)

## The item this holder currently has.
@export var item: ItemResource
## An item that forces the item to dissappear.
@export var null_item: ItemResource

@export_group("Components")
## The sprite node of this item.
@export var sprite: Sprite3D

func _ready() -> void:
	# Mostly for testing in the editor
	set_item(item, true)
	item_sent_to_inventory.connect(Callable(InventoryManager.instance, "add_item"))

func clear_item() -> void:
	set_item(null_item)

func interact() -> void:
	# Open inventory menu
	var menu_settings := InventoryManager.Settings.new()
	menu_settings.allow_selecting_nothing = true
	InventoryManager.instance.update_settings(menu_settings)
	InventoryManager.instance.show_menu()
	InventoryManager.instance.item_selected.connect(Callable.create(self, "on_inventory_selected"), CONNECT_ONE_SHOT)

func on_inventory_selected(new_item: ItemResource) -> void:
	InventoryManager.instance.remove_item(new_item)
	set_item(new_item)

## Changes the item of this particular item holder.
func set_item(new_item: ItemResource, is_initializing = false) -> void:
	if !is_instance_valid(new_item) && !is_initializing: # Can't set to null
		return
	
	if !is_initializing:
		item_sent_to_inventory.emit(item)
	
	if new_item == null_item: # Clearing the item
		new_item = null
	
	item = new_item
	sprite.visible = has_item()
	if sprite.visible:
		sprite.texture = item.get_ingame_texture()
		sprite.offset = Vector2.LEFT * sprite.texture.get_size().x * 0.5 # Center
		sprite.scale = Vector3.ONE * item.world_texture_scale
	else:
		sprite.texture = null

## Returns whether this item holder has an item or not.
func has_item() -> bool:
	return is_instance_valid(item)
