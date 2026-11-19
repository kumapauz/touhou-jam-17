## Manages the player's inventory.
extends Control
class_name InventoryManager

signal menu_shown
signal menu_hidden

@export_group("Components")
@export var cursor: Control
@export var inventory_item_parent: VBoxContainer
var _inventory_items: Array[InventoryItem]

## Tracks whether the inventory manager should be processing inputs.
var is_menu_active: bool
## Tracks the configuration of the current menu popup.
var current_settings: MenuSettings

func _ready() -> void:
	for child in inventory_item_parent.get_children():
		if child is InventoryItem:
			_inventory_items.append(child)

func _process(_delta: float) -> void:
	if is_menu_active:
		process_menu()

func process_menu() -> void:
	if current_settings.allow_cancel && Input.is_action_just_pressed("cancel"):
		hide_menu()
		return
	
	if Input.is_action_just_pressed("confirm"):
		select_item()

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
	items.append(item)

## Removes the first instance of an item from the inventory.
func remove_item(item: ItemResource) -> bool:
	var index: int = items.find(item)
	if index != -1:
		items.remove_at(index)
		return true
	return false

var item_selection: int
var menu_scroll: int

## Populates the list of shown menu items.
func populate_menu_items() -> void:
	pass

## Shows a menu so players can select an item. 
func show_menu(settings : MenuSettings) -> void:
	# TODO Change menu type based on context. 
	current_settings = settings
	menu_shown.emit()

func hide_menu() -> void:
	if !is_menu_active: # Menu is not visible
		return
	is_menu_active = false
	menu_hidden.emit()

func select_item() -> ItemResource:
	return null
