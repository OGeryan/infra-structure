extends Node3D

@onready var MetalBuildOrder : Array[Node3D] = [$Metal1, $Metal2]
@onready var PlankBuildOrder : Array[Node3D] = [$Plank1, $Plank2, $Plank3, $Plank4, $Plank5]

var Finished = false
@export var NoContinue = false
@export var Buildable = true

var MetalProgress = 0:
	set(x):
		for n in range(0, len(MetalBuildOrder)):
			if n == x:
				MetalBuildOrder[n].transparency = 0.2
				MetalBuildOrder[n].cast_shadow = false
			elif n < x:
				MetalBuildOrder[n].transparency = 0.0
				MetalBuildOrder[n].cast_shadow = true
			else:
				MetalBuildOrder[n].transparency = 1.0
				MetalBuildOrder[n].cast_shadow = false
		MetalProgress = x
var PlankProgress = 0:
		set(x):
			for n in range(0, len(PlankBuildOrder)):
				if n == x:
					PlankBuildOrder[n].transparency = 0.2
					PlankBuildOrder[n].cast_shadow = false
				elif n < x:
					PlankBuildOrder[n].transparency = 0.0
					PlankBuildOrder[n].cast_shadow = true
				else:
					PlankBuildOrder[n].transparency = 1.0
					PlankBuildOrder[n].cast_shadow = false
			PlankProgress = x
					
@export var Built = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Built:
		MetalProgress = MetalProgress
		PlankProgress = PlankProgress
	else:
		MetalProgress = len(MetalBuildOrder)
		PlankProgress = len(PlankBuildOrder)
		call_deferred("F_Finished")
	call_deferred("F_UpdateBuildCollision")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func F_Hammer(R: Dictionary, Player : Node3D):
	if !Buildable:
		return
	if Player:
		if R["metal"] >= 1 and MetalProgress < len(MetalBuildOrder):
			Player.F_ConsumeItem("steel", R["metal"])
			MetalProgress+=1
		elif R["wood"] >= 1 and PlankProgress < len(PlankBuildOrder):
			Player.F_ConsumeItem("lumber", R["wood"])
			PlankProgress+=1
	if PlankProgress == len(PlankBuildOrder)-1 and MetalProgress == len(MetalBuildOrder)-1 and !Finished:
		F_Finished()

func F_Finished():
	if NoContinue:
		return
	if get_parent().is_in_group("RailManager"):
		var New = preload("res://scenes/rail.tscn").instantiate()
		get_parent().add_child(New)
		New.global_position = $NextSpot.global_position
		Finished = true
		
func F_UpdateBuildCollision(Body: Node = null):
	if !$CanBuild.has_node("Sprite3D"):
		return
	if len($CanBuild.get_overlapping_bodies()) > 0:
		Buildable = false
	else:
		Buildable = true
	$CanBuild/Sprite3D.visible = !Buildable
	if Built:
		$CanBuild/Sprite3D.queue_free()
