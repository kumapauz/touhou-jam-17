### A place where the player can place an object.
### NPCs can also walk up to certain item holders to buy the object.
extends Area3D

## The item this holder currently has.
@export var item: ItemResource

@export_group("Components")
## The sprite node of this item.
@export var sprite: Sprite3D

func _ready() -> void:
	# Mostly for testing in the editor
	set_item(item)

## Changes the item of this particular item holder.
func set_item(new_item: ItemResource) -> void:
	item = new_item
	if has_item():
		sprite.texture = item.get_ingame_texture()
		sprite.offset = Vector2.LEFT * -sprite.texture.get_size().x * 0.5 # Center
		sprite.scale = Vector3.ONE * item.world_texture_scale
	else:
		sprite.texture = null

## Returns whether this item holder has an item or not.
func has_item() -> bool:
	return is_instance_valid(item)
