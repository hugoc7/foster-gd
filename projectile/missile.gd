extends RigidBody2D

const MISSILE_SPEED = 400
@export var explosion : PackedScene
var projectile_id: int = -1

signal destroyed(_projectile_id:int)

func _ready():
	#linear_velocity = 
	center_of_mass = center_of_mass.rotated(rotation)
	apply_impulse(MISSILE_SPEED * Vector2.RIGHT.rotated(rotation))

func destroy():
	var explosion_instance = explosion.instantiate()
	if explosion_instance:
		explosion_instance.position = position
		get_parent().add_child(explosion_instance)
	destroyed.emit(projectile_id)
	if multiplayer.is_server():
		queue_free()
