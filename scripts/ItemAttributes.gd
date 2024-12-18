extends Resource
class_name ItemAttributes

enum ActionTypes {NONE=0, LINETRACE=1, DYNAMITE=2}
enum LineTraceTypes {DAMAGE=0, HAMMER=1}

@export var Name = "cucc"
@export var Icon : Texture = preload("res://icon.svg") 
@export var UseRef : PackedScene = load("res://scripts/items/default_itemprop.tscn")
@export var EquipTimeMultiplier = 2.0

@export var PropMesh : Mesh
@export var Prop = {
	"size": Vector3(1.0, 1.0, 1.0),
	"rotation": Vector3(0, 0, 0),
	"collision": Vector3(1.0, 1.0, 1.0)
}

@export var ViewmodelMesh : Mesh
@export var Viewmodel = {
	"offset": Vector3(0, 0, 0),
	"rotation": Vector3(0, 0, 0),
	"size": Vector3(1.0, 1.0, 1.0),
	"animationset": null
}
@export var PickupSound : AudioStream = preload("res://audio/sfx_grab.tres")

@export var Anims = {
	"idle":"vm_toolidle1",
	"equip":"vm_toolequip",
	"action1":"vm_toolattack",
	"reload":"vm_toolattack"
}
@export var Consume_OnAction = false
@export var Action1 : ActionTypes = ActionTypes.NONE
@export var LTType : LineTraceTypes = LineTraceTypes.DAMAGE
@export var LTRange : float = 2.5
@export var Power : float = 1
@export var PowerMultipliers = {
	null:1,
	"wood":1,
	"metal":1,
	"flesh":1,
	"armored":0.5,
	"vulnerable":2
}
@export var Action1Interval = 1.0

@export var Amount = 1
@export var Stack = 1


func F_SpawnItem(Pos : Vector3, Old : ItemAttributes, spawner : Node3D, RanRot = 0):
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
	New.rotation_degrees.y = randf_range(0, RanRot)
	return New
