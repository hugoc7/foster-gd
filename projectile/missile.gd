extends RigidBody2D

const MISSILE_SPEED = 400
@export var explosion : PackedScene

func launch():
	#linear_velocity = 
	center_of_mass = center_of_mass.rotated(rotation)
	apply_impulse(MISSILE_SPEED * Vector2.RIGHT.rotated(rotation))

func destroy():
	var explosion_instance = explosion.instantiate()
	if explosion_instance:
		explosion_instance.position = position
		get_parent().add_child(explosion_instance)
	queue_free()
	#print_debug("Missile destroyed")
	pass


func _on_body_entered(body):
	#destroy()
	pass
	
