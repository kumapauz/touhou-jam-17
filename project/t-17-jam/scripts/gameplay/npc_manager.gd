## Manages spawning NPCs and giving them places to go.
extends Node3D

## Maximum number of npcs at the start
@export var max_npcs: int = 5

@export_dir var npc_resource_path: String
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
const GRID_OFFSET: Vector2i = Vector2i(-3, 0)

func _ready() -> void:
	init_npc_pool()
	init_item_holder(item_holder_parent)

## Recursively get all item holders.
func init_item_holder(root: Node) -> void:
	for child in root.get_children():
		if child is ItemHolder:
			_item_holders.append(child)
		init_item_holder(child)

func _process(_delta: float) -> void:
	if !_is_grid_initialized:
		init_pathfinding()

## Creates npc nodes.
func init_npc_pool() -> void:
	for i in range(max_npcs):
		var npc: NpcController = npc_scene.instantiate()
		_npc_pool.append(npc)
		npc_parent.add_child(npc)
		npc.deactivate()

## Creates the AStar grid for pathfinding
func init_pathfinding() -> void:
	astar_grid = AStarGrid2D.new()
	# Initialize cell size
	astar_grid.region = Rect2i(0, 0, 23, 8)
	astar_grid.cell_size = Vector2.ONE
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
	#print(astar_grid.get_id_path(Vector2i(0, 0), Vector2i(3, 4))) # Prints [(0, 0), (1, 1), (2, 2), (3, 3), (3, 4)]
	#print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4))) # Prints [(0, 0), (16, 16), (32, 32), (48, 48), (48, 64)]

## Constructs a Vector3 cooresponding to the given grid position.
func convert_grid_to_world_pos(grid_pos: Vector2i) -> Vector3:
	grid_pos -= GRID_OFFSET
	return global_position + Vector3(grid_pos.x, 0, grid_pos.y)

## Rounds the world position to the closest grid position.
func convert_world_to_grid_pos(world_pos: Vector3) -> Vector2i:
	var local_pos: Vector3i = to_local(world_pos).round()
	return Vector2i(local_pos.x, local_pos.z) + GRID_OFFSET
