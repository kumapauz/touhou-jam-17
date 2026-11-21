## Represents an item in the player's inventory.
extends Resource
class_name ItemResource

@export var item_name: String
@export_multiline var item_description: String
@export var ui_texture: Texture2D
## If null, will just reuse the UI sprite for the world.
@export var world_texture: Texture2D
## Optional parameter for how much to scale the world texture when in-game.
@export var world_texture_scale : float = 1.0
## The base price of the item.
@export var price: int = 100

# TODO Add a recipe to allow for crafting this item?
# TODO Add fields to specify which item this should turn into after being transformed by a object?

@export_range(1, 3) var rarity: int = 1

func get_ingame_texture() -> Texture2D:
	if is_instance_valid(world_texture):
		return world_texture
	return ui_texture
