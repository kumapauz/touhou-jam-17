### Handles the player controller.
extends CharacterBody3D
class_name PlayerController

static var instance: PlayerController

@export_group("Movement Settings")
@export var top_speed: float = 20.0
@export var traction: float = 20.0
@export var friction: float = 20.0
@export var turn_speed: float = 20.0

@export_group("Components")
@export var sprite : AnimatedSprite3D

@export_group("Debug Settings")
@export var debug_root: Node3D

var _spawn_transform: Transform3D
var move_speed: float
var move_angle: float
const TURNAROUND_ANGLE: float = PI * 0.75

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	_spawn_transform = transform

func _process(_delta: float) -> void:
	process_actions()

func _physics_process(delta: float) -> void:
	process_movement(delta)
	process_animation()

func process_actions() -> void:
	if !is_input_enabled():
		return
	
	process_interactable_objects()
	if Input.is_action_just_pressed("confirm") && is_instance_valid(_active_object):
		_active_object.interact()

func process_interactable_objects() -> void:
	if interactable_objects.size() == 0:
		return
	
	var closest_dist: float = INF
	var target_object: InteractableObject = _active_object
	if is_instance_valid(_active_object):
		if _active_object.is_selectable():
			closest_dist = _active_object.global_position.distance_squared_to(global_position)
		else:
			target_object = null
	for interactable in interactable_objects:
		if interactable == _active_object || !interactable.is_selectable():
			continue
		var dist: float = interactable.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			target_object = interactable
			closest_dist = dist
	if target_object != _active_object:
		set_active_interactable_object(target_object)

func set_active_interactable_object(new_interactable: InteractableObject) -> void:
	print("Interactable object set to %s" % new_interactable)
	if is_instance_valid(_active_object):
		_active_object.deselect()
	_active_object = new_interactable
	if is_instance_valid(_active_object):
		_active_object.select()

func process_movement(delta: float) -> void:
	if !is_input_enabled():
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

var _is_processing_inputs: bool
## Tracks whether the player is processing movement.
func is_input_enabled() -> bool:
	return _is_processing_inputs && !DialogManager.instance.is_dialog_active

func enable_movement() -> void:
	_is_processing_inputs = true

func disable_movement() -> void:
	_is_processing_inputs = false
	move_speed = 0
	# TODO Reset animations

func respawn() -> void:
	transform = _spawn_transform
	enable_movement()

####################
###Item Detection###
####################
var interactable_objects: Array[InteractableObject]
var _active_object: InteractableObject
func _on_item_detector_entered(area: Area3D) -> void:
	if area is InteractableObject:
		interactable_objects.append(area)
		print("Added interactable object")

func _on_item_detector_exited(area: Area3D) -> void:
	if area is InteractableObject:
		var index: int = interactable_objects.find(area)
		if index != -1:
			interactable_objects.remove_at(index)
			print("Removed interactable object")
			if interactable_objects.size() == 0:
				set_active_interactable_object(null)
