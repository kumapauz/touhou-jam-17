## Manages the player's inventory.
extends "res://scripts/interface/menu/item_selection.gd"
class_name InventoryManager

static var instance: InventoryManager
const MAX_INVENTORY_SIZE: int = 40

func _enter_tree() -> void:
	instance = self

## Adds an item to the inventory (duplicates allowed).
func add_item(item: ItemResource) -> void:
	if !is_instance_valid(item):
		return
	items.append(item)
	print("Item received: " + item.item_name)

## Removes the first instance of an item from the inventory.
func remove_item(item: ItemResource) -> bool:
	return remove_item_at(items.find(item))

## Removes a specific item from the inventory.
func remove_item_at(index: int) -> bool:
	if index != -1:
		print("Item sent: " + items.get(index).item_name)
		items.remove_at(index)
		return true
	return false

## Returns the number of a particular item the player is holding.
func get_item_count(item: ItemResource) -> int:
	var count: int = 0
	for i in items:
		if i == item:
			count += 1
	return count

func  on_menu_hidden() -> void:
	super()
	for connection in item_selected.get_connections():
		item_selected.disconnect(connection["callable"])
