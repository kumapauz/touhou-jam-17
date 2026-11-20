## Handles the camera controller.
extends Camera3D

@export var player: Node3D
@export var distance: float = 10.0
@export var room_boundaries: Rect2
@export var height_offset: float = 1.0

func _physics_process(_delta: float) -> void:
	global_position = player.global_position + global_basis.z * distance
	global_position += Vector3.UP * height_offset
