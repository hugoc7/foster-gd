extends CanvasLayer

class_name HUD

@export var player_info_widget: PackedScene

var player_widgets = {}

func update_player_name(_id, _name):
	var player_widget: PlayerInfoWidget = player_widgets[_id]
	player_widget.set_player_name(_name)

func update_life(_id, _life_percent: float):
	var player_widget: PlayerInfoWidget = player_widgets[_id]
	player_widget.set_life(_life_percent)
	
func add_player(_id, _name: String):
	var player_widget_instance: PlayerInfoWidget = player_info_widget.instantiate()
	
	$PlayerContainer.add_child(player_widget_instance)
	player_widgets[_id] = player_widget_instance
	player_widget_instance.set_player_name(_name)

func remove_player(_id):
	var player_widget: PlayerInfoWidget = player_widgets[_id]
	player_widget.queue_free()
	
	
