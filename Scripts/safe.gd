extends StaticBody3D

var player_nearby :bool = false

func _ready():
	Global.connect("correct_pass_entered",_correct_pass_entered)
	
func _correct_pass_entered():
	$AnimationPlayer.play("Door_open")
	
	
func _unhandled_input(event):
	if(Input.is_action_just_pressed("Interact")):
		if(player_nearby and Global.safe_open == false and Global.in_lock_screen == false):
			Global.emit_signal("lock_screen")

		elif(Global.in_lock_screen):
			Global.emit_signal("not_lock_screen")
			


func _on_area_3d_body_entered(body):
	if body.name == "Player":
		player_nearby = true


func _on_area_3d_body_exited(body):
	if body.name == "Player":
		player_nearby = false
