extends Sprite2D

class_name Bazooka

const missile = preload("res://scenes/missile.tscn")

func fire():
	var missile_instance = missile.instantiate()
	missile_instance.position = $MissilePosition.global_position
	missile_instance.rotation = $MissilePosition.global_rotation
	missile_instance.launch()
	get_tree().root.add_child(missile_instance)
	
	
	
