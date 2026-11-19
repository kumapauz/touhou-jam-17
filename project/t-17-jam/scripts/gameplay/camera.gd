## Handles the camera controller.
extends Camera3D

@export var player: Node3D
@export var distance: float = 10.0
@export var room_boundaries: Rect2

func _physics_process(_delta: float) -> void:
	global_position = player.global_position + global_basis.z * distance
