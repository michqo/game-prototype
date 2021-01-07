extends VBoxContainer

onready var world = preload("res://assets/scenes/game//World.tscn")
onready var about = preload("res://assets/scenes/ui/AboutMenu.tscn")

func _on_Button_pressed():
	get_tree().change_scene_to(world)


func _on_AboutButton_pressed():
	get_tree().change_scene_to(about)
