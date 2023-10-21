extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered",_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		if body.currentState== body.STATE.FORCED or body.currentState==body.STATE.NORMAL:
			body.currentState = body.STATE.VINE
			body.velocity = Vector2.ZERO
			body.currentVinePos = position
			body.currentVineSize = $hitbox.shape.size
			if body.position.y<(position.y-($hitbox.shape.size.y/2)):
				body.position.y=position.y-$hitbox.shape.size.y/2
			elif body.position.y>(position.y+($hitbox.shape.size.y)/2):
				body.position.y=position.y+$hitbox.shape.size.y/2
			if body.position.x<position.x:
				body.position.x=position.x-$hitbox.shape.size.x/2
				body.get_node("Sprite2D").rotation_degrees=-90
			else:
				body.position.x = position.x+$hitbox.shape.size.x/2
				body.get_node("Sprite2D").rotation_degrees=90
			print("VINE")
		pass
