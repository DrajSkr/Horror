extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if (body.name == "Player"):
		Global.playerisnearneedle = true# Replace with function body.


func _on_area_3d_body_exited(body):
	if (body.name == "Player"):
		Global.playerisnearneedle = false # Replace with function body.

func _unhandled_input(event):
	if (Input.is_action_just_pressed("Interact") and  Global.playerisnearneedle == true):
		Global.emit_signal("needleequipped")
		self.queue_free()
		
