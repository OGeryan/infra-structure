extends CharacterBody3D

@export var MoveSpeed = 6.0
@export var Accel = 9.0

var MouseSensitivity = 0.003

var Jump_Peak_T : float = 0.275
var Jump_Fall_T : float = 0.275
@export var JumpHeight = 0.75
var JumpVelocity : float = 6.0
var JumpSpeedGain = 1.225

var JumpGravity = ProjectSettings.get_setting("physics/3d/default_gravity")*2.5
var FallGravity : float = 5.0

var HeadOrigin : float
var HeadBobY = 0.0
var HeadBobTarget = 0.0
var HeadBobSpeed = 0

var Landed = true

var Inventory : Dictionary = {
	0:null,
	1:null,
	2:null,
	3:null,
	4:null
}

var Quitting = 0.0

var InvSlot = 0:
	set(x):
		if x >= $CanvasLayer/Control/InvSlots.get_child_count():
			InvSlot = 0
		elif x < 0:
			InvSlot = $CanvasLayer/Control/InvSlots.get_child_count()-1
		else:
			InvSlot = x
		var N = 0
		for i in $CanvasLayer/Control/InvSlots.get_children():
			if N == InvSlot:
				i.F_SetSelect(true)
				AudioManager.F_QuickPlaySound(preload("res://audio/switch.ogg"), self, 0.1)
			else:
				i.F_SetSelect(false)
			N += 1
		F_EquipItem(InvSlot)

var EquippedItem : ItemAttributes
var Equipping = 0.0
var ItemReady = true

func _ready() -> void:
	InvSlot = 0
	HeadOrigin = $Camera3D.position.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	JumpGravity = (2*JumpHeight)/pow(Jump_Peak_T, 2)
	FallGravity = (2.25*JumpHeight)/pow(Jump_Fall_T, 2)
	JumpVelocity = JumpGravity * Jump_Peak_T

func _physics_process(delta: float) -> void:
	var Gain = 1.0
	if !is_on_floor():
		Landed = false
		if velocity.y > 0:
			velocity.y -= JumpGravity * delta
		else:
			velocity.y -= FallGravity * delta
		Gain = JumpSpeedGain
	else:
		if !Landed:
			_step(true)
			Landed = true
			Gain = 1

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JumpVelocity

	var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = velocity.lerp(direction*MoveSpeed*Gain, delta*Accel).x
	velocity.z = velocity.lerp(direction*MoveSpeed*Gain, delta*Accel).z

	

