extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func F_SetSelect(val: bool):
	if val:
		texture = preload("res://img/inv_box_b.png")
	else:
		texture = preload("res://img/inv_box_a.png")
