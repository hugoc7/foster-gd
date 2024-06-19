extends Node2D

@export var world_rect : Rect2 = Rect2(0, 0, 1152, 648)
@export var player_scene : PackedScene
@export var death_duration: float = 2.0
var world_center = world_rect.position + world_rect.size / 2
@onready var player_spawn_pos = $PlayerSpawnPoint.position
@onready var hud : HUD = $HUD

var local_player : Player = null
var player_instances = {}

	
func _ready():
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
		pos = $PlayerSpawnPoint.global_position,
		name = _player_info.name
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
func _server_on_player_died(player: Player):
	if player:
		await get_tree().create_timer(death_duration).timeout
		_respawn_player.rpc(player.peer_id)
		

func _on_player_life_changed(player: Player):
	print_debug("[", multiplayer.get_unique_id(), "] Life changed player ", player.peer_id)
	hud.update_life(player.peer_id, float(player.health) / float(player.max_health))

@rpc("authority", "reliable", "call_local")
func _respawn_player(_peer_id: int):
	var player: Player = player_instances[_peer_id]
	player.spawn($PlayerSpawnPoint.global_position, player.peer_id, $Projectiles)

func add_player(_data):
	var player_instance : Player = player_scene.instantiate()
	if multiplayer.is_server():
		player_instance.name = _data.name + str(_data.peer_id)
		player_instance.peer_id = _data.peer_id
		player_instance.player_died.connect(_server_on_player_died)
	player_instance.spawn(_data.pos, _data.peer_id, $Projectiles)
	player_instance.life_changed.connect(_on_player_life_changed)
	
	var player_name = _data.name
	if _data.peer_id == multiplayer.get_unique_id():
		local_player = player_instance
		player_name = "[b]" + _data.name + "[/b]"
	hud.add_player(_data.peer_id, player_name)
	player_instances[_data.peer_id] = player_instance
	return player_instance
