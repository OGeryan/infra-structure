extends Node3D

var Config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Data = Config.load("user://rules.cfg")
	if Data != OK:
		Config.set_value("Generation", "Width", 64)
		Config.set_value("Generation", "Height", 512)
		Config.set_value("Generation", "Amount", 0.2)
		Config.set_value("Generation", "Scarce", 5)
		Config.set_value("Generation", "Theme", 0)
		Config.save("user://rules.cfg")
	F_Generate()

func F_Generate():
	var W = float(Config.get_value("Generation", "Width"))
	var H = float(Config.get_value("Generation", "Height"))
	var A = float(Config.get_value("Generation", "Amount"))
	var T = float(Config.get_value("Generation", "Theme"))
	var S = float(Config.get_value("Generation", "Scarce"))
	
	var NatureTree : PackedScene = preload("res://scenes/nature_tree.tscn")
	var NatureMetal : PackedScene = preload("res://scenes/nature_metal.tscn")
	var NatureBorder : PackedScene = preload("res://scenes/boundaryhills_1.tscn")
	match int(T):
		0:
			NatureTree = preload("res://scenes/nature_tree.tscn")
		1:
			print(T)
			NatureTree = preload("res://scenes/nature_cactus.tscn")
			NatureBorder = null
			$GROUND.set_surface_override_material(0, preload("res://surfaces/sand_mat1.tres"))
			$GROUND/StaticBody3D.set_meta("surface", "sand")
	
	if NatureBorder:
		for m in [-1, 1]:
			for p in range(-H*3, H*3, 99):
				var Add = NatureBorder.instantiate()
				add_child(Add)
				Add.global_position = Vector3(W/2*m + randf_range(-0.0075, 0.0075), 5, p)
				Add.rotation.y = deg_to_rad(0) if m < 0.5 else deg_to_rad(180)

	for py in range(-H*1.5, H*1.5, S):
		for px in range(-W/2, W/2, S):
			var R : Node3D = null
			if randf_range(0, 1) < A and abs(py) > 12: 
				if abs(px) > (W * 0.35) and randf_range(0, 1) > 0.4: #metals
					R = NatureMetal.instantiate()
				else: # wood
					R = NatureTree.instantiate()
				add_child(R)
				R.position.x = px + randf_range(-S/5, S/5)
				R.position.z = py + randf_range(-S/5, S/5)
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
