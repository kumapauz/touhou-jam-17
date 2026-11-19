## Manages the player's inventory.
extends Control

var items: Array[ItemResource]

## Adds an item to the inventory (duplicates allowed).
func add_item(item: ItemResource) -> void:
	items.append(item)

## Removes the first instance of an item from the inventory.
func remove_item(item: ItemResource) -> bool:
	var index: int = items.find(item)
	if index != -1:
		items.remove_at(index)
		return true
	return false


# Show a menu to allow players to 
func show_item_selection() -> void:
	pass
