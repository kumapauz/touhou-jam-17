## Allow players to buy items.
extends "res://scripts/interface/menu/item_selection.gd"

## The amount to purchase.
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
		trends[item] = item.price * 0.8 # Start with initial discount of 20%
		# TODO Add some fluctuation to the initial prices?

## Returns whether the player should get a single free sale.
func is_free_sale() -> bool:
	if ItemHolder.items.size() != 0 || InventoryManager.instance.items.size() != 0:
		return false
	
	for item in items:
		if trends[item] <= StatusManager.instance.money:
			return false
	# Player is broke -- give a freebie to avoid a softlock.
	return true

func populate_options() -> void:
	super()
	var free_sale: bool = is_free_sale()
	for option in selection_options:
		if is_instance_valid(option.item):
			if free_sale:
				option.update_price(0)
			else:
				option.update_price(trends[option.item])
			var count: int = InventoryManager.instance.get_item_count(option.item)
			count += ItemHolder.get_item_count(option.item)
			option.update_amount(count)

func select() -> void:
	var selected_item: ItemResource = selection_options.get(selection).item
	var price: int = trends[selected_item]
	if is_free_sale():
		price = 0
	
	if StatusManager.instance.money < price:
		SoundManager.instance.play_sfx("menu_cancel")
		print("Not enough money!")
		return
	
	#if InventoryManager.instance.items.size() >= InventoryManager.MAX_INVENTORY_SIZE:
		#print("No room in inventory!")
		#return
	
	SoundManager.instance.play_sfx("menu_accept")
	StatusManager.instance.add_money(-price)
	InventoryManager.instance.add_item(selection_options.get(selection).item)
	selection_options.get(selection).update_amount()
	# Update price based on trend
	trends[selected_item] += floor(selected_item.price * 0.1)
	populate_options()
