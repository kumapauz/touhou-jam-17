## Menu that allows for selecting an item from a list.
extends Menu

signal item_hovered(item: ItemResource)
signal item_selected(item: ItemResource)

@export var nothing_item: ItemResource

## List of actively visible items.
var _visible_items: Array[ItemResource]

var menu_scroll: int
## Tracks the configuration of the current menu popup.
var current_settings: Settings = Settings.new()

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
	if item_count > 1:
		SoundManager.instance.play_sfx("menu_move")
	
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
	super()
	var selected_item: ItemResource = selection_options.get(selection).item
	item_selected.emit(selected_item)
	hide_menu()

func cancel() -> void:
	if !current_settings.allow_cancel:
		return
	super()

func process_cursor_position() -> void:
	cursor.global_position = selection_options.get(selection).global_position
	item_hovered.emit(selection_options.get(selection).item)

class Settings:
	## Should the menu allow a separate "nothing" option?
	var allow_selecting_nothing: bool
	## Should the menu allow the menu to be canceled?
	var allow_cancel: bool = true
	## Should the prices be halved?
	var is_discard_menu: bool

## List of items currently in this menu.
@export var items: Array[ItemResource]

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
			printt(current_settings.is_discard_menu, _visible_items.get(i).get_discard_price())
			if current_settings.is_discard_menu:
				selection_options[i].update_price(_visible_items.get(i).get_discard_price())
			else:
				selection_options[i].update_price(0)
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
	item_hovered.emit(selection_options.get(selection).item)
