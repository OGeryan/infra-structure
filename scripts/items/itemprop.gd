extends CharacterBody3D

@export var Attributes : ItemAttributes
var Hover = false

func _enter_tree() -> void:
	$Mesh.mesh = $Mesh.mesh.duplicate()
	Attributes = Attributes.duplicate(true)
	$Mesh.mesh = Attributes.PropMesh
	$Mesh.scale = Attributes.Prop["size"]
	$Mesh.rotation_degrees = Attributes.Prop["rotation"]
	$CollisionShape3D.shape = $CollisionShape3D.shape.duplicate()
	$CollisionShape3D.shape.size = Attributes.Prop["collision"]

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += -9.81*delta
	velocity.x = lerpf(velocity.x, 0, delta*5)
	velocity.z = lerpf(velocity.z, 0, delta*5)
	move_and_slide()
		
