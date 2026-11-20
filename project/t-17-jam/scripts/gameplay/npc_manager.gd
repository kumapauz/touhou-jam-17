## Manages spawning NPCs and giving them places to go.
extends Node3D

## Maximum number of npcs at the start
@export var max_npcs: int = 5

@export_dir var npc_resource_path: String
var _npc_resources : Array[NpcResource]
@export var npc_scene: PackedScene

@export_group("Components")
@export var npc_parent: Node3D
@export var item_holder_parent: Node3D
var _item_holders: Array[ItemHolder]

var _npc_pool: Array[NpcController]
# A top-down view of the pathfinding grid.
var astar_grid: AStarGrid2D
var _is_grid_initialized: bool
const RAYCAST_DISTANCE: int = 5

func _ready() -> void:
	init_npc_pool()
	init_npc_resources()
	init_item_holder(item_holder_parent)

## Recursively get all item holders.
func init_item_holder(root: Node) -> void:
	for child in root.get_children():
		if child is ItemHolder:
			_item_holders.append(child)
		init_item_holder(child)

func spawn_npcs() -> void:
	for i in range(_npc_pool.size()):
		if !spawn_npc():
			break

## Spawns a single NPC.
func spawn_npc() -> bool:
	if _npc_pool.back().is_active:
		# No more NPCs to spawn
		return false
	var npc: NpcController = _npc_pool.pop_back()
	npc.set_npc(request_npc())
	npc.activate()
	npc.position = Vector3.ZERO
	npc.set_path(request_path(npc))
	_npc_pool.push_front(npc)
	return true

func _process(_delta: float) -> void:
	if !_is_grid_initialized:
		init_pathfinding()
		return
	
	if Input.is_action_just_pressed("ui_copy"):
		spawn_npc()

## Creates npc nodes.
func init_npc_pool() -> void:
	for i in range(max_npcs):
		var npc: NpcController = npc_scene.instantiate()
		_npc_pool.append(npc)
		npc_parent.add_child(npc)
		npc.position = Vector3.ZERO
		npc.deactivate()

func init_npc_resources() -> void:
	for resource_file in ResourceLoader.list_directory(npc_resource_path):
		var file_path: String = npc_resource_path.path_join(resource_file)
		var res: NpcResource = ResourceLoader.load(file_path)
		_npc_resources.append(res)

## Creates the AStar grid for pathfinding
func init_pathfinding() -> void:
	astar_grid = AStarGrid2D.new()
	# Initialize cell size
	astar_grid.region = Rect2i(0, 0, 23, 9)
	astar_grid.cell_size = Vector2.ONE
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	for x in range(astar_grid.region.position.x, astar_grid.region.size.x):
		for y in range(astar_grid.region.position.y, astar_grid.region.size.y):
			var to_pos: Vector3 = convert_grid_to_world_pos(Vector2i(x, y))
			var from_pos: Vector3 = to_pos + Vector3.UP * RAYCAST_DISTANCE
			var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from_pos, to_pos, 1)
			params.collide_with_areas = false
			var hit: Dictionary = space.intersect_ray(params)
			if !hit.has("position"):
				continue
			
			var col_point: Vector3 = hit["position"]
			if !is_equal_approx(global_position.y, col_point.y):
				var grid_point: Vector2i = convert_world_to_grid_pos(col_point)
				astar_grid.set_point_solid(grid_point)
				print("Set %s/%s solid" % [grid_point, col_point])
	
	_is_grid_initialized = true

## Constructs a Vector3 cooresponding to the given grid position.
func convert_grid_to_world_pos(grid_pos: Vector2i) -> Vector3:
	return global_position + Vector3(grid_pos.x, 0, grid_pos.y)

## Rounds the world position to the closest grid position.
func convert_world_to_grid_pos(world_pos: Vector3) -> Vector2i:
	var local_pos: Vector3i = to_local(world_pos).round()
	return Vector2i(local_pos.x, local_pos.z)

var PREFERRED_ITEM_CHANCE: int = 10
var NORMAL_ITEM_CHANCE: int = 5
var DISLIKED_ITEM_CHANCE: int = 1

## Gets a path for the given NPC.
func request_path(npc: NpcController) -> PackedVector2Array:
	var valid_items: Array[ItemHolder]
	for item_holder in _item_holders:
		if !item_holder.has_item():
			continue
		var chance: int = NORMAL_ITEM_CHANCE
		if npc.is_preferred_item(item_holder.item):
			chance = PREFERRED_ITEM_CHANCE
		elif npc.is_disliked_item(item_holder.item):
			chance = DISLIKED_ITEM_CHANCE
		for i in range(chance):
			valid_items.append(item_holder)
	
	var start_pos: Vector2i = convert_world_to_grid_pos(npc.global_position)
	# Default behavior: Head to the door and leave
	var end_pos: Vector2i = convert_world_to_grid_pos(global_position)
	if valid_items.size() != 0:
		var target_item: ItemHolder = valid_items.get(randi_range(0, valid_items.size() - 1))
		npc.set_target_holder(target_item)
		end_pos = convert_world_to_grid_pos(target_item.global_position)
	else:
		npc.set_target_holder(null)
	return astar_grid.get_point_path(start_pos, end_pos, true)

## Return a random npc, ensuring that no repeat characters are allowed.
func request_npc() -> NpcResource:
	var valid_npcs: Array[NpcResource] = _npc_resources.duplicate()
	for npc in _npc_pool:
		if !npc.is_active || !is_instance_valid(npc.npc) || npc.npc.npc_type == NpcResource.NPC_TYPE.MOB:
			continue
		
		var index: int = valid_npcs.find(npc.npc)
		if index == -1:
			valid_npcs.remove_at(index)
	var selection: int = randi_range(0, valid_npcs.size() - 1)
	return valid_npcs.get(selection)
