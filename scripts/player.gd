extends CharacterBody2D

class_name Player

signal player_died
signal damage_taken



@export var max_health = 3000

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_counter = 0
var alive = true
var health = max_health
var peer_id : int = 0
var weapon



func _ready():
	weapon = $Bazooka

func die():
	print_debug("Player died")
	set_physics_process(false)
	alive = false
	visible = false
	emit_signal("player_died")#must be called at the end
	
func take_damage(amount: int):
	health = max(health - amount, 0)
	if health <= 0:
		die()
	emit_signal("damage_taken")
	
func spawn(spawn_position: Vector2):
	print_debug("Player spawned at ", spawn_position)
	set_physics_process(true)
	alive = true
	visible = true
	position = spawn_position
	health = max_health
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		jump_counter = 0
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and jump_counter <= 1:
		velocity.y = JUMP_VELOCITY
		jump_counter += 1

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		weapon.fire()
	if event is InputEventMouseMotion:
		weapon.look_at(get_global_mouse_position())

		
		
		
		
		
		
		
