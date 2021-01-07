extends Area2D

var velocity = Vector2()
var moveSpeed = 100
var fallSpeed = 1
var maxFallSpeed = 7
var smoothingSpeed = 0.09
var isOnFloor = false

onready var player = get_node("../Player")

func _physics_process(_delta):
	if velocity.y < maxFallSpeed:
			velocity.y += fallSpeed
	if not(isOnFloor):
		translate(velocity)

func _on_DroppedGun_body_entered(body):
	if body.is_in_group("Player"):
		player.pick_up()
		queue_free()
	isOnFloor = true
