extends Area3D

@onready var monster_inst = load("res://Scenes/monster_1.tscn")
@onready var ghost_inst = load("res://Scenes/ghost_girl.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		#var mon = randi_range(0,1)
		var mon = 1
		if mon == 1:
			var monster = monster_inst.instantiate()
			var near = body.closest_point(body.global_position + (body.transform.basis.z.normalized() * 30.0))
			get_parent().add_child(monster)
			monster.global_position = near.global_position
			monster.scale *= 2.0
			monster.get_node("rustle").play()
			monster.player = body
			print(monster)
			queue_free()
		#else:
			#var monster = ghost_inst.instantiate()
			#var near = body.closest_point(body.global_position + (-body.transform.basis.z.normalized() * 10.0))
			#get_parent().add_child(monster)
			#monster.global_position = near.global_position
			#monster.get_node("rustle").play()
			#print(monster)
			#queue_free()
