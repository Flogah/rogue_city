class_name TownData
extends Resource

# man i wish I could put this into one datastructure that makes sense
var structures:Array[StructureData]

func save_town():
	structures.clear()
	# just save_structure for all of them

func load_town() -> Array:
	return structures

func save_structure(struct:Structure, transfrom:Transform3D):
	var save_struct: StructureData = StructureData.new()
	save_struct.structure = struct
	save_struct.transform = transfrom
	structures.append(save_struct)

# to be iterated on for the length of the arrays
# still needs to be instanced at the target location
func load_structure(index:int) -> Node3D:
	return structures.get(index)
