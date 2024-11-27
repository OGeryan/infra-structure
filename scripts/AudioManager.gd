extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func F_QuickPlaySound(Stream: AudioStream, Parent: Node = get_tree().root.get_child(0), Volume : float = 1):
	var New = AudioStreamPlayer3D.new()
	New.stream = Stream
	Parent.add_child(New)
	New.volume_db = linear_to_db(Volume)
	New.play()
	
