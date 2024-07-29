extends CharacterBody3D

var movement_speed: float = 5.0
var player
var state_machine

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var head = $Armature/Skeleton3D/head
@onready var left = $Armature/Skeleton3D/left_hand/Marker3D

@onready var spawnArea = $Area3D/CollisionShape3D.shape.extents
@onready var origin = $Area3D/CollisionShape3D.global_position
var elapsed_time = 0.0
var period = 0.0
var x = 0.0
var z = 0.0
var headturn = false

var rota
var loca
var point
var can_detect_rot = false

func _ready():
	$AnimationTree.active = true
	player = null
	anim_tree["parameters/conditions/attack"] = false
	anim_tree["parameters/conditions/spawn"] = false
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta):
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"idle":
			if elapsed_time > period: #random point selected within area3D in 1-3 sec
				period = randf_range(3.0,5.0)
				elapsed_time = 0.0
				x = randf_range(-4.0,4.0)
				var arr = [-1,1]
				z = global_position.z + arr[randi_range(0,1)]*sqrt(16.0 - (x*x))
				x += global_position.x
			elapsed_time += get_process_delta_time()
			await get_tree().process_frame
			var target_point = Vector3(x,global_position.y,z)
			navigation_agent.set_target_position(target_point)
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			#if $RayCast3D.is_colliding():
				#if $RayCast3D.get_collider().is_in_group("tree"):
					#next_path_position = transform.basis.x * 5.0
			velocity = current_agent_position.direction_to(next_path_position) * 0.7
			transform = transform.interpolate_with(transform.looking_at(target_point), 0.1)
		"scared":
			transform = transform.interpolate_with(transform.looking_at(player.global_position), 0.1)
		"walk":
			#anim_tree.advance(delta * 1.0) #controls speed of animation
			if player != null:
				navigation_agent.set_target_position(player.global_position)
				var current_agent_position: Vector3 = global_position
				var next_path_position: Vector3 = navigation_agent.get_next_path_position()
				velocity = current_agent_position.direction_to(next_path_position) * movement_speed
				transform = transform.interpolate_with(transform.looking_at(player.global_position), 0.1)
		"attack":
			$CollisionShape3D.disabled = true
			player.jumpscare_animation(left,head)
			#anim_tree.advance(delta * 0.000001) #controls speed of animation
		"chase":
			point = loca + (rota.normalized() * 40.0)
			navigation_agent.set_target_position(point)
			var current_agent_position: Vector3 = global_position
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * movement_speed
			velocity += rota.normalized() * movement_speed
			transform = transform.interpolate_with(transform.looking_at(point), 0.1)
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		anim_tree["parameters/conditions/spawn"] = true
		player = get_node(get_path_to(body))


func _on_attack_range_body_entered(body):
	if body.is_in_group("player"):
		anim_tree.set("parameters/conditions/attack",true)


func _on_attack_range_body_exited(body):
	if body.is_in_group("player"):
		anim_tree.set("parameters/conditions/attack",false)


func attack_damage():
	if anim_tree["parameters/conditions/attack"] == true:
		print("player has been attacked")
		#player.health -=10
		#player.take_damage()

func camera_shake():
	player.camera_shake()


func loc(pl_loc,pl_rot):
	loca = pl_loc
	rota = pl_rot


