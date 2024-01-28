extends Node2D

@export var world_rect : Rect2 = Rect2(0, 0, 1152, 648)
@export var player_scene : PackedScene
var world_center = world_rect.position + world_rect.size / 2
@onready var player_spawn_pos = $PlayerSpawnPoint.position
@onready var hud : HUD = $HUD

var local_player : Player
var player_instances = {}

	
func _ready():
	hud.update_player_name(Network.local_player_info.name)
	Network.player_connected.connect(add_new_player);
	

#Server only
func add_new_player(peer_id: int):
	if not Network.multiplayer.is_server(): 
		return
	var player_instance = player_scene.instantiate()
	if not player_instance: 
		print_debug("Unable to instantiate player scene for peer ", peer_id)
	player_instance.peer_id = peer_id
	$MultiplayerSpawner.add_child(player_instance)
	
	
	
func _process(delta):
	#kill player if it goes out of world rect
	if not world_rect.has_point($Player.position):
		$Player.position = world_center
		if $Player.alive:
			$Player.die()
	
	#make the camera follow the player
	$CameraPlayer.position = $Player.position

func _spawn_player():
	$Player.spawn(player_spawn_pos)
		
func _draw():
	draw_rect(world_rect, Color.DARK_MAGENTA, false, 3)

func _on_player_died():
	_spawn_player()

func _on_player_damage_taken():
	hud.update_life(float($Player.health) / float($Player.max_health))

#client only
func _on_multiplayer_spawner_spawned(node):
	if Network.multiplayer.is_server(): return
	if node is Player:
		var player : Player = node
		if player.peer_id == Network.multiplayer.get_unique_id():
			local_player = player
		
		
