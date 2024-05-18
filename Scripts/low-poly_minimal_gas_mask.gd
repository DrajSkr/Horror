extends Node3D

func _on_area_3d_body_entered(body):
	if (body.name == "Player") and not Global.PlayerGotMask:
		Global.PlayerGotMask = true
		$"../Gas-mask".visible = true
		self.queue_free()
		
