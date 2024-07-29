extends Area3D

@onready var monster_inst = load("res://New folder/monster_1.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		var monster = monster_inst.instantiate()
		var near = body.closest_point(body.global_position + (body.transform.basis.z.normalized() * 30.0))
		get_parent().add_child(monster)
		monster.global_position = near.global_position
		monster.scale *= 2.0
		monster.get_node("rustle").play()
		monster.player = body
		queue_free()
