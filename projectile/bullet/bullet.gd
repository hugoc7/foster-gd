extends RigidBody2D

const SPEED = 1000
@export var explosion : PackedScene
var projectile_id: int = -1
@export var server_position: Vector2

signal destroyed(_projectile_id:int)

func _ready():
	#linear_velocity = 
	apply_impulse(SPEED * Vector2.RIGHT.rotated(rotation))
	body_entered.connect(_on_body_entered)
	$AutoDestroyTimer.timeout.connect(destroy)
		
	
func _on_body_entered(body):
	destroy()

#called on all peers
func destroy():
	var explosion_instance = explosion.instantiate()
	if explosion_instance:
		explosion_instance.position = position
		get_parent().call_deferred("add_child", explosion_instance)
	destroyed.emit(projectile_id)
	queue_free()

