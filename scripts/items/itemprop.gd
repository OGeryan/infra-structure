extends CharacterBody3D

@export var Attributes : ItemAttributes

func _enter_tree() -> void:
	$Mesh.mesh = $Mesh.mesh.duplicate()
	$Mesh.mesh = Attributes.PropMesh
	$Mesh.scale = Attributes.PropSize
	$Mesh.rotation_degrees = Attributes.PropRotation
	$CollisionShape3D.shape = $CollisionShape3D.shape.duplicate()
	$CollisionShape3D.shape.size = Attributes.CollSize

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += -9.81*delta
	move_and_slide()
