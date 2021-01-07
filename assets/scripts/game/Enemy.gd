extends KinematicBody2D

var bulletScene = preload("res://assets/scenes/game/instances/Bullet.tscn")
var explosionScene = preload("res://assets/scenes/game/instances/Explosion.tscn")
onready var animatedsprite = get_node("AnimatedSprite")
onready var gun = get_node("AnimatedSprite/Gun")
onready var player = get_node("../Player")
onready var progress = get_node("ProgressBar")
onready var firePoint = get_node("AnimatedSprite/Gun/Firepoint")
onready var fireTimer = get_node("Timer")

var velocity = Vector2()
var spawn_point = Vector2(4950, -150)
var max_attack_distance = 650
var min_attack_distance = 70
var jump_distance = 64
var boostSpeed = 1000
var fallSpeed = 35
var jumpSpeed = 750
var maxFallSpeed = 1500
var moveSpeed = 50

var health = 300
var current_health = health
var take_demage = 30

func jump():
	if is_on_floor():
		velocity.y = -jumpSpeed

func pathfinding():
	var x_distance = abs(player.position.x) - abs(position.x)
	#var y_distance = abs(player.position.y) - abs(position.y)	
	if x_distance < jump_distance:
		#jump()
		pass
	var angle_between = player.get_angle_to(position)
	var deg_angle = rad2deg(angle_between)
	if deg_angle < 90 && deg_angle > -90:
		animatedsprite.flip_h = true
		animatedsprite.play("run")
		gun.flip_v = true
		gun.position.x = -35
		velocity.x -= moveSpeed
	else:
		animatedsprite.flip_h = false
		animatedsprite.play("run")
		gun.flip_v = false
		gun.position.x = 35
		velocity.x += moveSpeed

func die():
	var explosionInstance = explosionScene.instance()
	explosionInstance.position = position
	explosionInstance.one_shot = true
	get_tree().get_root().add_child(explosionInstance)
	queue_free()
	#current_health = health
	#progress.value = current_health
	#position = spawn_point
	#velocity = Vector2()
	
func fire():
	if fireTimer.is_stopped():
		var bulletInstance = bulletScene.instance()
		bulletInstance.rotation = gun.rotation
		bulletInstance.position = firePoint.get_global_position()
		get_tree().get_root().add_child(bulletInstance)
		fireTimer.start()

func _ready():
	progress.max_value = health
	progress.value = health
	progress.percent_visible = false
	animatedsprite.flip_h = true
	gun.flip_v = true
	gun.position.x = -35
	gun.rotation_degrees = 90

func _physics_process(_delta):
	velocity.x = lerp(velocity.x, 0, 0.3)
	
	var between_distance = player.position.distance_to(position)
	if between_distance < max_attack_distance && between_distance > min_attack_distance:
		gun.look_at(player.position)
		fire()
		pathfinding()
	else:
		animatedsprite.play("default")
	
	if get_slide_count() > 0:
		var slide_collision = get_slide_collision(0)
		var slide_collider = get_slide_collision(0).collider
		if slide_collision.get("collider"):
			if slide_collider.is_in_group("JumpPad"):
				velocity.y = -boostSpeed
			elif slide_collider.is_in_group("Border"):
				die()
				
	if current_health <= 0:
		die()
	
	if not(is_on_floor()):
		if velocity.y < maxFallSpeed:
			velocity.y += fallSpeed
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_JumpAreas_body_entered(body):
	if body.is_in_group("Enemy"):
		jump()
