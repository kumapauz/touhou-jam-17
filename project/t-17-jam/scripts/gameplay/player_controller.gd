### Handles the player controller.
extends CharacterBody3D

@export_group("Movement Settings")
@export var top_speed: float = 20.0
@export var traction: float = 20.0
@export var friction: float = 20.0
@export var turn_speed: float = 20.0

@export_group("Components")
@export var sprite : AnimatedSprite3D

@export_group("Debug Settings")
@export var debug_root: Node3D

var move_speed: float
var move_angle: float
const TURNAROUND_ANGLE: float = PI * 0.75

func _ready() -> void:
	enable_movement()

func _process(_delta: float) -> void:
	process_actions()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_animation()

func process_actions() -> void:
	if !is_input_enabled || DialogManager.instance.is_dialog_active:
		return
	
	process_item_holders()
	if Input.is_action_just_pressed("confirm") && is_instance_valid(_active_item_holder):
		# Open inventory menu
		var menu_settings := InventoryManager.MenuSettings.new()
		menu_settings.allow_selecting_nothing = true
		InventoryManager.instance.show_menu(menu_settings)
		InventoryManager.instance.item_selected.connect(Callable.create(self, "on_inventory_selected"), CONNECT_ONE_SHOT)
		InventoryManager.instance.menu_hidden.connect(Callable.create(self, "on_inventory_hidden"), CONNECT_ONE_SHOT)
		disable_movement()

func process_item_holders() -> void:
	if item_holders.size() == 0:
		return
	
	var closest_dist: float = INF
	var target_item_holder: ItemHolder = _active_item_holder
	if is_instance_valid(_active_item_holder):
		closest_dist = _active_item_holder.global_position.distance_squared_to(global_position)
	for holder in item_holders:
		if holder == _active_item_holder:
			continue
		var dist: float = holder.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			target_item_holder = holder
			closest_dist = dist
	if target_item_holder != _active_item_holder:
		set_active_item_holder(target_item_holder)

func set_active_item_holder(new_holder: ItemHolder) -> void:
	print("Item holder set to %s" % new_holder)
	if is_instance_valid(_active_item_holder):
		_active_item_holder.deselect_holder()
	_active_item_holder = new_holder
	if is_instance_valid(_active_item_holder):
		_active_item_holder.select_holder()

func on_inventory_selected(item: ItemResource) -> void:
	InventoryManager.instance.remove_item(item)
	_active_item_holder.set_item(item)

func on_inventory_hidden() -> void:
	for connection in InventoryManager.instance.item_selected.get_connections():
		InventoryManager.instance.item_selected.disconnect(connection["callable"])
	enable_movement()

func process_movement(delta: float) -> void:
	if !is_input_enabled || DialogManager.instance.is_dialog_active:
		return
	
	var input: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up")).limit_length()
	var input_length: float = input.length()
	var input_angle: float = input.angle()
	if is_braking(input_angle, input_length):
		move_speed = move_toward(move_speed, 0, friction * delta)
	else:
		process_turning(input_angle, delta)
		process_speed(input_length, delta)
	apply_velocity()

func process_animation() -> void:
	sprite.play("idle" if is_zero_approx(move_speed) else "walk")
	var delta_angle: float = abs(angle_difference(move_angle, 0))
	if (sprite.flip_h && delta_angle < PI * 0.4) || (!sprite.flip_h && delta_angle > PI * 0.6):
		flip_sprite()

func flip_sprite() -> void:
	sprite.flip_h = !sprite.flip_h

func process_speed(length: float, delta: float) -> void:
	move_speed = move_toward(move_speed, top_speed * length, traction * delta)

func process_turning(angle: float, delta: float) -> void:
	if is_zero_approx(move_speed):
		move_angle = angle
	else:
		move_angle = rotate_toward(move_angle, angle, turn_speed * delta)
	debug_root.rotation = Vector3.UP * move_angle

func is_braking(angle: float, length: float) -> bool:
	if is_zero_approx(length):
		return true
	return !is_zero_approx(move_speed) && abs(angle_difference(angle, move_angle)) > TURNAROUND_ANGLE

func apply_velocity() -> void:
	velocity = Vector3.RIGHT.rotated(Vector3.UP, move_angle) * move_speed
	move_and_slide()

## Tracks whether the player is processing movement.
var is_input_enabled: bool
func enable_movement() -> void:
	is_input_enabled = true

func disable_movement() -> void:
	is_input_enabled = false
	move_speed = 0
	# TODO Reset animations

####################
###Item Detection###
####################
var item_holders: Array[ItemHolder]
var _active_item_holder: ItemHolder
func _on_item_detector_entered(area: Area3D) -> void:
	if area is ItemHolder:
		item_holders.append(area)
		print("Added item holder")

func _on_item_detector_exited(area: Area3D) -> void:
	if area is ItemHolder:
		var index: int = item_holders.find(area)
		if index != -1:
			item_holders.remove_at(index)
			print("Removed item holder")
			if item_holders.size() == 0:
				set_active_item_holder(null)
