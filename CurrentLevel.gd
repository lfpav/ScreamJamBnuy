extends Node
@onready var CurrentLvl
@onready var Player = get_parent().get_node("Player")
@export var CurLvlId = 2
@export var chonga = true
func _load_level(number):
	match number:
		0:
			CurrentLvl=load("res://Tutorial.tscn").instantiate()
			add_child(CurrentLvl)
			CurrentLvl.get_node("LevelCompleteBox").body_entered.connect(_change_level)
		1:
			CurrentLvl=load("res://Level_1.tscn").instantiate()
			add_child(CurrentLvl)
			CurrentLvl.get_node("LevelCompleteBox").body_entered.connect(_change_level)
		2:
			CurrentLvl=load("res://Level_2.tscn").instantiate()
			add_child(CurrentLvl)
			CurrentLvl.get_node("LevelCompleteBox").body_entered.connect(_change_level)
			return
			
	Player.position = CurrentLvl.PlayerStartPos
	Player.velocity = Vector2.ZERO
func _ready():
	_load_level(CurLvlId)
	
	

func _change_level(body):
	if body.name=="Player" and chonga :
		CurrentLvl.queue_free()
		CurLvlId+=1
		
		call_deferred("_load_level",CurLvlId)
		Player.position = CurrentLvl.PlayerStartPos
		Player.velocity = Vector2.ZERO
