extends Node3D
@onready var deadtree1 = load("res://Assets/Dead Tree/object_1.tscn")
@onready var deadtree2 =load("res://Assets/Dead Tree/object_2.tscn")
@onready var deadtree3 =load("res://Assets/Dead Tree/object_3.tscn")
@onready var deadtree4 =load("res://Assets/Dead Tree/object_4.tscn")

@onready var windsound =$"wind sound"
@onready var bgmusic =$bgmusic
@onready var floormesh=$Floor/MeshInstance3D
@onready var grass=$SimpleGrassTextured
@onready var player = $Player

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	var kitna_pas = 2
	var halfmaplength=250
	var prob = 0.7
	var x_axis=halfmaplength
	var y_axis=halfmaplength
	while(x_axis>-halfmaplength):
		while(y_axis>-halfmaplength):
			var chance = randf()
			if(chance>1-prob):
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
					get_node("Trees").add_child(deadtree)
					deadtree.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
					deadtree.global_rotation = Vector3(0,rot,0)
			y_axis-=kitna_pas
		x_axis-= kitna_pas
		y_axis=halfmaplength
	
