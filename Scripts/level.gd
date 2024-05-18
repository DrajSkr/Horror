extends Node3D
@onready var deadtree1 = preload("res://Assets/Dead Tree/object_1.tscn")
@onready var deadtree2 =preload("res://Assets/Dead Tree/object_2.tscn")
@onready var deadtree3 =preload("res://Assets/Dead Tree/object_3.tscn")
@onready var deadtree4 =preload("res://Assets/Dead Tree/object_4.tscn")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
# Called when the node enters the scene tree for the first time.

func _ready():
	if !is_multiplayer_authority():
		return
	var kitna_pas = 5
	var x_axis=50
	var y_axis=50
	while(x_axis>-50):
		while(y_axis>-50):
			var ranx = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
			var rany = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
			var which_tree = randi_range(1,4)
			var rot = randi_range(-180,180)
			var deadtree
			if which_tree ==1:
				deadtree = deadtree1.instantiate()
			if which_tree ==2:
				deadtree=deadtree2.instantiate()
			if which_tree ==3:
				deadtree = deadtree3.instantiate()
			if which_tree ==4:
				deadtree=deadtree4.instantiate()
			
			get_child(0).add_child(deadtree)
			
			deadtree.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
			deadtree.global_rotation = Vector3(0,rot,0)
			y_axis-=kitna_pas
		x_axis-= kitna_pas
		y_axis=50
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
