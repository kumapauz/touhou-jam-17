extends Menu
class_name DeskManager

static var instance: DeskManager

@export var retail_store: Menu
@export var description: Label
@export_dir var item_resource_path: String
@export_multiline var option_descriptions: Array[String]
var item_resources: Array[ItemResource]

func _enter_tree() -> void:
	instance = self
	init_item_resources()
	retail_store.item_hovered.connect(Callable(self, "set_item_description"))

func set_item_description(item: ItemResource) -> void:
	if is_instance_valid(item):
		description.text = item.item_description

func init_item_resources() -> void:
	for resource_file in ResourceLoader.list_directory(item_resource_path):
		var file_path: String = item_resource_path.path_join(resource_file)
		var res: ItemResource = ResourceLoader.load(file_path)
		item_resources.append(res)

func select() -> void:
	if selection == 0:
		retail_store.show_menu()
	elif selection == 2:
		if InventoryManager.instance.items.size() == 0:
			# Nothing to discard
			return
		var settings: InventoryManager.Settings = InventoryManager.Settings.new()
		InventoryManager.instance.update_settings(settings)
		InventoryManager.instance.show_menu()
		InventoryManager.instance.item_selected.connect(Callable(self, "on_discard_selected"), PROPERTY_HINT_ONESHOT)

func on_discard_selected(item: ItemResource) -> void:
	InventoryManager.instance.remove_item(item)
	process_discard_status()

func show_menu() -> void:
	super()
	process_discard_status()

func process_discard_status() -> void:
	if InventoryManager.instance.items.size() == 0:
		selection_options.get(2).modulate = Color(1, 1, 1, 0.5)
	else:
		selection_options.get(2).modulate = Color.WHITE

func on_menu_focused() -> void:
	super()
	process_discard_status()

func process_cursor_position() -> void:
	super()
	description.text = option_descriptions.get(selection)

func _process_delivery() -> void:
	pass
