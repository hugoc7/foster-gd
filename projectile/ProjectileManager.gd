extends Node


class_name ProjectileManager

var removed_projectile_ids = []

var projectile_count: int = 0

func get_new_projectile_id():
	projectile_count += 1
	if removed_projectile_ids.is_empty():
		return projectile_count - 1
	else: 
		return removed_projectile_ids.pop_back()

func release_projectile_id(id: int):
	if projectile_count <= 0:
		print_debug("Unable to release projectile")
	removed_projectile_ids.push_back(id)
	projectile_count -= 1
