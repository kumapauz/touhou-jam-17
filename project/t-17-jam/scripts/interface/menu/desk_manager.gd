extends Menu
class_name DeskManager

static var instance: DeskManager

@export var description: Label
@export_dir var item_resource_path: String
@export_multiline var option_descriptions: Array[String]

var _item_resources: Array[ItemResource]

func _enter_tree() -> void:
	instance = self

func init_item_resources() -> void:
	for resource_file in ResourceLoader.list_directory(item_resource_path):
		var file_path: String = item_resource_path.path_join(resource_file)
		var res: ItemResource = ResourceLoader.load(file_path)
		_item_resources.append(res)

func select() -> void:
	if selection == 2:
		var settings: InventoryManager.Settings = InventoryManager.Settings.new()
		InventoryManager.instance.update_settings(settings)
		InventoryManager.instance.show_menu()

func _process_delivery() -> void:
	pass

func process_cursor_position() -> void:
	super()
	description.text = option_descriptions.get(selection)
