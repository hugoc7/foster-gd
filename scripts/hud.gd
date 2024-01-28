extends CanvasLayer

class_name HUD

func update_player_name(name):
	$HSplitContainer/PlayerName.text = name

func update_life(life_percent: float):
	$HSplitContainer/LifeBar.value = life_percent
