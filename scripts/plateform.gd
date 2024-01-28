extends Polygon2D

func _ready():
	$Polygon2D/CollisionPolygon2D.polygon = polygon
