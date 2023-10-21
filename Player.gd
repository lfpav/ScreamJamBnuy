extends CharacterBody2D


const SPEED = 300.0
const MAX_SPEED=500.0
const JUMP_VELOCITY = -650.0
const CLIMB_SPEED = 150
var falling = false
var direction
var vdirection
var sprint
var storedvel
enum STATE{
	NORMAL,
	VGRAB,
	SGRABL,
	SGRABR,
	FORCED,
	VINE
}
var currentState = STATE.NORMAL 
@onready var label = $Label
@onready var RayV = $RayCastV
@onready var RayVL = $RayCastVL
@onready var CeilTimer = $ceilingchecker
@onready var RayVR = $RayCastVR
@onready var Sprite = $Sprite2D
@onready var CollisionShape = $CollisionShape2D
@onready var WJTime = $WJTime
@onready var cam = get_parent().get_node("Camera2D")
@onready var RayR = $RayCastR
@onready var RayLU = $RayCastLU
@onready var RayLL = $RayCastLL
@onready var RayRU = $RayCastRU
@onready var RayRL = $RayCastRL
@onready var RayL = $RayCastL
@onready var RayArray = [RayV,RayVL,RayVR,RayR,RayL]
@onready var VRays = [RayVL,RayV,RayVR]
@onready var MainRays = [RayV,RayL,RayR]
@export var VisibleRayCasts = true :
	set(value):
		for ray in RayArray:
			ray.get_node("Line2D").visible = value
var currentVinePos = Vector2.ZERO
var currentVineSize = Vector2.ZERO
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
func _ready():
	pass
func _RayCastLineRender():
	for ray in RayArray:
		if ray.get_collider():
			ray.get_node("Line2D").default_color=Color("RED")
		else:
			ray.get_node("Line2D").default_color=Color("WHITE")
func _Grabber():
	if currentState==STATE.FORCED:
		currentState=STATE.NORMAL
	for ray in MainRays:
		if ray.get_collider():
			if ray.get_collider().collision_layer==1:
				print (ray.get_collider().collision_layer)
				var vectorResult = Vector2(30,0) if ray.name=="RayCastR" else Vector2(-30,0) if ray.name=="RayCastL" else Vector2(0,0)
				position=ray.get_collision_point()-vectorResult
				if ray.name =="RayCastV":
					up_direction=Vector2(0,1)
					currentState=STATE.VGRAB
					$Sprite2D.flip_v=true
					velocity.y=0
					break
					
					
				elif ray.name=="RayCastL":
					currentState=STATE.SGRABL
					$CollisionShape2D.rotation_degrees=0
				else:
					currentState=STATE.SGRABR
					$CollisionShape2D.rotation_degrees=0
				break
