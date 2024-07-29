extends Node3D
#@onready var deadtree1 = load("res://Assets/Dead Tree/object_1.tscn")
#@onready var deadtree2 =load("res://Assets/Dead Tree/object_2.tscn")
#@onready var deadtree3 =load("res://Assets/Dead Tree/object_3.tscn")
#@onready var deadtree4 =load("res://Assets/Dead Tree/object_4.tscn")
#@onready var bush_inst = load("res://Scenes/bush.tscn")
#
#@onready var node_inst = load("res://Scenes/ai_nodes.tscn")
#var previous_node_position

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

#func _ready():
	#var windsound =$"wind sound"
	#var bgmusic =$bgmusic
#
	#var kitna_pas = 5.0
	#var halfmaplength=250
	#var prob = 0.7
	#var x_axis=halfmaplength
	#var y_axis=halfmaplength
	#previous_node_position = Vector3(x_axis,0,y_axis)
	#while(x_axis>-halfmaplength):
		#while(y_axis>-halfmaplength):
			#var tree_prob = 0.93 #1 - 0.07(thala)
			#var chance = randf()
			#if(chance>1-prob):
				#var ch = randf()
				#var ranx = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
				#var rany = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
				#var rot = randi_range(-180,180)
				#if(ch < tree_prob):
					#var which_tree = randi_range(1,4)
					#var size = randf_range(0.7,1.4)
					#var deadtree
					#if which_tree ==1:
						#deadtree = deadtree1.instantiate()
					#if which_tree ==2:
						#deadtree=deadtree2.instantiate()
					#if which_tree ==3:
						#deadtree = deadtree3.instantiate()
					#if which_tree ==4:
						#deadtree=deadtree4.instantiate()
					#get_node("Trees").add_child(deadtree)
					#deadtree.get_child(0).scale.x = size
					#deadtree.get_child(0).scale.y = size
					#deadtree.get_child(0).scale.z = size
					#deadtree.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
					#var node_position = deadtree.global_position
					#if (previous_node_position - node_position).length_squared()/2 > kitna_pas*kitna_pas:
						#var ai_node = node_inst.instantiate()
						#get_node("ai_node").add_child(ai_node)
						#ai_node.global_position = (previous_node_position + node_position)/2
					#previous_node_position = node_position
					#deadtree.global_rotation = Vector3(0,rot,0)
				#else:
					#var bush = bush_inst.instantiate()
					#get_node("Bushes").add_child(bush)
					#bush.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
					#bush.global_rotation = Vector3(0,rot,0)
			#y_axis-=kitna_pas
		#x_axis-= kitna_pas
		#y_axis=halfmaplength
	#windsound.play()
	#bgmusic.play()


func _on_timer_timeout():
	$Label.text = "FPS: "+ str(Engine.get_frames_per_second())
	$Timer.start(1)

