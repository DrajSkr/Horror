extends Node3D

var inbush = false

func _unhandled_input(_event):
	if(Input.is_action_just_pressed("Hide")):
		if(Global.insidebush and inbush):
			Global.insidebush = false
			Global.emit_signal("hiddeninbush")
		elif (inbush and not Global.insidebush):
			Global.insidebush = true
			Global.emit_signal("hiddeninbush")


func _on_detect_body_entered(body):
	if body.name == "Player":
		inbush = true


func _on_detect_body_exited(body):
	if body.name == "Player":
		inbush = false
