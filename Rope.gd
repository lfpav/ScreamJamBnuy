extends Area2D
@onready var Player = $/root/Main/ActiveGame/Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if has_overlapping_bodies():
		if Input.is_action_just_pressed("move_up"):
			Player.position.y = -610
			Player.currentState = Player.STATE.NORMAL
			Player.up_direction=Vector2(0,-1)
			Player.get_node("Sprite2D").rotation_degrees=0
			Player.get_node("CollisionShape2D").rotation_degrees=0
			Player.get_node("Sprite2D").flip_v=false
			
		

