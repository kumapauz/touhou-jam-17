## Manages the player's inventory.
extends Menu
class_name InventoryManager

static var instance: InventoryManager

signal item_selected(item: ItemResource)

@export var nothing_item: ItemResource

## List of actively visible items.
var _visible_items: Array[ItemResource]

var menu_scroll: int
## Tracks the configuration of the current menu popup.
var current_settings: Settings

func _enter_tree() -> void:
	instance = self

func scroll_selection(dir: int) -> void:
	if dir == 0:
		return
	
	selection_timer = SELECTION_SCROLL_INTERVAL
	var item_count: int = _visible_items.size()
	selection += dir
	var scroll_dir: int = 0
	if selection >= item_count:
		scroll_dir = 1 # Scroll down
	elif selection < 0:
		scroll_dir = -1 # Scroll up
	selection = posmod(selection, item_count)
	
	if scroll_dir != 0:
		var total_count: int = get_menu_item_count()
		if total_count > selection_options.size():
			@warning_ignore("integer_division")
			menu_scroll = posmod(menu_scroll + scroll_dir, total_count / selection_options.size() + 1)
			populate_options()
			item_count = _visible_items.size()
			selection = 0 if scroll_dir > 0 else item_count - 1
	process_cursor_position()

func select() -> void:
	var selected_item: ItemResource = selection_options.get(selection).item
	item_selected.emit(selected_item)
	hide_menu()

func cancel() -> void:
	if !current_settings.allow_cancel:
		return
	hide_menu()

func process_cursor_position() -> void:
	cursor.global_position = selection_options.get(selection).global_position

class Settings:
	## Should the menu allow a separate "nothing" option?
	var allow_selecting_nothing: bool
	## Should the menu allow the menu to be canceled?
	var allow_cancel: bool = true

## List of items currently in the player's inventory.
var items: Array[ItemResource]

## Adds an item to the inventory (duplicates allowed).
func add_item(item: ItemResource) -> void:
	if !is_instance_valid(item):
		return
	items.append(item)
	print("Item received: " + item.item_name)

## Removes the first instance of an item from the inventory.
func remove_item(item: ItemResource) -> bool:
	var index: int = items.find(item)
	if index != -1:
		items.remove_at(index)
		print("Item sent: " + item.item_name)
		return true
	return false

## Returns the number of a particular item the player is holding.
func get_item_count(item: ItemResource) -> int:
	var count: int = 0
	for i in items:
		if i == item:
			count += 1
	return count

## Populates the list of shown menu items.
func populate_options() -> void:
	_visible_items.clear()
	
	# TODO Allow items to be grouped together
	# Update visible item list
	var offset: int = 0
	if current_settings.allow_selecting_nothing:
		offset = -1
		if menu_scroll == 0:
			_visible_items.append(nothing_item)
	var start_index: int = max(menu_scroll * selection_options.size() + offset, 0)
	for i in range(0, selection_options.size() + offset):
		var target_index: int = start_index + i
		if target_index >= items.size():
			break
		_visible_items.append(items.get(target_index))
	
	# Update the buttons
	for i in selection_options.size():
		if i < _visible_items.size():
			selection_options[i].set_item(_visible_items.get(i))
		else:
			selection_options[i].set_item(null)

## Returns the number of possible selections in the menu.
func get_menu_item_count() -> int:
	# TODO Allow grouping items together
	var total: int = items.size()
	if current_settings.allow_selecting_nothing:
		total += 1
	return total

func update_settings(settings : Settings) -> void:
	current_settings = settings

## Shows a menu so players can select an item. 
func show_menu() -> void:
	menu_scroll = 0
	super()
	populate_options()

func hide_menu() -> void:
	super()
	animator.play("hide")

func  on_menu_hidden() -> void:
	super()
	for connection in InventoryManager.instance.item_selected.get_connections():
		InventoryManager.instance.item_selected.disconnect(connection["callable"])
