extends CollisionPolygon2D

@onready var polygon_2d = $Polygon2D
# Called when the node enters the scene tree for the first time.
func _ready():
	polygon_2d.polygon = polygon
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
