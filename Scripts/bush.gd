extends Node3D

var inbush = false
@onready var bushsound = $Bush

func _unhandled_input(_event):
	if(Input.is_action_just_pressed("Hide")):
		if(Global.hiddeninsidebush and inbush):
			Global.emit_signal("nothiddeninbush")
		elif (inbush and not Global.hiddeninsidebush):
			Global.emit_signal("hiddeninbush")


func _on_detect_body_entered(body):
	if body.name == "Player":
		inbush = true

func _on_detect_body_exited(body):
	if body.name == "Player":
		inbush = false
		

func _process(_delta):
	if (inbush and not Global.hiddeninsidebush and Global.dir != Vector2.ZERO and !bushsound.playing):
		bushsound.play()
	elif (inbush and Global.dir == Vector2.ZERO):
		bushsound.stop()
	elif (Global.hiddeninsidebush):
		bushsound.stop()
	elif not inbush:
		bushsound.stop()
