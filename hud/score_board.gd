extends Control

func _ready():
	update_player_list()
	Network.player_connected.connect(on_player_list_changed)
	Network.player_disconnected.connect(on_player_list_changed)
	visible = false

func on_player_list_changed(peer_id, player_info):
	update_player_list()
	
func update_player_list():
	var player_ids = Network.players.keys()
	
	while $PlayerContainer.get_child_count() < player_ids.size():
		var player_widget = Label.new()
		$PlayerContainer.add_child(player_widget)
		
	while $PlayerContainer.get_child_count() >  player_ids.size():
		$PlayerContainer.remove_child($PlayerContainer.get_child(0))
	
	var i = 0
	for player_id in Network.players.keys():
		$PlayerContainer.get_child(i).text = Network.players[player_id].name
		i+=1
		
func _unhandled_key_input(event: InputEvent):
	if event.is_action_pressed("open_scoreboard"):
		visible = true
	if event.is_action_released("open_scoreboard"):
		visible = false
	
