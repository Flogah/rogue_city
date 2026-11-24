@tool
extends Node3D
class_name Dungeon

@export var dimensions: Vector3i = Vector3i(10,10,10)
@export var start_coords: Vector3i = Vector3i(0,5,5)
@export var path_length: int = 10

var dungeon: Array


func _ready() -> void:
	init_dungeon()
	create_main_path(start_coords, path_length)
	build_dungeon()
	
func init_dungeon() -> void:
	for x in dimensions.x:
		dungeon.append([])
		for y in dimensions.y:
			dungeon[x].append([])
			for z in dimensions.z:
				dungeon[x][y].append(0)

func create_main_path(start: Vector3i, length: int) -> bool:
	if length == 0: return true
	var current: Vector3i = start
	var direction: Vector3i
	direction = get_random_direction()
	var target_tile: Vector3i = Vector3i(current.x, current.y, current.z) + direction
	if is_tile_unoccupied(target_tile) and is_tile_within_dungeon(target_tile):
		current += direction
		dungeon[current.x][current.y][current.z] = length
		if create_main_path(current, length-1):
			return true
		else:
			dungeon[current.x][current.y][current.z] = 0
			current -= direction
		direction = Vector3i(direction.y, -direction.x, direction.z)
	return false

func build_dungeon() -> void:
	pass
	

func is_tile_within_dungeon(coord: Vector3i) -> bool:
	return(coord.x >= 0 && coord.x <= dimensions.x && coord.y >= 0 && coord.y <= dimensions.x && coord.z >= 0 && coord.z <= dimensions.x)

func is_tile_unoccupied(coord: Vector3i) -> bool:
	return (dungeon[coord.x][coord.y][coord.z] == 0)

func get_random_direction() -> Vector3i:
	match randi_range(0,4):
		0:
			return Vector3i.FORWARD
		1:
			return Vector3i.RIGHT
		2:
			return Vector3i.BACK
		3:
			return Vector3i.LEFT
		4:
			match randi_range(0,1):
				0:
					return Vector3i.UP
				1:
					return Vector3i.DOWN
	return Vector3i.FORWARD
