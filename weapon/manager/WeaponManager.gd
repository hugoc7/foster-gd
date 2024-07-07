extends Node

class_name PlayerWeaponManager


@export var mouse_wheel_reactivity = 2
@export var server_weapon_rotation: float = 0
@export var projectiles_parent: Node = null

var current_weapon
var is_in_cooldown = false
var is_switch_weapon_in_cooldown = false
var weapons: Array[Node]
var weapon_index: int = 0
var scroll_count: int = 0
var peer_id: int
var waiting_for_weapon_switch_server_confirmation = false

func _ready():
	setup()

# should be called after proejectile_parent has been set
func setup():
	if projectiles_parent == null:
		return
	#setup weapons	
	weapons = $Weapons.get_children()
	if weapons.is_empty():
		print_debug("Error: weapons array empty")
	current_weapon = weapons[0]
	for weapon in weapons:
		weapon.projectile_manager = $ProjectileManager	
		weapon.projectiles_parent = projectiles_parent
	if not $FireCooldownTimer.timeout.is_connected(_on_fire_cooldown_timeout):
		$FireCooldownTimer.timeout.connect(_on_fire_cooldown_timeout)
	if not $FireCooldownTimer.timeout.is_connected(_on_switch_weapon_cooldown_timeout):
		$SwitchWeaponTimer.timeout.connect(_on_switch_weapon_cooldown_timeout)

func _on_switch_weapon_cooldown_timeout():
	is_switch_weapon_in_cooldown = false

@rpc("authority", "reliable", "call_local")
func client_switch_weapon(to_next: bool):
	current_weapon.visible = false
	if to_next:
		weapon_index += 1
		if weapon_index >= weapons.size():
			weapon_index = 0
	else:
		weapon_index -= 1
		if weapon_index < 0:
			weapon_index = weapons.size() - 1
	current_weapon = weapons[weapon_index]
	current_weapon.visible = true
	#print("[", Network.get_unique_id(), "] Switch to weapon ", weapon_index)
	waiting_for_weapon_switch_server_confirmation = false
	
	

func _on_fire_cooldown_timeout():
	is_in_cooldown = false
		
	
func _process(_delta):
	#TODO : disable process ?
	if Network.get_unique_id() != peer_id:
		current_weapon.rotation = server_weapon_rotation

func _fire():
	if is_in_cooldown:
		return
	if not current_weapon.fire():
		return
	is_in_cooldown = true
	$FireCooldownTimer.start()
		

func manage_inputs(event: InputEvent, mouse_position: Vector2):
	if event.is_action_pressed("fire"):
		_fire()
		
	#TODO: don't send mouse information too often => setup a maximum sending frequence
	if event is InputEventMouseMotion:
		current_weapon.look_at(mouse_position)
		_server_receive_look_inputs.rpc_id(1, current_weapon.rotation)
		
		
	var is_mouse_scroll = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			is_mouse_scroll = true
			
	if not is_switch_weapon_in_cooldown and not waiting_for_weapon_switch_server_confirmation:	
		if Input.is_action_just_pressed("next_weapon"):		
			if is_mouse_scroll:
					scroll_count += 1
					if scroll_count >= mouse_wheel_reactivity:
						scroll_count = 0
						waiting_for_weapon_switch_server_confirmation = true						
						_server_switch_weapon.rpc_id(1, true)
						is_switch_weapon_in_cooldown = true
						$SwitchWeaponTimer.start()
			else:
				waiting_for_weapon_switch_server_confirmation = true				
				_server_switch_weapon.rpc_id(1, true)
				is_switch_weapon_in_cooldown = true
				$SwitchWeaponTimer.start()
				
						
		if Input.is_action_just_pressed("previous_weapon"):
			if is_mouse_scroll:
					scroll_count += 1
					if scroll_count >= mouse_wheel_reactivity:
						scroll_count = 0
						waiting_for_weapon_switch_server_confirmation = true
						_server_switch_weapon.rpc_id(1, false)
						is_switch_weapon_in_cooldown = true
						$SwitchWeaponTimer.start()
						
			else:
				waiting_for_weapon_switch_server_confirmation = true				
				_server_switch_weapon.rpc_id(1, false)
				is_switch_weapon_in_cooldown = true
				$SwitchWeaponTimer.start()
	
	
@rpc("unreliable_ordered", "any_peer", "call_local")
func _server_receive_look_inputs(angle: float):
	server_weapon_rotation = angle
	current_weapon.rotation = angle

@rpc("reliable", "any_peer", "call_local")
func _server_switch_weapon(to_next: bool):
	client_switch_weapon.rpc(to_next)
	
	

		
		
		
		
		
		
		
