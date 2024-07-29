extends CharacterBody3D


const SPEED = 300
const JUMP_VELOCITY = 5

var dir : Vector2

@onready var cam=$Camera3D
@export var camera_sensitivity = 50 #1 to 100 only,baaki v ho skte hai wese...

var gravity = 12

var jumpscare = false

var loc = false
var rot = false
var enemy
var can_detect_enemy = false
@onready var see_enemy_time = $see_enemy_time
@onready var raycast = $RayCast3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		cam.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		cam.rotation.x = clamp(cam.rotation.x , -PI/2,PI/2)
	
	

func _physics_process(delta):
	if can_detect_enemy:
		raycast.look_at(enemy.global_position,Vector3.UP)
		if raycast.is_colliding() && raycast.get_collider().is_in_group("enemy"):
			see_enemy_time.start(3.0)
	else:
		see_enemy_time.stop()
	dir = Input.get_vector("left","right","up","down").normalized()
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = (transform.basis * Vector3(dir.x, 0, dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED *delta
		velocity.z = direction.z * SPEED *delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*delta)
		velocity.z = move_toward(velocity.z, 0, SPEED*delta)

	move_and_slide()

func jumpscare_animation(left,head):
	jumpscare = true
	global_position = global_position.lerp(left.global_position + Vector3(0.0,-0.982,0.0),0.1)
	look_at(head.global_position)
	$Camera3D.global_position = $Camera3D.global_position.lerp(left.global_position, 0.2)
	$Camera3D.look_at(head.global_position)

func camera_shake():
	$Camera3D.apply_shake()


func _on_location_body_entered(body):
	if body.is_in_group("enemy"):
		enemy = body
		loc = true
		body.anim_tree["parameters/conditions/chase"] = true
		if loc == true:
			if rot != true:
				enemy.loc(global_position,transform.basis.x)
			if rot == true:
				enemy.loc(global_position,transform.basis.z)
		$send_data_to_enemy.start()


func _on_location_rotation_body_entered(body):
	if body.is_in_group("enemy"):
		rot = true


func _on_location_body_exited(body):
	if body.is_in_group("enemy"):
		rot = false


func _on_location_rotation_body_exited(body):
	if body.is_in_group("enemy"):
		loc = false
		body.anim_tree["parameters/conditions/chase"] = false
		$send_data_to_enemy.stop()


func _on_send_data_to_enemy_timeout():
	if loc == true:
		if rot != true:
			enemy.loc(global_position,transform.basis.x)
		if rot == true:
			enemy.loc(global_position,transform.basis.z)


func _on_vision_body_entered(body):
	if body.is_in_group("enemy"):
		can_detect_enemy = true

func _on_vision_body_exited(body):
	if body.is_in_group("enemy"):
		can_detect_enemy = false

func _on_see_enemy_time_timeout():
	enemy.player = self
	enemy.anim_tree["parameters/conditions/spawn"] = true