func _process(delta):
	if position.x>1920:
		if position.y>0:
			cam.position = Vector2(2880,540)
		elif position.y<0:
			cam.position = Vector2(2880,-540)
	if position.x<1920:
		if position.y>0:
			cam.position = Vector2(960,540)
		elif position.y<0:
			cam.position=Vector2(960,-540)
	if position.x>3840:
		if position.y>0:
			cam.position = Vector2(4800,540)
		elif position.y<0:
			cam.position=Vector2(4800,-540)
		
	if velocity.x!=0:
		$Sprite2D.flip_h=velocity.x<0
	direction = Input.get_axis("move_left", "move_right")
	vdirection = Input.get_axis("move_up","move_down")
	sprint = Input.is_action_pressed("sprint")
	if Input.is_action_just_pressed("grab"):
		_Grabber()
	if VisibleRayCasts:
		_RayCastLineRender()
	if Input.is_action_just_released("grab"):
		currentState = STATE.NORMAL
		up_direction=Vector2(0,-1)
		$Sprite2D.rotation_degrees=0
		$CollisionShape2D.rotation_degrees=90
		$Sprite2D.flip_v=false
	if Input.is_action_just_pressed("reset"):
		position = Vector2(1400,900)
	if velocity.y>0 and currentState==STATE.NORMAL:
		$Sprite2D.flip_v=false
	$Sprite2D.rotation_degrees=90 if currentState==STATE.SGRABL else -90 if currentState ==STATE.SGRABR else $Sprite2D.rotation_degrees if currentState == STATE.VINE else 0 if not is_on_floor() else $Sprite2D.rotation_degrees
	if currentState==STATE.SGRABL:
		if velocity.y!=0:
			$Sprite2D.flip_h=velocity.y<0
		
	if currentState==STATE.SGRABR:
		if velocity.y!=0:
			$Sprite2D.flip_h=velocity.y>0
			
		
	$Label.text = str(velocity)
	#if currentState==STATE.NORMAL and CollisionShape.rotation!=0:
		#CollisionShape.rotation=0
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and currentState==STATE.NORMAL or currentState==STATE.FORCED:
		velocity.y+=gravity*delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if currentState == STATE.VGRAB:
			currentState = STATE.NORMAL
			up_direction=Vector2(0,-1)
			$Sprite2D.rotation_degrees=0
			$CollisionShape2D.rotation_degrees=90
			$Sprite2D.flip_v=false
		elif is_on_floor():
			if direction!=0:
				currentState=STATE.FORCED
				WJTime.start()
				if abs(velocity.x)>300:
					velocity.y = JUMP_VELOCITY * (abs(velocity.x)/350)
				else:
					velocity.y = JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY
		elif is_on_wall():
			print("wall")
			#if currentState==STATE.SGRAB:
			#	velocity.x = direction*300
			if RayL.get_collider() or RayR.get_collider():
				var multi = 1 if RayL.get_collider() else -1 if RayR.get_collider() else 0
				velocity.x= SPEED * multi
				currentState=STATE.FORCED
				WJTime.start()
				velocity.y = JUMP_VELOCITY
		elif currentState==STATE.SGRABL or currentState==STATE.SGRABR:
			var multi = 1 if RayL.get_collider() else -1 if RayR.get_collider() else 0
			velocity.x= SPEED * multi
			currentState=STATE.FORCED
			WJTime.start()
			velocity.y = JUMP_VELOCITY
		
			storedvel = velocity.x
	match currentState:
		STATE.SGRABL:
			if vdirection>0 and RayLL.get_collider():
				velocity.y=vdirection*CLIMB_SPEED
			elif vdirection<0 and RayLU.get_collider():
				velocity.y=vdirection*CLIMB_SPEED
			else:
				velocity.y=0
		STATE.SGRABR:
			if vdirection>0 and RayRU.get_collider():
				velocity.y=vdirection*CLIMB_SPEED
			elif vdirection<0 and RayRL.get_collider():
				velocity.y=vdirection*CLIMB_SPEED
			else:
				velocity.y=0
		STATE.VINE:
			var multi=0
			if vdirection>0 and position.y-80<(currentVinePos.y+(currentVineSize.y/2)):
				velocity.y=vdirection*CLIMB_SPEED
			elif vdirection<0 and position.y-170>(currentVinePos.y-(currentVineSize.y)/2):
				velocity.y=vdirection*CLIMB_SPEED
			else:
				velocity.y=0
			if direction!=0:
				if direction>0:
					multi = 1
					position.x = currentVinePos.x+currentVineSize.x/2
					get_node("Sprite2D").rotation_degrees=90
					$Sprite2D.flip_h=true
				if direction<0:
					multi = -1
					position.x = currentVinePos.x-currentVineSize.x/2
					get_node("Sprite2D").rotation_degrees=-90
					$Sprite2D.flip_h=false
			if Input.is_action_just_pressed("jump"):
				velocity.x= SPEED * multi
				currentState=STATE.FORCED
				WJTime.start()
				velocity.y = JUMP_VELOCITY
								
		STATE.VGRAB:
			if direction>0 and RayVR.get_collider():
				velocity.x=direction*SPEED
			elif direction<0 and RayVL.get_collider():
				velocity.x=direction*SPEED
			else:
				velocity.x=0
			if not is_on_ceiling():
				velocity.y-= gravity*delta
			if not RayV.get_collider():
				currentState=STATE.NORMAL
				print(velocity.y)
			#if get_last_slide_collision():
				#Sprite.rotation_degrees = rad_to_deg(snapped(deg_to_rad(180)-get_last_slide_collision().get_angle(),0.01))
				#CollisionShape.rotation = Sprite.rotation
			#print(get_last_slide_collision().get_angle())
	
			#CollisionShape.rotation = Sprite.rotation
	if direction and currentState==STATE.NORMAL:
		if sprint and is_on_floor():
			velocity.x = move_toward(velocity.x,MAX_SPEED*direction,30)
		elif abs(velocity.x)>=300:
			velocity.x = move_toward(velocity.x,direction*SPEED,16)
		else:
			velocity.x = direction*SPEED
	elif currentState==STATE.NORMAL:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, 50)
	
	

	move_and_slide()
	if is_on_floor():
		if currentState==STATE.VGRAB:
		#if not is_on_ceiling():
			#velocity.y-= gravity*delta
			if get_last_slide_collision():
				#Sprite.rotation_degrees = rad_to_deg(snapped(deg_to_rad(180)-get_last_slide_collision().get_angle(),0.01))
				Sprite.rotation=get_floor_normal().angle() + deg_to_rad(270)
				#CollisionShape.rotation = Sprite.rotation
		else:
			var normalangle = get_floor_normal().angle() + deg_to_rad(90)
			#print (abs(Sprite.rotation-normalangle))
			Sprite.rotation=get_floor_normal().angle() + deg_to_rad(90)


func _on_wj_time_timeout():
	if currentState==STATE.FORCED:
		currentState=STATE.NORMAL
		print("hurr")



func _on_ceilingchecker_timeout():
	currentState=STATE.NORMAL
	print("jonas")
	
	pass # Replace with function body.


