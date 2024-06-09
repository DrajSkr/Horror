extends Node3D


func _unhandled_input(_event):
	if(Input.is_action_just_pressed("Hide")):
		if(Global.hiddeninsidebush and Global.inbush):
			Global.hiddeninsidebush = false
			Global.emit_signal("hiddeninbush")
		elif (Global.inbush and not Global.hiddeninsidebush):
			Global.hiddeninsidebush = true
			Global.emit_signal("hiddeninbush")


func _on_detect_body_entered(body):
	if body.name == "Player":
		Global.inbush = true


func _on_detect_body_exited(body):
	if body.name == "Player":
		Global.inbush = false

