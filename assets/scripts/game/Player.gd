extends KinematicBody2D

var bulletScene = preload("res://assets/scenes/game/instances/Bullet.tscn")
var explosionScene = preload("res://assets/scenes/game/instances/Explosion.tscn")
var realGunScene = preload("res://assets/scenes/game/instances/RealGun.tscn")
onready var progress = get_node("ProgressBar")
onready var fireTimer = get_node("FireTimer")
onready var sprite = get_node("AnimatedSprite")
var gun
var firePoint

var velocity = Vector2()
var spawn_point = Vector2(512, 220)
enum direction {LEFT, RIGHT}
var moveSpeed = 100
var fallSpeed = 35
var maxFallSpeed = 1500
var jumpSpeed = 750
var boostSpeed = 1000
var smoothingSpeed = 0.09

var isDying = false
var has_gun = false
var health = 300
var current_health = health
var take_demage = 30

func pick_up():
	var realGunInstance = realGunScene.instance()
	sprite.add_child(realGunInstance)
	gun = get_node("AnimatedSprite/RealGun")
	firePoint = get_node("AnimatedSprite/RealGun/Firepoint")
	has_gun = true

func die():
	var explosionInstance = explosionScene.instance()
	explosionInstance.position = position
	explosionInstance.one_shot = true
	get_tree().get_root().add_child(explosionInstance)
	#yield(get_tree().create_timer(1), "timeout")
	velocity = Vector2()
	position = spawn_point
	current_health = health
	progress.value = health
	isDying = false

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

func _physics_process(_delta):
	if has_gun:
		var towards_rad = gun.get_angle_to(get_global_mouse_position())
		var towards_deg = rad2deg(towards_rad)
		var current_deg = gun.rotation_degrees + towards_deg
		if direction.LEFT:
			gun.rotation_degrees = clamp(current_deg, -270, -90)
		else:
			gun.rotation_degrees = clamp(current_deg, -90, 90)
	velocity.x = lerp(velocity.x, 0, smoothingSpeed)
	
	if Input.is_action_pressed("ui_left"):
		if has_gun:
			gun.flip_v = true
			gun.position.x = -35
		sprite.flip_h = true
		sprite.play("run")
		direction.LEFT = 1
		direction.RIGHT = 0
		velocity.x -= moveSpeed
	elif Input.is_action_pressed("ui_right"):
		if has_gun:
			gun.flip_v = false
			gun.position.x = 35
		sprite.play("run")
		sprite.flip_h = false
		direction.LEFT = 0
		direction.RIGHT = 1
		velocity.x += moveSpeed
	else:
		sprite.play("default")
	
	if get_slide_count() > 0:
		var slide_collision = get_slide_collision(0)
		var slide_collider = get_slide_collision(0).collider
		if slide_collision.get("collider"):
			if slide_collider.is_in_group("JumpPad"):
				velocity.y = -boostSpeed
			elif slide_collider.is_in_group("Border"):
				if not(isDying):
					isDying = true
					die()

	if current_health <= 0:
		current_health = health
		progress.value = current_health
		die()

	if Input.is_action_pressed("ui_left_click") and has_gun:
		fire()
	
	if is_on_floor():
		if Input.is_action_pressed("ui_select"):
			velocity.y = -jumpSpeed
	else:
		if velocity.y < maxFallSpeed:
			velocity.y += fallSpeed
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
