extends Control

var Pos = Vector2(0,0)
var Direction = -90

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	F_Structure()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func F_Structure():
	Pos.x = 0
	if Pos.x > 1:
		Direction = 90
	else:
		Direction = -90
	Pos.y = randf_range(300, size.y-50)
	var T = preload("res://maps/train.tscn").instantiate()
	get_parent().add_child.call_deferred(T)
	T.position = Pos - Vector2(100 if Pos.x < 1 else -100,7.5)
	T.rotation_degrees = Direction +90

func F_Step():
	var Add = preload("res://maps/track.tscn").instantiate()
	get_parent().add_child(Add)
	Add.position = Pos
	Add.rotation_degrees = Direction
	Pos.x += 32 * -(Direction/90)
	if Pos.x >= get_viewport().size.x + 100:
		F_Structure()
