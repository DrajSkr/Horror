extends Node2D

var progress = []
var sceneName
var scene_load_status = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	sceneName = "res://Scenes/level.tscn"
	ResourceLoader.load_threaded_request(sceneName)
	
func _process(delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED :
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)
