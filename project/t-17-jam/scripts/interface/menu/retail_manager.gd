## Allow players to buy items.
extends "res://scripts/interface/menu/item_selection.gd"

## The amount to purchase
var amount: int = 1

func initialize_menu() -> void:
	super()
	items = DeskManager.instance.item_resources.duplicate()
	items.remove_at(items.find(nothing_item))

func process_input(delta: float) -> void:
	super(delta)


func select() -> void:
	var selected_item: ItemResource = selection_options.get(selection).item
	if StatusManager.instance.money < selected_item.price:
		print("Not enough money!")
		return
	
	if InventoryManager.instance.items.size() >= InventoryManager.MAX_INVENTORY_SIZE:
		print("No room in inventory!")
		return
	
	StatusManager.instance.add_money(-selected_item.price)
	InventoryManager.instance.add_item(selection_options.get(selection).item)
