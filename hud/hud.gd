extends CanvasLayer

class_name HUD

func update_player_name(player_name):
	$HSplitContainer/PlayerName.text = player_name

func update_life(life_percent: float):
	$HSplitContainer/LifeBar.value = life_percent
