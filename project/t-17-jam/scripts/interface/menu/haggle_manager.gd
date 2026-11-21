## Lets the player haggle with a shopper.
extends Menu
class_name HaggleManager

static var instance: HaggleManager
func _enter_tree() -> void:
	instance = self

@export var item_root: Control
@export var item: TextureRect
@export var price_label: Label
## The desired price
var target_price: int

## The NPC we're haggling with.
var _haggle_target: NpcController
const MAX_PRICE: int = 9999

func initialize_menu() -> void:
	pass

func select() -> void:
	finalize_sale()
	hide_menu()

func scroll_selection(dir: int) -> void:
	target_price = clamp(target_price - dir, 0, MAX_PRICE)
	update_price()

func show_menu() -> void:
	super()
	update_price()

func update_price() -> void:
	price_label.text = "%4d" % target_price

func set_npc(npc: NpcController) -> void:
	_haggle_target = npc
	target_price = _haggle_target._target_holder.item.price
	
	item_root.visible = true
	item.texture = _haggle_target._target_holder.item.ui_texture
	DialogManager.instance.play_random_quote(_haggle_target.npc.inquiry_quotes, "Buying this!")

## No cursor
func process_cursor_position() -> void:
	pass

## Called after the sale is finished.
func finalize_sale() -> void:
	print("FINALIZING SALE")
	StatusManager.instance.add_money(target_price)
	DialogManager.instance.enable_inputs()
	DialogManager.instance.play_random_quote(_haggle_target.npc.purchase_quotes, "Thanks!")
	_haggle_target.purchase_item()
	_haggle_target = null
	item_root.visible = false
