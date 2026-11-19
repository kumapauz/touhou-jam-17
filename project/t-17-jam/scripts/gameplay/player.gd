### Handles the player controller.
extends CharacterBody3D

@export_group("Movement Settings")
@export var top_speed: float = 20.0
@export var traction: float = 20.0
@export var friction: float = 20.0
@export var turn_speed: float = 20.0

@export_group("Debug Settings")
@export var debug_root: Node3D

var move_speed: float
var move_angle: float
const TURNAROUND_ANGLE: float = PI * 0.75

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var input: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up")).limit_length()
	var input_length: float = input.length()
	var input_angle: float = input.angle()
	if is_braking(input_angle, input_length):
		move_speed = move_toward(move_speed, 0, friction * delta)
	else:
		process_turning(input_angle, delta)
		process_speed(input_length, delta)
	apply_velocity()

func process_speed(length: float, delta: float) -> void:
	move_speed = move_toward(move_speed, top_speed * length, traction * delta)

func process_turning(angle: float, delta: float) -> void:
	if is_zero_approx(move_speed):
		move_angle = angle
	else:
		move_angle = rotate_toward(move_angle, angle, turn_speed * delta)

func is_braking(angle: float, length: float) -> bool:
	if is_zero_approx(length):
		return true
	return !is_zero_approx(move_speed) && abs(angle_difference(angle, move_angle)) > TURNAROUND_ANGLE

func apply_velocity() -> void:
	velocity = Vector3.RIGHT.rotated(Vector3.UP, move_angle) * move_speed
	debug_root.rotation = Vector3.UP * move_angle
	move_and_slide()
