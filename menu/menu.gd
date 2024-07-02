extends CanvasLayer

@export var game_scene : PackedScene

func _ready():
	var option_button = $Popup/ConnectionContainer/OptionContainer/OptionButton
	var option_back_button = $Popup/OptionsContainer/ReturnContainer/ReturnButton
	option_button.pressed.connect(_switch_to_options)
	option_back_button.pressed.connect(_switch_to_menu)
	
func _switch_to_options():
	$Popup/OptionsContainer.visible = true
	$Popup/ConnectionContainer.visible = false
	
func _switch_to_menu():
	$Popup/OptionsContainer.visible = false
	$Popup/ConnectionContainer.visible = true

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
		
	print(Network.local_prediction_delay)
		
	get_tree().change_scene_to_packed(game_scene)
