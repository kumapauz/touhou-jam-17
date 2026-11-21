## Lets the player haggle with a shopper.
extends Menu
class_name HaggleManager

static var instance: HaggleManager
func _enter_tree() -> void:
	instance = self

@export var item_root: Control
@export var item: TextureRect
## The desired price
var target_price: int
## Which digit is being edited.
var editing_place: int = 0

## The NPC we're haggling with.
var _haggle_target: NpcController
const MAX_PRICE: int = 99999

func select() -> void:
	finalize_sale()
	hide_menu()

func process_input(delta: float) -> void:
	# Check horizonal input
	var target_editing_place: int = editing_place
	if Input.is_action_just_pressed("left"):
		target_editing_place += 1
	elif Input.is_action_just_pressed("right"):
		target_editing_place -= 1
	target_editing_place = clamp(target_editing_place, 0, 4)
	if target_editing_place != editing_place:
		editing_place = target_editing_place
		process_cursor_position()
	
	var input: int = sign(Input.get_axis("up", "down"))
	if input != 0 && previous_input == input:
		selection_timer = move_toward(selection_timer, 0, delta)
		if !is_zero_approx(selection_timer):
			return
	
	previous_input = input
	scroll_selection(input)

func cancel() -> void:
	pass

func process_cursor_position() -> void:
	var index: int = (selection_options.size() - 1) - editing_place
	cursor.global_position = selection_options.get(index).global_position

func scroll_selection(dir: int) -> void:
	if dir == 0:
		return
	selection_timer = SELECTION_SCROLL_INTERVAL
	target_price = clamp(target_price - dir * pow(10, editing_place), 0, MAX_PRICE)
	update_price()

func show_menu() -> void:
	editing_place = 0
	update_price()
	super()
	DialogManager.instance.set_speaker(_haggle_target.npc)
	DialogManager.instance.play_random_quote(_haggle_target.npc.inquiry_quotes, "Buying this!")

func update_price() -> void:
	for i in range(selection_options.size()):
		selection_options.get(i).text = ("%05d" % target_price)[i]

func set_npc(npc: NpcController) -> void:
	_haggle_target = npc
	target_price = _haggle_target._target_holder.item.price
	
	item_root.visible = true
	item.texture = _haggle_target._target_holder.item.ui_texture

## Called after the sale is finished.
func finalize_sale() -> void:
	StatusManager.instance.add_money(target_price)
	DialogManager.instance.enable_inputs()
	DialogManager.instance.play_random_quote(_haggle_target.npc.purchase_quotes, "Thanks!")
	_haggle_target.purchase_item()
	_haggle_target = null
	item_root.visible = false
