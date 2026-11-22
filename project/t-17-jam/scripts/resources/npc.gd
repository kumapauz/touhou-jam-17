### Represents the data of an NPC.
extends Resource
class_name NpcResource

@export var name: String
## In-game sprites for moving around.
@export var sprite_frames: SpriteFrames

## This NPC will have a higher chance of buying these items.
@export var preferred_items: Array[ItemResource]
## This NPC will have a lower chance of buying these items.
@export var disliked_items: Array[ItemResource]

@export var npc_type: NPC_TYPE
enum NPC_TYPE {
	MOB, # Multiple mob characters can spawn at once
	CHAR, # Unique character that can only be spawned once
}

## Base probability to stay in the store.
@export_range(0, 1, 0.1) var loiter_chance: float = 0.8
## How purchases influence persistence. High -> Leaves after a few purchases. Low -> Bulk buyer
@export_range(0, 1, 0.1) var loiter_increment: float = 0.1
## Base probability to make a purchase.
@export_range(0, 1, 0.1) var purchase_bias: float = 0.2
## Bias when buying preferred items.
@export_range(0, 1, 0.1) var preferred_purchase_bias: float = 0.2
## Bias when buying disliked items.
@export_range(0, 1, 0.1) var disliked_purchase_bias: float = 0.2

## How long to think before performing an action.
@export_range(0, 1, 0.1) var contemplation_bias: float = 0.5
## Multipier for how long to think before performing an action.
@export_range(0, 1, 0.1) var contemplation_multiplier: float = 0.5

## The ratio of how much this shopper is willing to pay extra without haggling.
@export_range(0.5, 2, 0.1) var overpay_bias: float = 1.2
## The maximum ratio this shopper is willing to pay extra with perfect haggling skills.
@export_range(1, 5, 0.1) var max_overpay_bias: float = 3.0
## The most aggreeable this npc is to haggle with.
@export_range(1, 5, 0.1) var min_haggle_multiplier: float = 1.0
## The most difficult this npc is to haggle with.
@export_range(1, 5, 0.1) var max_haggle_multiplier: float = 4.0
## How stubborn the npc is to negotiations. (i.e. how many negotiations need to be done).
@export_range(1, 5) var stubborness: int = 5

@export_group("Dialogs")
## Optional sprites for dialog.
@export var expressions: Array[Texture2D]
## Quotes for when this shopper wants to buy something.
@export var inquiry_quotes: PackedStringArray
## Quotes for when this shopper wants a discount.
@export var discount_quotes: PackedStringArray
## Quotes for when something is too expensive.
@export var expensive_quotes: PackedStringArray
## Quotes for when this shopper confirms a purchase.
@export var purchase_quotes: PackedStringArray
## Quotes for when the player refuses to sell to this shopper.
@export var declined_quotes: PackedStringArray
