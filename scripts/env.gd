extends WorldEnvironment

@export var CycleTime = 0.0
@export var TimeSpeed = 0.001
@export var Light : DirectionalLight3D
@export var DayLight : Curve

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	CycleTime += TimeSpeed*delta
	if CycleTime >= 1:
		CycleTime = 0
	if Light != null:
		var T : float = DayLight.sample(CycleTime)
		Light.light_energy = T
		Light.light_color = Color(1, lerp(0.5,1.0,T), lerp(0.0,1.0,T))
		environment.background_energy_multiplier = T + .00
		Light.rotation_degrees.x = lerp(0, 360, remap(CycleTime, 0, 1, 1, 0))
	
