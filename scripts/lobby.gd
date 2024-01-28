extends CanvasLayer

@export var game_scene : PackedScene

func _on_join_button_pressed():
	Network.local_player_info.name = $Popup/ConnectionContainer/NameInput.text
	var error = Network.join_game($Popup/ConnectionContainer/IPInput.text)
	if error:
		print_debug("Network error : unable to join a game ")
		return
		
	get_tree().change_scene_to_packed(game_scene)


func _on_host_button_pressed():
	Network.local_player_info.name = $Popup/ConnectionContainer/NameInput.text
	var error = Network.create_game()
	if error:
		print_debug("Network error : unable to create a game ")
		return
		
	get_tree().change_scene_to_packed(game_scene)
