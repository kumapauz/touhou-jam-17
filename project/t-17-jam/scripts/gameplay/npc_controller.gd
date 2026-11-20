extends Node3D
class_name NpcController

@export var npc: NpcResource

@export_group("Components")
@export var sprites: AnimatedSprite3D

## The item holder this player is moving towards.
var _target_holder: ItemHolder
var current_path: PackedVector2Array
var current_path_index: int
var is_active: bool
var path_t : float
const MOVE_SPEED: float = 5.0

func _physics_process(delta: float) -> void:
	if !is_active:
		return
	
	if current_path_index >= current_path.size() - 1:
		sprites.play("idle")
		# Reached end of path
		return
	
	sprites.play("walk")
	var init_pos: Vector2 = current_path.get(current_path_index)
	var next_pos: Vector2 = current_path.get(current_path_index + 1)
	path_t = move_toward(path_t, 1.0, MOVE_SPEED * delta)
	var current_pos: Vector2 = init_pos.lerp(next_pos, path_t)
	position = Vector3(current_pos.x, 0, current_pos.y) + Vector3.LEFT * 3
	
	if is_equal_approx(path_t, 1.0):
		path_t = 0.0
		current_path_index += 1

func set_npc(new_npc: NpcResource) -> void:
	npc = new_npc
	if is_instance_valid(npc):
		sprites.sprite_frames = npc.sprite_frames

func set_path(path: PackedVector2Array) -> void:
	current_path = path
	current_path_index = 0
	path_t = 0

func is_preferred_item(item: ItemResource) -> bool:
	if is_instance_valid(npc):
		return npc.preferred_items.has(item)
	return false

func is_disliked_item(item: ItemResource) -> bool:
	if is_instance_valid(npc):
		return npc.disliked_items.has(item)
	return false

func set_target_holder(holder: ItemHolder) -> void:
	_target_holder = holder

## Activates this NPC.
func activate() -> void:
	visible = true
	is_active = true
	process_mode = Node.PROCESS_MODE_INHERIT

## Dectivates this NPC.
func deactivate() -> void:
	visible = false
	is_active = false
	process_mode = Node.PROCESS_MODE_DISABLED
