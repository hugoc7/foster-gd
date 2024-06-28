@tool
extends EditorScript

@export var file_path = "res://map/test.map"
@export var plateform_scene: PackedScene = preload("res://plateform/plateform.tscn")
@export var plateform_parent: Node
const scale_ratio = 1


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	plateform_parent = get_scene().get_node("Plateforms")
	
	
	var map_file = FileAccess.open(file_path, FileAccess.READ)
	var content = map_file.get_line().trim_prefix(" ").trim_suffix(" ").split(" ")
	if content.size() < 3:
		print("Error invalid map")
		return
	var map_w = int(content[0]) - 1
	var map_h = int(content[1]) - 1
	var nb_rect = int(content[2]) - 1
	print("Map size: ", map_w, "x", map_h)
	print(nb_rect, " declared rectangles")
	var rectangles = []
	for prop in range(5):
		var property_array = []
		for i in range(nb_rect):
			var pos = 3 + prop*nb_rect + i
			if pos >= content.size():
				print("Error while reading map")
				return
			property_array.append(float(content[pos]) - 1) 
		rectangles.append(property_array)
		
	for i in range(nb_rect):
		var x = rectangles[0][i]
		var y = rectangles[1][i]
		var w = rectangles[2][i]
		var h = rectangles[3][i]
		var color = rectangles[4][i]
		
		print(x, " ", y,  " ", w,  " ", h,  " ", color)
		add_plateform(x + w/2, y + h/2, w, h, color, "wall" + str(i))

		
func add_plateform(x: float, y:float, w:float, h:float, _color, _name):
	var wall_instance: Polygon2D = plateform_scene.instantiate()
	wall_instance.name = _name
	plateform_parent.add_child(wall_instance)
	wall_instance.set_owner(get_scene())
	wall_instance.position = Vector2(x,y)
	var rect = [Vector2(-w/2,-h/2), Vector2(w/2,-h/2), Vector2(w/2,h/2), Vector2(-w/2, h/2)]
	wall_instance.set_polygon(rect)
	wall_instance.scale = Vector2(scale_ratio, scale_ratio)
	
	
	
	
