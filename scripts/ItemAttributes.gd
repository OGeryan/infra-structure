extends Resource
class_name ItemAttributes

@export var Name = "cucc"
@export var Icon : Texture = preload("res://icon.svg") 
@export var UseRef : PackedScene = load("res://scripts/items/default_itemprop.tscn")
@export var EquipTimeMultiplier = 2.0
@export var PropMesh : Mesh
@export var PropSize = Vector3(1.0, 1.0, 1.0)
@export var PropRotation = Vector3(0, 0, 0)
@export var CollSize = Vector3(1.0, 1.0, 1.0)

@export var Amount = 1
@export var Stack = 1


func F_SpawnItem(Pos : Vector3, Old : ItemAttributes, spawner : Node3D):
	var New = load("res://scripts/items/default_itemprop.tscn").instantiate()
	if "Attributes" in New:
		New.Attributes = Old
	"""
	New.get_node("Mesh").mesh = Old.PropMesh
	New.get_node("Mesh").scale = Old.PropSize
	New.get_node("Mesh").rotation_degrees = Old.PropRotation
	New.get_node("CollisionShape3D").shape.size = Old.CollSize
	"""
	spawner.get_tree().root.get_child(0).add_child(New)
	New.global_position = Pos
