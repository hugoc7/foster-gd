extends CharacterBody2D

class_name Player

signal player_died(player: Player)
signal damage_taken(player: Player)



@export var max_health = 3000

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_counter = 0
var alive = true
var health = max_health
@export var peer_id : int = 0
var weapon
var input_enabled = false
var physics_enabled = false
var direction:float = 0
var jump_just_pressed = false
@export var server_position = Vector2.ZERO



func _ready():
	weapon = $Bazooka
	set_physics_process(physics_enabled)
	set_process_unhandled_input(input_enabled)
	

func die():
	print_debug("Player died")
	set_physics_process(false)
	alive = false
	visible = false
	emit_signal("player_died", self)#must be called at the end
	
func take_damage(amount: int):
	health = max(health - amount, 0)
	if health <= 0:
		die()
	emit_signal("damage_taken", self)
	
func spawn(spawn_position: Vector2, peer_id: int):
	print_debug("[", Network.get_unique_id(), "] Player ", peer_id, " spawned at ", spawn_position)
	var local_peer_id : int = Network.get_unique_id()
	var is_local_player : bool = local_peer_id == peer_id
	
	if Network.is_server():
		physics_enabled = true
		
	if is_local_player:
		input_enabled = true
		
	position = spawn_position
	
	self.peer_id = peer_id
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		jump_counter = 0
	
	# Handle Jump.
	if jump_just_pressed and jump_counter <= 1:
		velocity.y = JUMP_VELOCITY
		jump_counter += 1

	# Get the input direction and handle the movement/deceleration.
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _process(delta):
	if Network.is_server():
		server_position = position
	else:
		position = server_position
	
func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		weapon.fire()
	if event is InputEventMouseMotion:
		weapon.look_at(get_global_mouse_position())
	direction = Input.get_axis("move_left", "move_right")
	jump_just_pressed = Input.is_action_just_pressed("jump")
	_server_receive_move_inputs.rpc_id(1, direction, jump_just_pressed)
	
@rpc("reliable", "any_peer", "call_local")
func _server_receive_move_inputs(direction: float, jump: bool):
	self.direction = direction
	self.jump_just_pressed = jump

		
		
		
		
		
		
		
