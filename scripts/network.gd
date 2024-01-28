extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id, player_info)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var local_player_info = {"name": "Anonymous"}

var players_loaded = 0

func _emit_player_connected(peer_id, player_info):
	print_debug("Player ", peer_id, " has connected as ", player_info.name)	
	player_connected.emit(peer_id, player_info)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = local_player_info
	_emit_player_connected(1, local_player_info)
	


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_peer_connected(id):
	if multiplayer.is_server():
		_register_player.rpc_id(id, local_player_info)
	else:
		var peer_id = multiplayer.get_unique_id()
		players[peer_id] = local_player_info
		_emit_player_connected(peer_id, local_player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	_emit_player_connected(new_player_id, new_player_info)


func _on_peer_disconnected(id):	
	var player_info = {}
	var player_name = "?"
	if players.has(id):
		player_info = players[id]
		player_name = player_info.name
	print_debug("Player ", id, " (", player_name ,") has disconnected")
	player_disconnected.emit(id, player_info)



func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
