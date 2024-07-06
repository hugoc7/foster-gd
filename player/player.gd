extends CharacterBody2D

class_name Player

signal player_died(player: Player)
signal life_changed(player: Player)



@export var max_health = 1000

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_counter = 0
var alive = true
var health = max_health
var peer_id : int = 0 # dont specifiy @export 
var weapon
var direction:float = 0
var jump_just_pressed = false
@export var server_position = Vector2.ZERO
@export var server_weapon_rotation: float = 0
@export var projectiles_parent: Node = null
var is_in_cooldown = false

func _ready():
	#setup weapon
	weapon = $Bazooka
	weapon.projectile_manager = $ProjectileManager	
	weapon.projectiles_parent = projectiles_parent
	$FireCooldownTimer.timeout.connect(_on_fire_cooldown_timeout)
	
	
	print("[", Network.get_unique_id(), "] Player ", peer_id, " spawned at ", position)
	var local_peer_id : int = Network.get_unique_id()
	var is_local_player : bool = local_peer_id == peer_id
	
	set_physics_process(Network.is_server())
	set_process_unhandled_input(is_local_player)

func _on_fire_cooldown_timeout():
	is_in_cooldown = false
	
@rpc("authority", "reliable", "call_local")
func client_die():
	print("[", Network.get_unique_id(), "] Player ", peer_id, " died")
	set_physics_process(false)
	set_process_unhandled_input(false)
	alive = false
	visible = false
	if health > 0:
		health = 0
		life_changed.emit(self)
	player_died.emit(self)
	set_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	
func server_take_damage(amount: int):
	if not Network.is_server():
		print_debug("Error method called by client")
		return
	client_take_damage.rpc(amount)
	
@rpc("authority", "reliable", "call_local")
func client_take_damage(amount: int):
	health = max(health - amount, 0)
	if health <= 0:
		client_die()
	life_changed.emit(self)
	
	
func spawn(spawn_position: Vector2, _peer_id: int, _projectile_parent: Node):	
	position = spawn_position
	velocity = Vector2.ZERO
	peer_id = _peer_id
	projectiles_parent = _projectile_parent
	set_physics_process(Network.is_server())
	set_process(true)
	set_process_unhandled_input(Network.get_unique_id() == peer_id)
	alive = true
	visible = true
	health = max_health
	life_changed.emit(self)
	$CollisionShape2D.set_deferred("disabled", false)
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		jump_counter = 0
	
	# Handle Jump.
	if jump_just_pressed and jump_counter < 2:
		velocity.y = JUMP_VELOCITY
		jump_counter += 1
		jump_just_pressed = false

	# Get the input direction and handle the movement/deceleration.
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _process(_delta):
	if Network.is_server():
		server_position = position
	else:
		position = server_position
		
	if Network.get_unique_id() != peer_id:
		weapon.rotation = server_weapon_rotation
		
	
	

func _fire():
	if is_in_cooldown:
		return
	if not weapon.fire():
		return
	is_in_cooldown = true
	$FireCooldownTimer.start()
		

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		_fire()
		
	#TODO: don't send mouse information too often => setup a maximum sending frequence
	if event is InputEventMouseMotion:
		weapon.look_at(get_global_mouse_position())
		_server_receive_look_inputs.rpc_id(1, weapon.rotation)
		
	var old_direction = direction
	var old_jump_input = jump_just_pressed
	direction = Input.get_axis("move_left", "move_right")
	jump_just_pressed = Input.is_action_just_pressed("jump")
	if old_direction != direction or old_jump_input != jump_just_pressed:
		_server_receive_move_inputs.rpc_id(1, direction, jump_just_pressed)
		#print("Jump input: ", jump_just_pressed)
	
@rpc("reliable", "any_peer", "call_local")
func _server_receive_move_inputs(_direction: float, _jump: bool):
	direction = _direction
	jump_just_pressed = _jump
	
@rpc("unreliable_ordered", "any_peer", "call_local")
func _server_receive_look_inputs(angle: float):
	server_weapon_rotation = angle
	weapon.rotation = angle

		
		
		
		
		
		
		
