extends Area2D

@export var animator: AnimationPlayer

var speed: float
const BASE_SPEED: float = 250.0

var state: STATE
enum STATE {
	INACTIVE,
	ACTIVE,
	EXPLODED
}

func is_spawnable() -> bool:
	return state == STATE.INACTIVE

func is_active() -> bool:
	return state == STATE.ACTIVE

func process_point(delta: float) -> void:
	position += Vector2.RIGHT * delta * BASE_SPEED * speed

func respawn() -> void:
	state = STATE.INACTIVE

func spawn(spd: float) -> void:
	state = STATE.ACTIVE
	position = Vector2.ZERO
	speed = spd
	animator.play("spawn")

func explode(failed: bool = false) -> void:
	state = STATE.EXPLODED
	animator.play("fail" if failed else "explode")