func _process(delta: float) -> void:
	HeadBobY = lerpf($Camera3D.position.y, HeadOrigin + HeadBobTarget if velocity.length() > MoveSpeed/2 and is_on_floor() else HeadOrigin, HeadBobSpeed*delta)
	$Camera3D.position.y = HeadBobY
	
	if Input.is_action_just_pressed("ChangeItemUp"):
		InvSlot += 1
	if Input.is_action_just_pressed("ChangeItemDown"):
		InvSlot -= 1
	
	if !ItemReady and EquippedItem:
		$CanvasLayer/Control/EquipProgress.visible = true
		Equipping += delta*EquippedItem.EquipTimeMultiplier
		if Equipping >= 1:
			ItemReady = true
			Equipping = 0.0
		$CanvasLayer/Control/EquipProgress.value = Equipping
	else:
		$CanvasLayer/Control/EquipProgress.visible = false
		
	$HoverSprite.visible = ($Camera3D/PickupRay.get_collider() and $Camera3D/PickupRay.get_collider().is_in_group("Pickup"))
	$CanvasLayer/Crosshair.visible = !$HoverSprite.visible
	if $Camera3D/PickupRay.get_collider():
		if $Camera3D/PickupRay.get_collider().is_in_group("Pickup"):
			$HoverSprite.global_position = $Camera3D/PickupRay.get_collider().global_position
	
	if Input.is_key_pressed(KEY_ESCAPE):
		Quitting += delta
	else:
		Quitting -= delta
	Quitting = clampf(Quitting, 0.0, 1.0)
	$CanvasLayer/Quitting.visible = Quitting > .05
	$CanvasLayer/Quitting/QuitBar.value = Quitting
	if is_equal_approx(1.0, Quitting):
		get_tree().change_scene_to_packed(preload("res://maps/mainmenu.tscn"))
		return

	move_and_slide()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MouseSensitivity)
		$Camera3D.rotate_x(-event.relative.y*MouseSensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(90), deg_to_rad(90)) 
	if event.is_action_pressed("Fire"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
		#FIRING
		if ItemReady and EquippedItem:
			match EquippedItem.Action1:
				0:
					pass
				1:
					var VM = $Camera3D/Viewport/vm_hands
					VM.F_PlayAnim(EquippedItem.Anims["action1"], true)
					VM.F_SetBusy(EquippedItem.Action1Interval)
					VM.F_PlayAnim(EquippedItem.Anims["idle"], false, true)
					if !VM.is_connected("Action1", F_Action):
						VM.connect("Action1", F_Action)
						await VM.get_node("AnimationPlayer").animation_finished
						VM.disconnect("Action1", F_Action)
				2:
					F_Action()
				_:
					pass
	if event.is_action_pressed("MouseToggle"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			get_window().mode = Window.MODE_FULLSCREEN if get_window().mode == Window.MODE_WINDOWED else Window.MODE_WINDOWED
		if event.keycode == KEY_F1:
			$CanvasLayer.visible = !$CanvasLayer.visible
		if event.keycode == KEY_1:
			InvSlot = 0
		if event.keycode == KEY_2:
			InvSlot = 1
		if event.keycode == KEY_3:
			InvSlot = 2
		if event.keycode == KEY_4:
			InvSlot = 3
		if event.keycode == KEY_5:
			InvSlot = 4
		if event.is_action_pressed("PickUp"):
			if F_RayCastForward(3.5):
				var Hit = F_RayCastForward(3.5)["collider"]
				if Hit.is_in_group("Pickup"):
					F_SetInventoryItem(InvSlot, Hit.Attributes, Hit)
				elif Hit.is_in_group("Interact"):
					if Hit.get_parent().has_method("F_Interact"):
						Hit.F_Interact(self)
		if event.is_action_pressed("Throw") and Inventory[InvSlot] != null:
			if !F_RayCastForward(0.5):
				var SpawnedItem = Inventory[InvSlot].F_SpawnItem($Camera3D.global_position, Inventory[InvSlot], self)
				F_SetInventoryItem(InvSlot, null, null)
				SpawnedItem.velocity = Vector3(($Camera3D.global_transform.basis.z*-15).x, 0, ($Camera3D.global_transform.basis.z*-15).z)

func F_Action():
	match EquippedItem.Action1:
		1:
			var Ray = preload("res://scenes/actionraycast.tscn").instantiate()
			if EquippedItem.LTType == 1:
				EquippedItem.PowerMultipliers["wood"] = int(F_HasInventoryItem("lumber", 1))
				EquippedItem.PowerMultipliers["metal"] = int(F_HasInventoryItem("steel", 1))
			$Camera3D.add_child(Ray)
			Ray.F_Cast(EquippedItem.LTType, EquippedItem.LTRange, EquippedItem.Power, $Camera3D, EquippedItem.PowerMultipliers, self)
			await get_tree().create_timer(.5).timeout
			Ray.queue_free()
		2:
			var Throw = preload("res://scenes/dynamite.tscn").instantiate()
			AudioManager.F_QuickPlaySound(preload("res://audio/sfx_grab.tres"))
			get_tree().root.get_child(0).add_child(Throw)
			Throw.global_position = global_position
			Throw.velocity = Vector3(($Camera3D.global_transform.basis.z*-5).x, 0, ($Camera3D.global_transform.basis.z*-5).z)
	if EquippedItem.Consume_OnAction:
		F_SetInventoryItem(InvSlot, null, null)
			
func F_RayCastForward(length: float = 100) -> Dictionary:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create($Camera3D.global_position,
	$Camera3D.global_position - $Camera3D.global_transform.basis.z * length, 4294967295, [self])
	var collision = space.intersect_ray(query)
	return collision

func F_RayCastDown() -> Dictionary:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create($Camera3D.global_position, Vector3($Camera3D.global_position.x, $Camera3D.global_position.y - 10, $Camera3D.global_position.z))
	var collision = space.intersect_ray(query)
	return collision


func _step(force: bool) -> void:
	if ((velocity.length() > MoveSpeed/2) and is_on_floor()) or force:
		var Surface = ""
		if !F_RayCastDown().collider.has_meta("surface"):
			Surface = ""
		else:
			Surface = F_RayCastDown().collider.get_meta("surface")
		match Surface:
			"stone":
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_stonestep.tres"), self)
			"metal":
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_metalstep.tres"), self)
			"ground":
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_grassstep.tres"), self)
			"sand":
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_sandstep.tres"), self, 5)
			_:
				AudioManager.F_QuickPlaySound(preload("res://audio/sfx_stonestep.tres"), self)


func _headbob() -> void:
	if is_equal_approx(HeadBobTarget, 0.0):
		HeadBobTarget = -0.12
	else:
		HeadBobTarget *= -1
		
func F_EquipItem(slot : int):
	if Inventory[slot] == null:
		$Camera3D/Viewport/vm_hands/PLACEHOLDER.mesh = null
		$Camera3D/Viewport/vm_hands.F_SetBusy(0)
		$Camera3D/Viewport/vm_hands.F_ClearQueue()
		$Camera3D/Viewport/vm_hands.F_PlayAnim("vm_idle", true)
		EquippedItem = null
		ItemReady = true
		return
	$Camera3D/Viewport/vm_hands.F_SetBusy(0)
	$Camera3D/Viewport/vm_hands.F_ClearQueue()
	$Camera3D/Viewport/vm_hands.F_PlayAnim(Inventory[InvSlot].Anims["equip"])
	$CanvasLayer/SelectText.text = Inventory[slot].Name
	$CanvasLayer/AnimationPlayer.stop()
	$CanvasLayer/AnimationPlayer.play("textupdate")
	$Camera3D/Viewport/vm_hands.F_PlayAnim(Inventory[InvSlot].Anims["idle"], false, true)
	if Inventory[InvSlot].Viewmodel == null:
		$Camera3D/Viewport/vm_hands/PLACEHOLDER.mesh = Inventory[InvSlot].PropMesh
		$Camera3D/Viewport/vm_hands/Tool.mesh = null
		$Camera3D/Viewport/vm_hands/Tool.position = Inventory[InvSlot]["offset"]
		$Camera3D/Viewport/vm_hands/Tool.rotation_degrees = Inventory[InvSlot]["rotation"]
		$Camera3D/Viewport/vm_hands/Tool.scale = Inventory[InvSlot]["size"]
	else:
		$Camera3D/Viewport/vm_hands/Tool.mesh = Inventory[InvSlot].ViewmodelMesh
		$Camera3D/Viewport/vm_hands/PLACEHOLDER.mesh = null

	ItemReady = false
	Equipping = 0
	EquippedItem = Inventory[slot]

func F_SetInventoryItem(id : int, item : ItemAttributes, pickup : Node3D = null, equip = true):
	var Old = Inventory[id] as ItemAttributes
	var StackItem = false
	#STACK ID
	if pickup and Inventory[id] != null:
		if (pickup.Attributes.Amount + Old.Amount <= Inventory[id].Stack) and pickup.Attributes.Name == Old.Name:
			StackItem = true
		var Pos = pickup.global_position
		if !StackItem:
			pickup.free()
			Old.F_SpawnItem(Pos, Old, self)
		else:
			item.Amount = Old.Amount + pickup.Attributes.Amount
			pickup.free()
	if pickup and is_instance_valid(pickup):
		pickup.free()
		
	Inventory[id] = item
	if item != null:
		$CanvasLayer/Control/InvSlots.get_children()[id].get_node("MarginContainer/Icon").texture = item.Icon
		if equip:
			AudioManager.F_QuickPlaySound(item.PickupSound, self, 1)
		if item.Amount > 1:
			$CanvasLayer/Control/InvSlots.get_children()[id].get_node("StackSize").text = str(item.Amount,"x")
		else:
			$CanvasLayer/Control/InvSlots.get_children()[id].get_node("StackSize").text = ""	
	else:
		$CanvasLayer/Control/InvSlots.get_children()[id].get_node("MarginContainer/Icon").texture = Texture.new()
		$CanvasLayer/Control/InvSlots.get_children()[id].get_node("StackSize").text = ""
	if equip:
		F_EquipItem(InvSlot)
	
	
func F_HasInventoryItem(Name: String, Min: int = 1):
	for i in Inventory:
		if Inventory[i]:
			if Inventory[i].Name == Name and Inventory[i].Amount >= Min:
				return true
	return false
	
func F_ConsumeItem(Name: String, N: int):
	var Consumed = 0
	for i in Inventory:
		if Inventory[i]:
			if Inventory[i].Name == Name:
				var ToConsume = min(Inventory[i].Amount, N-Consumed)
				Inventory[i].Amount -= ToConsume
				Consumed += ToConsume
				F_SetInventoryItem(i, Inventory[i], null, false)
				if Inventory[i].Amount <= 0:
					F_SetInventoryItem(i, null, null, false)
		if Consumed >= N:
			return
