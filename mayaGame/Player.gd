extends KinematicBody2D

var speed = 150.0
var velocity = Vector2(0,0)

func _ready():
	add_to_group("player")

func _physics_process(delta):
	velocity = Vector2()
	
	# Récupère les touches fléchées ou ZQSD
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	move_and_slide(velocity)
