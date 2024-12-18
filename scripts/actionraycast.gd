extends Node3D

func F_Cast(Type, Length = 3.5, Value = 1.0, Cam = null, Multipliers = {}, Source : Node3D = get_parent()):
	$RayCast3D.target_position = Vector3(0, 0, -Length)
	$RayCast3D.force_raycast_update()	
	if $RayCast3D.get_collider():
		var Hit = $RayCast3D.get_collider()
		match Type:
			0:
				print(str("hit - ", Hit))
				if Cam:
					Cam.Magnitude = .05
					Cam.Period = 0.1
					Cam.F_CameraShake()
				var Surface = ""
				if !Hit.has_meta("surface"):
					Surface = ""
				else:
					Surface = Hit.get_meta("surface")
				match Surface:
					"stone":
						AudioManager.F_QuickPlaySound(preload("res://audio/sfx_minerock.tres"), self)
						ParticleManager.F_QuickPlayFX_Explosive(preload("res://img/explosive_metal.tres"), preload("res://img/particle_b.png"), $RayCast3D.get_collision_point())
					"wood":
						AudioManager.F_QuickPlaySound(preload("res://audio/sfx_chopwood.tres"), self)
						ParticleManager.F_QuickPlayFX_Explosive(preload("res://img/explosive_wood.tres"), preload("res://img/particle_a.png"), $RayCast3D.get_collision_point())
					_:
						AudioManager.F_QuickPlaySound(preload("res://audio/sfx_hitgeneric.tres"), self)
						ParticleManager.F_QuickPlayFX_Explosive(preload("res://img/explosive_generic.tres"), preload("res://img/particle_b.png"), $RayCast3D.get_collision_point())
				if Hit.get_parent().has_method("F_Damage"):
					Hit.get_parent().F_Damage(Value * Multipliers[Hit.get_parent().HitLayer])
			1:
				print(str("hammer - "), Hit)
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_hithammer.tres"), self)
				if Hit.get_parent().has_method("F_Hammer"):
					ParticleManager.F_QuickPlayFX_Explosive(preload("res://img/explosive_build.tres"), preload("res://img/particle_d.png"), $RayCast3D.get_collision_point())
					Hit.get_parent().F_Hammer(Multipliers, Source)
				elif Hit.get_parent().has_method("F_Damage"):
					Hit.get_parent().F_Damage(Value * Multipliers[Hit.get_parent().HitLayer])
