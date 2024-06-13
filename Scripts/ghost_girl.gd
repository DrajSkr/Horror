extends Node3D

@onready var radi = $radius
@onready var hunt = false
var ghost_speed = 2
var hide_time :float = 10.0
@onready var delay_timer = $delaytimer
var delaytime = 1.5


var hidetime= hide_time

func _ready():
	self.visible=false

func _on_radius_body_entered(body):
	if body.name == "Player" :
		self.visible = true
		delay_timer.start(delaytime)
		look_at(Global.player_pos)
		Global.ghost_on_hunt = true

func _process(delta):
	if(hunt and Global.hiddeninsidebush == false):
		var direc = Global.player_pos - self.global_position
		self.global_position += direc.normalized()*delta*ghost_speed
		ghost_speed+=0.1*delta
		look_at(Global.player_pos)
	if(hunt and Global.hiddeninsidebush):
		hidetime -= delta
		if(hidetime<0):
			self.queue_free()
			Global.ghost_on_hunt = false
	else:
		hidetime = hide_time


func _on_attack_body_entered(body):
	if body.name == "Player":
		print("jumpscare")

func _on_delaytimer_timeout():
	hunt = true
