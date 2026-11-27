class_name TownData
extends Resource

var save_path: String = "res://save_data/town_save.tres"
# man i wish I could put this into one datastructure that makes sense
#var structures:Array[StructureData]
@export var structures:Array[StructureData] = []

func clear_town_data():
	structures.clear()
	# just save_structure for all of them

func save_structure(struct:Structure, transform:Transform3D):
	var save_struct: StructureData = StructureData.new()
	save_struct.structure = struct
	save_struct.transform = transform
	structures.append(save_struct)

func save_town():
	ResourceSaver.save(self, save_path)

func load_town() -> void:
	var data = ResourceLoader.load(save_path)
	if data:
		structures = data.structures

# to be iterated on for the length of the arrays
# still needs to be instanced at the target location
func load_structure(index:int) -> Node3D:
	return structures.get(index)
