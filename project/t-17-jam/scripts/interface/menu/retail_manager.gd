## Allow players to buy items.
extends "res://scripts/interface/menu/item_selection.gd"

## The amount to purchase
var amount: int = 1

## Key-value pairs of an item and its price.
var trends: Dictionary

func initialize_menu() -> void:
	super()
	items = DeskManager.instance.item_resources.duplicate()
	items.remove_at(items.find(nothing_item))
	StatusManager.instance.day_started.connect(Callable(self, "reset_trends"))
	reset_trends()

func reset_trends() -> void:
	for item in items:
		# Reset trend prices
		trends[item] = item.price
		# TODO Add some fluctuation to the initial prices?

func populate_options() -> void:
	super()
	for option in selection_options:
		if is_instance_valid(option.item):
			option.update_price(trends[option.item])

func select() -> void:
	var selected_item: ItemResource = selection_options.get(selection).item
	var price: int = trends[selected_item]
	if StatusManager.instance.money < price:
		print("Not enough money!")
		return
	
	if InventoryManager.instance.items.size() >= InventoryManager.MAX_INVENTORY_SIZE:
		print("No room in inventory!")
		return
	
	StatusManager.instance.add_money(-price)
	InventoryManager.instance.add_item(selection_options.get(selection).item)
	selection_options.get(selection).update_amount()
	# Update price based on trend
	trends[selected_item] += floor(selected_item.price * 0.1)
	selection_options.get(selection).update_price(trends[selected_item])
