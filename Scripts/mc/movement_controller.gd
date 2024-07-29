extends Node
class_name MovementController

@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var rotation_speed : float = 8.0
@export var fall_gravity : float = 45
var jump_gravity : float = fall_gravity
var dir : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var player_init_rotation : float
var dash_timer : Timer = Timer.new()
var dash_velocity : Vector3
var tween : Tween
var cam_rotation : float = 0

func _ready():
	player_init_rotation = player.rotation.y
	dash_timer.timeout.connect(player._on_dash_timer_timeout)
	dash_timer.one_shot = true
	add_child(dash_timer)

func _physics_process(delta):
	velocity.x = speed * dir.normalized().x * delta
	velocity.z = speed * dir.normalized().z * delta
	if player.is_dashing:
		velocity.y = 0   
		velocity.x = dash_velocity.x
		velocity.z = dash_velocity.z
	elif player.is_attacking:
		velocity.y = 0
		if dash_timer.time_left > 0:
			velocity.x = dash_velocity.x
			velocity.z = dash_velocity.z
		else:
			velocity.x =0
			velocity.z = 0
	else:
		var target_rotation = atan2(dir.x, dir.z) - player_init_rotation
		mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	if not player.is_on_floor() and not player.is_attacking and not player.is_dashing:
		if velocity.y >= 0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	
	#player.velocity = velocity
	player.velocity = player.velocity.lerp(velocity,acceleration*delta)
	player.move_and_slide()
	#print(velocity)
	
	#var target_rotataion = atan2(dir.x,dir.z) - player.rotation.y
	#mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y,target_rotataion,rotation_speed*delta)

func dash(_velocity : Vector3, duration : float, delay : float):
	force_rotate_mesh(delay)
	if not player.is_dashing:
		await get_tree().create_timer(delay).timeout
	dash_timer.start(duration)
	var rotation : float = atan2(dir.x, dir.z)
	dash_velocity = _velocity.rotated(Vector3.UP, rotation)


#func is_dashing() -> bool:
	#return dash_timer.time_left > 0


func force_rotate_mesh(_transition_timer : float):
	if tween:
		tween.kill()

	var target_rotation : Vector3 = mesh_root.rotation
	target_rotation.y = lerp_angle(mesh_root.rotation.y, atan2(dir.x, dir.z) - player_init_rotation, 1)
	
	tween = create_tween()
	tween.tween_property(mesh_root, "rotation", target_rotation, _transition_timer)

func _jump(jump_state : String):
	#if player.is_dashing:
		#return
	#
	#if player.is_attacking:
		#return
	
	if jump_state == "jump":
		#await get_tree().create_timer(0.1).timeout
		velocity.y = 20.0

func _on_set_movement_state(_movement_state : movement_state):
	if player.is_attacking:
		return
	
	speed = _movement_state.movement_speed
	acceleration = _movement_state.acceleration

func _on_set_movement_dir(_movement_dir : Vector3):
	if player.is_attacking:
		return
	
	dir = _movement_dir.rotated(Vector3.UP, cam_rotation + player_init_rotation)

func _on_set_cam_rotation(_cam_rotation : float):
	cam_rotation = _cam_rotation


func _on_pressed_dash():
	dash(Vector3(0.0, 0.0, 50.0), 0.3, 0.01)
