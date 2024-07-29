extends Node3D

@export var speed = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().progress = randf_range(0.0,100.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent().progress += speed * delta
