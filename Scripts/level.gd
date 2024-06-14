extends Node3D
@onready var deadtree1 = load("res://Assets/Dead Tree/object_1.tscn")
@onready var deadtree2 = load("res://Assets/Dead Tree/object_2.tscn")
@onready var deadtree3 = load("res://Assets/Dead Tree/object_3.tscn")
@onready var deadtree4 = load("res://Assets/Dead Tree/object_4.tscn")
@onready var bush_inst = load("res://Scenes/bush.tscn")

@onready var windsound =$"wind sound"
@onready var bgmusic =$bgmusic
@onready var lock = $Lock


func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	Global.connect("lock_screen",_lock_screen)
	Global.connect("not_lock_screen",_not_lock_screen)
	Global.connect("correct_pass_entered",_correct_pass_entered)
	
	lock.visible = false
	Global.password = ""
	for i in range(4):
		Global.password += str(randi_range(0,9))
	$Password.text = Global.password
		
	var kitna_pas = 5
	var halfmaplength=250
	var prob = 0.7
	var x_axis=halfmaplength
	var y_axis=halfmaplength
	while(x_axis>-halfmaplength):
		while(y_axis>-halfmaplength):
			var tree_prob = 0.93 #1 - 0.07(thala) #lol
			var chance = randf()
			if(chance>1-prob):
				var ch = randf()
				var ranx = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
				var rany = randf_range(kitna_pas/4.0,3*kitna_pas/4.0)
				var rot = randi_range(-180,180)
				if(ch < tree_prob):
					var which_tree = randi_range(1,4)
					var size = randf_range(0.7,1.4)
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
					deadtree.get_child(0).scale.x = size
					deadtree.get_child(0).scale.y = size
					deadtree.get_child(0).scale.z = size
					deadtree.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
					deadtree.global_rotation = Vector3(0,rot,0)
				else:
					var bush = bush_inst.instantiate()
					get_node("Bushes").add_child(bush)
					bush.global_position = Vector3(x_axis - ranx,0,y_axis-rany)
					bush.global_rotation = Vector3(0,rot,0)
			y_axis-=kitna_pas
		x_axis-= kitna_pas
		y_axis=halfmaplength


func _on_timer_timeout():
	$Fps.text = "FPS: "+ str(Engine.get_frames_per_second())
	$Timer.start(1)

func _on_timer_2_timeout():
	var player = load("res://Scenes/player.tscn").instantiate()
	get_node("characters").add_child(player)
	player.global_position = Vector3.ZERO
	windsound.play()
	bgmusic.play()
	$Gen.visible = false
	
func _lock_screen():
	Global.in_lock_screen = true
	lock.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _not_lock_screen():
	Global.in_lock_screen = false
	lock.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _correct_pass_entered():
	Global.safe_open = true
