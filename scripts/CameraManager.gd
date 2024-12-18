extends Camera3D

@export var Period = 0.1
@export var Magnitude = 0.1

func F_CameraShake():
	var initial_transform = self.transform 
	var T = 0.0

	while T < Period:
		var Offset = Vector3(randf_range(-Magnitude, Magnitude),randf_range(-Magnitude, Magnitude),0.0)

		self.transform.origin = initial_transform.origin + Offset
		T += get_process_delta_time()
		await get_tree().process_frame
	self.transform = initial_transform
