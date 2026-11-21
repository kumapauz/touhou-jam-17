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
## List of actively visible items.
var _visible_items: Array[ItemResource]

## Tracks whether the inventory manager should be processing inputs.
var process_inputs: bool
## Tracks whether the menu is shown or not.
var is_menu_active: bool
## Tracks the configuration of the current menu popup.
var current_settings: MenuSettings
var _input_scroll: float
var _held_input: int
const INPUT_SCROLL_LENGTH: float = 0.12

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	for child in inventory_item_parent.get_children():
		if child is InventoryItem:
			_menu_items.append(child)

func _process(delta: float) -> void:
	if process_inputs:
		process_menu(delta)

func process_menu(delta: float) -> void:
	if current_settings.allow_cancel && Input.is_action_just_pressed("cancel"):
		hide_menu()
		return
	
	if Input.is_action_just_pressed("confirm"):
		select_item()
	
	var input: int = sign(Input.get_axis("up", "down"))
	if _held_input != input:
		_held_input = input
		scroll_selection(input)
	else:
		_input_scroll = move_toward(_input_scroll, 0, delta)
		if input != 0 && is_zero_approx(_input_scroll):
			scroll_selection(input)

func scroll_selection(dir: int) -> void:
	if dir == 0:
		return
	
	_input_scroll = INPUT_SCROLL_LENGTH
	var item_count: int = _visible_items.size()
	item_selection += dir
	var scroll_dir: int = 0
	if item_selection >= item_count:
		scroll_dir = 1 # Scroll down
	elif item_selection < 0:
		scroll_dir = -1 # Scroll up
	item_selection = posmod(item_selection, item_count)
	
	if scroll_dir != 0:
		var total_count: int = get_menu_item_count()
		if total_count > _menu_items.size():
			@warning_ignore("integer_division")
			menu_scroll = posmod(menu_scroll + scroll_dir, total_count / _menu_items.size() + 1)
			populate_menu_items()
			item_count = _visible_items.size()
			item_selection = 0 if scroll_dir > 0 else item_count - 1
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

@export var items: Array[ItemResource]

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
	_visible_items.clear()
	
	# TODO Allow items to be grouped together
	# Update visible item list
	var offset: int = 0
	if current_settings.allow_selecting_nothing:
		offset = -1
		if menu_scroll == 0:
			_visible_items.append(nothing_item)
	var start_index: int = max(menu_scroll * _menu_items.size() + offset, 0)
	for i in range(0, _menu_items.size() + offset):
		var target_index: int = start_index + i
		if target_index >= items.size():
			break
		_visible_items.append(items.get(target_index))
	
	# Update the buttons
	for i in _menu_items.size():
		if i < _visible_items.size():
			_menu_items[i].set_item(_visible_items.get(i))
		else:
			_menu_items[i].set_item(null)

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
	process_cursor_position()
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
