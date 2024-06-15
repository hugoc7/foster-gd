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
@export var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var local_player_info = {"name": "Anonymous"}

var players_loaded = 0

func _ready():
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)	
	
func is_server():
	if not multiplayer.multiplayer_peer:
		return false
	return multiplayer.is_server()
	
func get_unique_id():
	if not multiplayer.multiplayer_peer:
		return 0
	return multiplayer.get_unique_id()
	
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
	player_connected.emit(1, local_player_info)
	
## The client request a new player to the server
func request_new_player():
	print_debug("[",multiplayer.get_unique_id() ,"] ",
		"Request connection as ", local_player_info.name)
	_server_request_new_player.rpc_id(1, local_player_info)
	

@rpc("any_peer", "call_local", "reliable")	
## The client sends his player info to the server and request player creation
func _server_request_new_player(player_info):
	if not multiplayer.is_server():
		return
	var player_id : int = multiplayer.get_remote_sender_id()
	print_debug("[",multiplayer.get_unique_id() ,"] ",
		"Player ", player_id, " has connected as ", player_info.name)
	players[player_id] = player_info
	_client_new_player.rpc(player_id, players)
	player_connected.emit(player_id, player_info)
	
@rpc("authority", "call_local", "reliable")	
## The server tells to all clients that there is a new player
func _client_new_player(player_id, player_info_list):
	if multiplayer.is_server():
		return
	players = player_info_list
	print_debug("[",multiplayer.get_unique_id() ,"] ",
		"Player ", player_id, " has connected as ", players[player_id].name)
	player_connected.emit(player_id,  players[player_id])
	
func _on_peer_disconnected(id):	
	var player_info = {}
	var player_name = "?"
	if players.has(id):
		player_info = players[id]
		player_name = player_info.name
	print_debug("[",multiplayer.get_unique_id() ,"] ",
		"Player ", id, " (", player_name ,") has disconnected")
	players.erase(id)
	player_disconnected.emit(id, player_info)

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
