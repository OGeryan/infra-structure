extends Control

var CurrentPreset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TracksA.connect("timeout", $TracksLayer/Tracks.F_Step)
	var Config = ConfigFile.new()
	var Data = Config.load("user://rules.cfg")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Data == OK:
		$Tabs/Play/VBoxContainer/Width.value = float(Config.get_value("Generation", "Width"))
		$Tabs/Play/VBoxContainer/Height.value = float(Config.get_value("Generation", "Height"))
		$Tabs/Play/VBoxContainer/Scarcity.value = float(Config.get_value("Generation", "Scarce"))
		$Tabs/Play/VBoxContainer/Amount.value = float(Config.get_value("Generation", "Amount"))
	await get_tree().create_timer(.2).timeout
	F_LoadSettings()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED


func F_Hovered() -> void:
	AudioManager.F_QuickPlaySound2D(preload("res://audio/button_1.ogg"), self, 2)


func F_Clicked() -> void:
	AudioManager.F_QuickPlaySound2D(preload("res://audio/button_2.ogg"), self, 2)


func F_Quit() -> void:
	get_tree().quit(0)



func F_UpdateGeneration(D : float) -> void:
	var Config = ConfigFile.new()
	Config.set_value("Generation", "Width", $Tabs/Play/VBoxContainer/Width.value)
	Config.set_value("Generation", "Height", $Tabs/Play/VBoxContainer/Height.value)
	Config.set_value("Generation", "Amount", $Tabs/Play/VBoxContainer/Amount.value)
	Config.set_value("Generation", "Scarce", $Tabs/Play/VBoxContainer/Scarcity.value)
	Config.set_value("Generation", "Theme", $Tabs/Play/ScrollContainer/FlowContainer/Theme.selected)
	Config.save("user://rules.cfg")


func F_StartGame() -> void:
	F_UpdateGeneration(-1)
	$Tabs/Play/StartButton/StartLabel.text = "loadin"
	await get_tree().create_timer(.2).timeout
	get_tree().change_scene_to_packed(load("res://maps/map1_test.tscn"))


func F_GenerationPresets(index: int) -> void:
	var Preset = []
	match index:
		0:
			Preset = [64, 512, 0.2, 5]
		1:
			Preset = [128, 512, 0.4, 5]
		2:
			Preset = [64, 512, 0.03, 10]
		3:
			Preset = [16, 512, 0.3, 3]
		_:
			Preset = [64, 512, 0.2, 5]
	$Tabs/Play/VBoxContainer/Width.value = Preset[0]
	$Tabs/Play/VBoxContainer/Height.value = Preset[1]
	$Tabs/Play/VBoxContainer/Amount.value = Preset[2]
	$Tabs/Play/VBoxContainer/Scarcity.value = Preset[3]

func F_Play() -> void:
	if $Tabs.visible:
		if $Tabs.current_tab == 0:
			$Tabs.visible = false
			return
	$Tabs.visible = true
	$Tabs.current_tab = 0


func F_Settings() -> void:
	if $Tabs.visible:
		if $Tabs.current_tab == 1:
			$Tabs.visible = false
			return
	$Tabs.visible = true
	$Tabs.current_tab = 1

func F_Credits() -> void:
	if $Tabs.visible:
		if $Tabs.current_tab == 2:
			$Tabs.visible = false
			return
	$Tabs.visible = true
	$Tabs.current_tab = 2


func F_SetVolume(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func F_SetAA(toggled_on: bool) -> void:
	get_viewport().msaa_3d = 2 if toggled_on else 0


func F_SliderToggle(value: bool) -> void:
	if value:
		AudioManager.F_QuickPlaySound2D(preload("res://audio/button_1.ogg"))
	else:
		AudioManager.F_QuickPlaySound2D(preload("res://audio/button_2.ogg"))
	F_SaveSettings()
		
func F_SaveSettings():
	var Settings = ConfigFile.new()
	Settings.set_value("Audio", "MainVolume", $Tabs/Settings/VBoxContainer/VolumeSlider.value)
	Settings.set_value("GFX", "MSAA", $Tabs/Settings/VBoxContainer/AAToggle.button_pressed)
	Settings.save("user://settings.cfg")

func F_LoadSettings():
	var Settings = ConfigFile.new()
	if Settings.load("user://settings.cfg") != OK:
		return
	$Tabs/Settings/VBoxContainer/VolumeSlider.value = Settings.get_value("Audio", "MainVolume")
	$Tabs/Settings/VBoxContainer/AAToggle.button_pressed = Settings.get_value("GFX", "MSAA", 0)
