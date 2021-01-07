extends Area2D

var speed = 1200
var lifetime = 2

var explosionScene = preload("res://assets/scenes/game/instances/Explosion.tscn")

onready var timer = get_tree().create_timer(lifetime)

func die():
	var explosionInstance = explosionScene.instance()
	explosionInstance.position = position
	explosionInstance.one_shot = true
	get_tree().get_root().add_child(explosionInstance)
	queue_free()

func _ready():
	timer.connect("timeout", self, "die")

# projectile trail, use line2d or something

func _physics_process(delta):
	position += transform.x * speed * delta
	
func _on_Bullet_body_entered(body):
	if body.is_in_group("Enemy"):
		body.current_health -= body .take_demage
		body.progress.value = body.current_health
		die()
	elif body.is_in_group("Player"):
		body.current_health -= body .take_demage
		body.progress.value = body.current_health
		die()
	die()
