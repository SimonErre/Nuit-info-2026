extends KinematicBody2D

onready var anim = $AnimatedSprite  # Lien vers AnimatedSprite (Godot 3)
var speed = 150.0
var velocity = Vector2()

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
		
		# Gérer les animations
		if velocity.x > 0:
			anim.play("walk_right")
		elif velocity.x < 0:
			anim.play("walk_left")
		elif velocity.y > 0:
			anim.play("walk_down")
		elif velocity.y < 0:
			anim.play("walk_up")
	else:
		anim.stop()
		anim.frame = 0

	move_and_slide(velocity)
