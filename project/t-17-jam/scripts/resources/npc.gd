### Represents the data of an NPC.
extends Resource
class_name NpcResource

@export var name: String
## In-game sprites for moving around.
@export var sprite_frames: SpriteFrames
## Optional sprites for dialog.
@export var expressions: Array[Texture2D]

## This NPC will have a higher chance of buying these items.
@export var preferred_items: Array[ItemResource]
## This NPC will have a lower chance of buying these items.
@export var disliked_items: Array[ItemResource]

@export var npc_type: NPC_TYPE
enum NPC_TYPE {
	MOB, # Multiple mob characters can spawn at once
	CHAR, # Unique character that can only be spawned once
}
