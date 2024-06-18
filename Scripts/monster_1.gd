extends CharacterBody3D

var movement_speed: float = 300.0
var player
var state_machine

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var head = $Armature/Skeleton3D/head
@onready var left = $Armature/Skeleton3D/left_hand/Marker3D

var point
var can_detect_rot = false
var tree = null
var disp
var disp2
var can_rustle = false
var hide_time :float = 10.0

func _ready():
	$AnimationTree.active = true
	player = null
	anim_tree["parameters/conditions/attack"] = false
	anim_tree["parameters/conditions/spawn"] = false
	state_machine = anim_tree.get("parameters/playback")
	disp = global_position + Vector3(10.0,0.0,0.0)
	$avoid_getting_stuck.start()

func _physics_process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"scared":
			transform = transform.interpolate_with(transform.looking_at(player.global_position), 0.1)
		"walk":
			if player != null:
				navigation_agent.set_target_position(player.global_position)
				var current_agent_position: Vector3 = global_position
				var next_path_position: Vector3 = navigation_agent.get_next_path_position()
				point = Vector3(Global.player_pos.x,0,Global.player_pos.z)
				velocity = current_agent_position.direction_to(point) * movement_speed * delta
				transform = transform.interpolate_with(transform.looking_at(player.global_position), 0.1)
		"attack":
			$thump1.stop()
			$thump2.stop()
			$CollisionShape3D.disabled = true
			player.jumpscare_animation(left,head)
		"stalk":
			if can_rustle:
				$random_rustle.start(randf_range(5.0,10.0))
			point = player.global_position + (global_position - player.global_position).normalized() * 5.0
			point = Vector3(point.x,0,point.z)
			navigation_agent.set_target_position(point)
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			disp2 = next_path_position - global_position
			velocity = current_agent_position.direction_to(point) * movement_speed * delta * 1.5
			transform = transform.interpolate_with(transform.looking_at(player.global_position), 0.1)
	if Global.hiddeninsidebush:
		velocity = Vector3.ZERO
		hide_time -= delta
		if(hide_time<0):
			self.queue_free()
			Global.ghost_on_hunt = false
	move_and_slide()
	


func _on_attack_range_body_entered(body):
	if body.name == "Player":
		anim_tree.set("parameters/conditions/attack",true)


func _on_attack_range_body_exited(body):
	if body.name == "Player":
		anim_tree.set("parameters/conditions/attack",false)


func attack_damage():
	if anim_tree["parameters/conditions/attack"] == true:
		print("player has been attacked")
		#player.health -=10
		#player.take_damage()

func camera_shake():
	player.camera_shake()


func _on_avoid_getting_stuck_timeout():
	if $CollisionShape3D.disabled == true:
		$CollisionShape3D.disabled = false
	if (disp - global_position).length_squared() < 1.0 and disp2.length_squared() > 5.0:
		$CollisionShape3D.disabled = true
	disp = global_position


func _on_random_rustle_timeout():
	#$rustle.volume_db = 0.0
	$rustle.play()
