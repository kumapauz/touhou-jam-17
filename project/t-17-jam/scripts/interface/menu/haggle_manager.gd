## Lets the player haggle with a shopper.
extends Menu
class_name HaggleManager

static var instance: HaggleManager
func _enter_tree() -> void:
	instance = self

@export var haggle_label: Label
@export var markup_label: Label
@export var item_root: Control
@export var item: TextureRect
@export var haggle_cursor_animator: AnimationPlayer
@export var haggle_point_parent: Node2D
var _haggle_point_pool: Array[Node2D]
var _haggle_points: Array[Area2D]
var _is_haggle_input_enabled: bool

## The desired price.
var target_price: int
var base_price: int
var haggle_price: int
var haggle_score: int
var haggle_points_processed: int
var is_haggle_points_spawning: bool

var _haggle_timer: float
const MIN_HAGGLE_INTERVAL: float = 0.2
const MAX_HAGGLE_INTERVAL: float = 1.2
const HAGGLE_SPEED_MULTIPLIER: float = 2.0

## Which digit is being edited.
var editing_place: int = 0

## The NPC we're haggling with.
var _haggle_target: NpcController
const MAX_PRICE: int = 99999

var is_haggle_minigame_active: bool

func initialize_menu() -> void:
	super()
	for point in haggle_point_parent.get_children():
		_haggle_point_pool.append(point)

func process_menu(delta: float) -> void:
	if is_haggle_minigame_active:
		process_haggle_minigame(delta)
	else:
		super(delta)

func select() -> void:
	super()
	if target_price > base_price * _haggle_target.npc.max_overpay_bias:
		# Way too expensive. Ask player to enter a different value
		DialogManager.instance.play_random_quote(_haggle_target.npc.expensive_quotes, "That's too expensive!!!")
		return
	
	if target_price > base_price * _haggle_target.npc.overpay_bias:
		start_haggle_minigame()
		return
	finalize_sale()

func start_haggle_minigame() -> void:
	haggle_score = 0
	haggle_points_processed = 0
	_is_haggle_input_enabled = true
	for point in _haggle_point_pool:
		point.respawn()
	
	update_haggle_price()
	is_haggle_minigame_active = true
	DialogManager.instance.disable_inputs()
	DialogManager.instance.play_random_quote(_haggle_target.npc.discount_quotes, "Let's negotiate...")
	animator.play("negotiate")

func on_minigame_started() -> void:
	_haggle_timer = 0.0
	is_haggle_points_spawning = true

func process_haggle_minigame(delta: float) -> void:
	for point in _haggle_point_pool:
		if point.is_active():
			point.process_point(delta)
	
	_haggle_timer = move_toward(_haggle_timer, 0, delta)
	if is_haggle_points_spawning && is_zero_approx(_haggle_timer):
		spawn_haggle_point()
	
	if Input.is_action_just_pressed("confirm") && _is_haggle_input_enabled:
		haggle_cursor_animator.seek(0.0)
		haggle_cursor_animator.play("hit")
		_is_haggle_input_enabled = false

## Called when the haggle point is being checked.
func check_haggle_hit() -> void:
	_is_haggle_input_enabled = true
	if haggle_points_processed == _haggle_target.npc.stubborness:
		# Minigame has finished
		finalize_sale()
		return
	
	if _haggle_points.size() == 0:
		haggle_cursor_animator.play("miss")
		update_haggle_score(-1)
		SoundManager.instance.play_sfx("menu_cancel")
	else:
		for point in _haggle_points:
			point.explode()
			update_haggle_score(1)
		_haggle_points.clear()
		SoundManager.instance.play_sfx("menu_accept")

func update_haggle_score(dir: int) -> void:
	haggle_score += dir
	haggle_score = max(haggle_score, 0)
	update_haggle_price()
	if dir >= 0:
		haggle_points_processed += 1
	if haggle_points_processed == _haggle_target.npc.stubborness:
		target_price = haggle_price
		animator.play("negotiate-result")

func update_haggle_price() -> void:
	var current_ratio: float = haggle_score / (_haggle_target.npc.stubborness as float)
	haggle_price = base_price
	haggle_price += round((target_price - base_price) * current_ratio)
	haggle_label.text = "%s" % haggle_price

func spawn_haggle_point() -> void:
	_haggle_timer = lerp(MIN_HAGGLE_INTERVAL, MAX_HAGGLE_INTERVAL, randf())
	for i in range(0, _haggle_target.npc.stubborness):
		if _haggle_point_pool.get(i).is_spawnable():
			var speed: float = calculate_haggle_speed()
			_haggle_point_pool.get(i).spawn(speed)
			return
	# Finished spawning points
	is_haggle_points_spawning = false

func calculate_haggle_speed() -> float:
	var denominator: float = base_price * _haggle_target.npc.max_overpay_bias - base_price
	var ratio: float = (target_price - base_price) / denominator
	var min_speed: float = _haggle_target.npc.min_haggle_multiplier
	var max_speed: float = _haggle_target.npc.max_haggle_multiplier
	return min_speed + randf() * ratio * max_speed

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
	super()
	DialogManager.instance.enable_inputs()
	DialogManager.instance.play_random_quote(_haggle_target.npc.declined_quotes, "Aww...")

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
	SoundManager.instance.play_sfx("transaction")
	super()

func on_menu_shown() -> void:
	super()
	DialogManager.instance.set_speaker(_haggle_target.npc)
	DialogManager.instance.play_random_quote(_haggle_target.npc.inquiry_quotes, "Buying this!")

func update_price() -> void:
	for i in range(selection_options.size()):
		selection_options.get(i).text = ("%05d" % target_price)[i]
	
	var ratio : int = round(100 * target_price / (base_price as float))
	markup_label.text = "%s%%" % ratio

func set_npc(npc: NpcController) -> void:
	_haggle_target = npc
	base_price = _haggle_target._target_holder.item.price
	target_price = base_price
	
	item_root.visible = true
	item.texture = _haggle_target._target_holder.item.ui_texture

## Called this to finalize a sale.
func finalize_sale() -> void:
	StatusManager.instance.add_money(target_price)
	DialogManager.instance.enable_inputs()
	DialogManager.instance.play_random_quote(_haggle_target.npc.purchase_quotes, "Thanks!")
	is_haggle_minigame_active = false
	_haggle_target.purchase_item()
	_haggle_target = null
	item_root.visible = false
	SoundManager.instance.play_sfx("negotiation")
	hide_menu()

func _on_haggle_detector_area_entered(area: Area2D) -> void:
	_haggle_points.append(area)

func _on_haggle_detector_area_exited(area: Area2D) -> void:
	var index: int = _haggle_points.find(area)
	if index != -1:
		_haggle_points.remove_at(index)

func _on_haggle_end_area_entered(area: Area2D) -> void:
	area.explode(true)
	update_haggle_score(0)

func _on_haggle_cursor_animation_finished(_anim_name: StringName) -> void:
	haggle_cursor_animator.play("loop")
