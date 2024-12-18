extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func F_QuickPlayFX_Explosive(Mat: ParticleProcessMaterial, T : Texture = load("res://img/particle_a.png"), Pos: Vector3 = Vector3(0,0,0), Parent: Node = get_tree().root.get_child(0)):
	var New = preload("res://scenes/explode_particle.tscn").instantiate()
	New.draw_pass_1.surface_get_material(0).albedo_texture = T
	Parent.add_child(New)
	New.global_position = Pos
	New.process_material = Mat
	New.emitting = true
	
