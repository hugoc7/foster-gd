extends Sprite2D

class_name Bazooka


const missile = preload("res://projectile/missile.tscn")

var prediction_missile_instance : Node = null
var projectile_manager: ProjectileManager = null

func _ready():
	$ProjectileSpawner.spawn_function = _on_spawn_projectile

#called by client or host
func fire():
	if not Network.is_server():
		prediction_missile_instance = missile.instantiate()
		prediction_missile_instance.position = $MissilePosition.global_position
		prediction_missile_instance.rotation = $MissilePosition.global_rotation
		get_node($ProjectileSpawner.spawn_path).add_child(prediction_missile_instance)
	_server_fire.rpc_id(1, $MissilePosition.global_position, $MissilePosition.global_rotation)
	

@rpc("any_peer", "call_local", "reliable")
func _server_fire(_position, _rotation):
	$ProjectileSpawner.spawn({
		pos = _position, 
		rot = _rotation,
		peer_id = multiplayer.get_remote_sender_id()
	})

#called on all clients
func _on_spawn_projectile(data):
	print_debug("[", multiplayer.get_unique_id(), "] spawn projectile for player ", data.peer_id)
	
	var projectile_id = projectile_manager.get_new_projectile_id()
	var projectile_name = "missile" + str(data.peer_id) + "_" + str(projectile_id)
	var missile_instance: Node = null
	
	if multiplayer.get_unique_id() == data.peer_id and prediction_missile_instance != null:
		prediction_missile_instance.get_parent().remove_child(prediction_missile_instance)	
		missile_instance = prediction_missile_instance
		prediction_missile_instance = null
	else:
		missile_instance = missile.instantiate()
		
	missile_instance.position = data.pos
	missile_instance.rotation = data.rot
	missile_instance.projectile_id = projectile_id
	missile_instance.name = projectile_name
	missile_instance.destroyed.connect(projectile_manager.release_projectile_id)
	return missile_instance
	

