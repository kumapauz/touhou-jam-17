extends Node3D
class_name NpcController

@export var npc: NpcResource

@export_group("Components")
@export var sprites: AnimatedSprite3D
var current_grid_pos: Vector2
var current_path: PackedVector2Array
var current_path_index: int

func set_npc(new_npc: NpcResource) -> void:
	npc = new_npc
	if is_instance_valid(npc):
		sprites.sprite_frames = npc.sprite_frames

func set_path(path: PackedVector2Array) -> void:
	current_path = path
	current_path_index = 0

## Activates this NPC.
func activate() -> void:
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT

## Dectivates this NPC.
func deactivate() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
