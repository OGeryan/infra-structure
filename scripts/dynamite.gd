extends CharacterBody3D

@export var Damage = 5

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += -9.81*delta
	velocity.x = lerpf(velocity.x, 0, delta*5)
	velocity.z = lerpf(velocity.z, 0, delta*5)
	move_and_slide()


func F_Detonate() -> void:
	var SFX = AudioManager.F_QuickPlaySound(preload("res://audio/sfx_explosion_dynamite.tres"), get_tree().root.get_child(0), 3)
	SFX.global_position = global_position
	$Kaboom.emitting = true
	$Kaboom.reparent(get_parent())
	var Hit = $Radius.get_overlapping_bodies()
	for i in Hit:
		if i.get_parent().has_method("F_Damage"):
			i.get_parent().F_Damage(Damage)
	queue_free()
	
