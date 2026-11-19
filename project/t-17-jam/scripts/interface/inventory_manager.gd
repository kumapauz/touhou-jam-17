## Manages the player's inventory.
extends Control
class_name InventoryManager

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

## Returns an item for a given menu item option.
func find_item(menu_index: int) -> ItemResource:
	if items.size() == 0:
		return null
	# TODO Allow grouping items together
	if current_settings.allow_selecting_nothing:
		menu_index -= 1
	return items.get(menu_scroll + menu_index)

## Shows a menu so players can select an item. 
func show_menu(settings : MenuSettings) -> void:
	# TODO Change menu type based on context. 
	is_menu_active = true
	current_settings = settings
	populate_menu_items()
	item_menu_animator.play("show")
	menu_shown.emit()

func hide_menu(selected_item: ItemResource = null) -> void:
	if !is_menu_active: # Menu is not visible
		return
	process_inputs = false
	item_menu_animator.play("hide")
	item_selected.emit(selected_item)

## Called from the animator.
func on_menu_shown() -> void:
	process_inputs = true

## Called from the animator.
func on_menu_hidden() -> void:
	is_menu_active = false
	menu_hidden.emit()

func select_item() -> void:
	hide_menu(_menu_items.get(item_selection).item) # Selected nothing
