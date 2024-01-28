extends GPUParticles2D

var damage = 50

func _ready():
	one_shot = true
	emitting = true
	

func _on_destroy_timer_timeout():
	queue_free()


func _on_effect_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
