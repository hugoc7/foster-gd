extends Control


class_name PlayerInfoWidget

func set_player_name(_name: String):
	$HSplitContainer/PlayerName.text = _name
	
func set_life(_life: float):
	$HSplitContainer/LifeBar.value = _life
	
