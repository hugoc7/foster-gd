extends Node2D

@export var world_rect : Rect2 = Rect2(0, 0, 1152, 648)
@export var player_scene : PackedScene
var world_center = world_rect.position + world_rect.size / 2
@onready var player_spawn_pos = $PlayerSpawnPoint.position
@onready var hud : HUD = $HUD

var local_player : Player = null
var player_instances = {}

	
func _ready():
	hud.update_player_name(Network.local_player_info.name)
	
	#Setup player spawner before spawning players
	$PlayerSpawner.spawn_function = add_player
	
	Network.player_disconnected.connect(on_player_disconnected)
	
	
	if Network.is_server(): 
		for peer_id in Network.players:
			server_add_player(peer_id, Network.players[peer_id])
		Network.player_connected.connect(server_add_player)
	else:
		multiplayer.connected_to_server.connect(Network.request_new_player)
		

func on_player_disconnected(_peer_id, _player_info):
	for node in $Players.get_children():
		var player = node as Player
		if player.peer_id == _peer_id:
			player.queue_free()
	
#Server only
func server_add_player(_peer_id: int, _player_info):
	#var player_instance : Player = player_scene.instantiate()
	#player_instance.name = _player_info.name + str(peer_id)
	#if not player_instance: 
	#	print_debug("Unable to instantiate player scene for peer ", peer_id)
	#player_instance.spawn($PlayerSpawnPoint.global_position, peer_id, $Projectiles)		
	$PlayerSpawner.spawn({
		peer_id = _peer_id,
		pos = $PlayerSpawnPoint.global_position
	})
	
	
	
	
func _process(_delta):
	
	#make the camera follow the player
	if local_player:
		$CameraPlayer.position = local_player.position
	
	#Server only after this line ---
	#kill player if it goes out of world rect
	if not Network.is_server():
		return
	
	for player in $Players.get_children():
		if not world_rect.has_point(player.position):
			player.position = world_center
			if player.alive:
				player.die()
		
func _draw():
	draw_rect(world_rect, Color.DARK_MAGENTA, false, 3)

# Server only
func _on_player_died(player: Player):
	if player:
		player.spawn($PlayerSpawnPoint.global_position, player.peer_id, $Projectiles)

func _on_player_damage_taken(player: Player):
	if local_player == player and local_player:
		hud.update_life(float(local_player.health) / float(local_player.max_health))

func add_player(_data):
	var player_instance : Player = player_scene.instantiate()
	if multiplayer.is_server():
		player_instance.name = Network.players[_data.peer_id].name + str(_data.peer_id)
	player_instance.spawn(_data.pos, _data.peer_id, $Projectiles)
	return player_instance
