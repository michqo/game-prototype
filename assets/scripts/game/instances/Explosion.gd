extends CPUParticles2D

func die():
	queue_free()
	
func _ready():
	var timer = get_tree().create_timer(lifetime)
	timer.connect("timeout", self, "die")
