extends Node2D


func _on_button_pressed() -> void:
	var loadingScreen = load("res://Scenes/loading.tscn")
	get_tree().change_scene_to_packed(loadingScreen)
	
