extends Area2D

var damage = 50

var remaining_frames_to_wait = 1

func _ready():
	$ParticleEmitter.one_shot = true
	$ParticleEmitter.emitting = true
	$DestroyTimer.timeout.connect(_on_destroy_timer_timeout)
	if not multiplayer.is_server():
		set_physics_process(false)
		
	

func _on_destroy_timer_timeout():
	queue_free()


func _physics_process(_delta):
	#workaround : wait for first frame to detect collision
	if remaining_frames_to_wait > 0:
		remaining_frames_to_wait -= 1
		return
		
	for body in get_overlapping_bodies():
		if body.has_method("server_take_damage"):
			body.server_take_damage(damage)
	set_physics_process(false)
			
	
