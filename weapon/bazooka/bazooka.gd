extends Sprite2D

class_name Bazooka


@export var missile: PackedScene

var prediction_missile_instance : Node = null
var projectile_manager: ProjectileManager = null

@export var projectiles_parent: Node

#called by client or host
func fire():
	for body in $SpawnArea.get_overlapping_bodies():
		if not body is Player:
			return false
			
	if not Network.is_server():
		if Network.local_prediction_enabled:	
			prediction_missile_instance = missile.instantiate()
			prediction_missile_instance.position = $MissilePosition.global_position
			prediction_missile_instance.rotation = $MissilePosition.global_rotation
			projectiles_parent.add_child(prediction_missile_instance)
	_server_fire.rpc_id(1, $MissilePosition.global_position, $MissilePosition.global_rotation)
	return true
	

@rpc("any_peer", "call_local", "reliable")
func _server_fire(_position, _rotation):
	_client_spawn_projectile.rpc(_position, _rotation, multiplayer.get_remote_sender_id())
	

@rpc("authority", "call_local", "reliable")
func _client_spawn_projectile(_pos, _rot, _peer_id):
	#print_debug("[", multiplayer.get_unique_id(), "] spawn projectile for player ", _peer_id)
	
	var projectile_id = projectile_manager.get_new_projectile_id()
	var projectile_name = "missile" + str(_peer_id) + "_" + str(projectile_id)
	var missile_instance: Node = null
	var already_spawned = prediction_missile_instance != null
	
	if already_spawned:
		missile_instance = prediction_missile_instance
		prediction_missile_instance = null
		
	else:
		missile_instance = missile.instantiate()
	
	missile_instance.set_multiplayer_authority(1)
	missile_instance.position = _pos
	missile_instance.rotation = _rot
	missile_instance.projectile_id = projectile_id
	missile_instance.name = projectile_name
	missile_instance.destroyed.connect(projectile_manager.release_projectile_id)
	
	if not already_spawned:
		projectiles_parent.add_child(missile_instance)
	

