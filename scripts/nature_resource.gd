extends Node3D

@export var AltMeshes : Array[Mesh]
@export var HitPoints = 5
@export var HitLayer = "wood"
@export var YRNGOffset = 0.0
@export var SpawnResource : ItemAttributes
@export var DestroySFX : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AltMeshes.append($StaticBody3D/MeshInstance3D.mesh)
	$StaticBody3D/MeshInstance3D.mesh = AltMeshes.pick_random()
	global_rotation_degrees.y = randf_range(0, 360)
	var RNGScale = randf_range(1, 1.1)
	var RNGScaleXZ = randf_range(0.8, 1)
	scale = Vector3(RNGScaleXZ, RNGScale, RNGScaleXZ)
	position.y += randf_range(0, YRNGOffset)

func F_Damage(P : float):
	if HitPoints <= 0:
		return
	HitPoints -= P
	$Label3D/AnimationPlayer.stop()
	$Label3D.text = str(int(HitPoints))
	$Label3D/AnimationPlayer.play("hit")
	if HitPoints <= 0:
		F_Destroy() 
	
func F_Destroy():
	if has_node("SPAWNITEMS"):
		for i in $SPAWNITEMS.get_children():
			SpawnResource.F_SpawnItem(i.global_position, SpawnResource, self, 360)
	if DestroySFX:
		var SFX = AudioManager.F_QuickPlaySound(DestroySFX, get_tree().root.get_child(0), 2)
		SFX.global_position = global_position
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
