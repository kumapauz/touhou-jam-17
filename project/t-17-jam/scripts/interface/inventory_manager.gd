## Manages the player's inventory.
extends Control
class_name InventoryManager

static var instance: InventoryManager

signal menu_shown
signal item_selected(item: ItemResource)
signal menu_hidden

@export var nothing_item: ItemResource

@export_group("Components")
@export var item_menu_animator: AnimationPlayer
@export var cursor: Control
@export var inventory_item_parent: VBoxContainer
var _menu_items: Array[InventoryItem]

## Tracks whether the inventory manager should be processing inputs.
var process_inputs: bool
## Tracks whether the menu is shown or not.
var is_menu_active: bool
## Tracks the configuration of the current menu popup.
var current_settings: MenuSettings

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	for child in inventory_item_parent.get_children():
		if child is InventoryItem:
			_menu_items.append(child)

func _process(_delta: float) -> void:
	if process_inputs:
		process_menu()

func process_menu() -> void:
	if current_settings.allow_cancel && Input.is_action_just_pressed("cancel"):
		hide_menu()
		return
	
	if Input.is_action_just_pressed("confirm"):
		select_item()
	
	if Input.is_action_just_pressed("up"):
		scroll_selection(-1)
	elif Input.is_action_just_pressed("down"):
		scroll_selection(1)

func scroll_selection(dir: int) -> void:
	var menu_count: int = get_menu_item_count()
	item_selection = posmod(item_selection + dir, menu_count)
	process_cursor_position()

func process_cursor_position() -> void:
	cursor.global_position = _menu_items.get(item_selection).global_position

class MenuSettings:
	## Should the menu allow a separate "nothing" option?
	var allow_selecting_nothing: bool
	## Should the menu allow the menu to be canceled?
	var allow_cancel: bool = true
	## Should duplicate items be grouped together?
	var allow_grouping: bool = true
	enum MenuType {
		SELECT, # Select an item. Something must be selected.
		SELECT_WITH_NULL, # Used to place an item. Allow selecting "nothing."
	}

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

var item_selection: int
var menu_scroll: int

## Populates the list of shown menu items.
func populate_menu_items() -> void:
	for i in _menu_items.size():
		if i == 0 && menu_scroll == 0 && current_settings.allow_selecting_nothing:
			_menu_items[i].set_item(nothing_item)
			print("Set a nothing item.")
			continue
		var target_item: ItemResource = find_item(i)
		if is_instance_valid(target_item):
			_menu_items[i].set_item(target_item)
		else:
			_menu_items[i].set_item(null)
	process_cursor_position()

## Returns an item for a given menu item option.
func find_item(menu_index: int) -> ItemResource:
	# TODO Allow grouping items together
	if current_settings.allow_selecting_nothing:
		menu_index -= 1
	if items.size() <= menu_scroll + menu_index:
		return null
	return items.get(menu_scroll + menu_index)

## Returns the number of possible selections in the menu.
func get_menu_item_count() -> int:
	# TODO Allow grouping items together
	var total: int = items.size()
	if current_settings.allow_selecting_nothing:
		total += 1
	return total

## Shows a menu so players can select an item. 
func show_menu(settings : MenuSettings) -> void:
	# TODO Change menu type based on context. 
	is_menu_active = true
	current_settings = settings
	item_selection = 0
	menu_scroll = 0
	populate_menu_items()
	item_menu_animator.play("show")
	menu_shown.emit()

func hide_menu() -> void:
	if !is_menu_active: # Menu is not visible
		return
	process_inputs = false
	item_menu_animator.play("hide")

## Called from the animator.
func on_menu_shown() -> void:
	process_inputs = true

## Called from the animator.
func on_menu_hidden() -> void:
	is_menu_active = false
	menu_hidden.emit()

func select_item() -> void:
	var selected_item: ItemResource = _menu_items.get(item_selection).item
	hide_menu() # Selected nothing
	item_selected.emit(selected_item)
