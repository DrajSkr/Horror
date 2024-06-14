extends CanvasLayer

func _on_start_pressed():
	var loadingScreen = load("res://Scenes/loading.tscn")
	get_tree().change_scene_to_packed(loadingScreen)

func _on_settings_pressed():
	var settings = load("res://Scenes/settings.tscn")
	get_tree().change_scene_to_packed(settings)

func _on_exit_pressed():
	get_tree().quit()
