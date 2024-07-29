extends CharacterBody3D


var SPEED = 1200
const JUMP_VELOCITY = 10

var dir : Vector2

@onready var cam=$Head
@export var camera_sensitivity = 50 #1 to 100 only,baaki v ho skte hai wese...


var gravity = 12.0
var angular_velocity = 15

var jumpscare = false
#var current_monster
var enemy
var can_detect_enemy = false
var can_detect_enemy_2 = false
@onready var see_enemy_time = $see_enemy_time
@onready var raycast = $head/RayCast3D

@onready var still_on_wall_check := $Wall_check/still_on_wall_check
@onready var wall_check := $Wall_check/wall_check
@onready var stick_point_holder = $Wall_check/Stick_point_holder
@onready var stick_point = $Wall_check/Stick_point_holder/Stick_point
var is_climbing = false
var gravity_enabled = true
var is_falling
@export var climb_speed = 15
var direction

@onready var terrain := $"../MTerrain"


func _ready():
	$Wall_check.top_level = true
	set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		cam.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		cam.rotation.x = clamp(cam.rotation.x , -PI/2,PI/2)

func _process(delta):
	#turns body in the direction of movement
	if direction != Vector3.ZERO and !is_climbing:
		$Wall_check.rotation.y = lerp_angle($Wall_check.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
	if direction != Vector3.ZERO and is_climbing:
		$Wall_check.rotation.y = -(atan2(get_wall_normal().z, get_wall_normal().x) - PI/2)
	$Wall_check.global_transform.origin = global_transform.origin

func _physics_process(delta):
	detect_enemy()
	if !is_climbing:
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("down") - Input.get_action_strength("up")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	climbing()
	velocity = direction * SPEED
	if not is_on_floor() and gravity_enabled:
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !is_climbing:
		velocity.y = 25
	move_and_slide()
	#match current_monster:
		#"monster1":
			#pass

func jump():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func climbing():
	#check if player is able to climb
	if wall_check.is_colliding():
		if still_on_wall_check.is_colliding():
			if Input.is_action_pressed("ui_accept"):
				if is_on_floor():
					is_climbing  = false
					velocity.y = JUMP_VELOCITY
				else:
					is_climbing = true
			else:
				is_climbing = false
		else:
			#if player is at the top of a climb, boost them over the top
			velocity.y = 5.0
			await get_tree().create_timer(0.3).timeout
			is_climbing = false
	else:
		is_climbing = false
		jump()
	
	
	if is_climbing:
		#if player is climbing disable gravity
		gravity_enabled = false
		SPEED = climb_speed
		direction = Vector3.ZERO
		gravity = 0.0 #gravity is set to zero to prevent it building up
		
		#sticks player to the wall
		stick_point_holder.global_transform.origin = wall_check.get_collision_point()
		self.global_transform.origin.x = stick_point.global_transform.origin.x
		self.global_transform.origin.z = stick_point.global_transform.origin.z
		
		#move player relative to the walls normal
		var rot = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI/2)
		var f_input = Input.get_action_strength("up") - Input.get_action_strength("down")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, f_input, 0).rotated(Vector3.UP, rot).normalized() 
	else:
		SPEED = 5.0
		gravity_enabled = true

func detect_enemy():
	if can_detect_enemy:
		raycast.top_level = true
		raycast.look_at(enemy.global_position,Vector3.UP)
		raycast.global_position = $Camera3D.global_position - Vector3(0.0,1.0,0.0)
		if can_detect_enemy_2 and raycast.is_colliding():
			if raycast.get_collider().is_in_group("enemy"):
				see_enemy_time.start(0.5)
				can_detect_enemy_2 = false
	if !can_detect_enemy:
		see_enemy_time.stop()


func camera_shake():
	$Camera3D.apply_shake()


func closest_point(point):
	var array = $location_rotation.get_overlapping_bodies()
	
	var closest_node = null
	var closest_node_distance = 0.0
	for i in array:
		var current_node_distance = point.distance_to(i.global_position)
		if closest_node == null or current_node_distance < closest_node_distance:
			closest_node = i
			closest_node_distance = current_node_distance
	return closest_node

func _on_vision_body_entered(body):
	if body.is_in_group("enemy"):
		enemy = body
		can_detect_enemy = true
		can_detect_enemy_2 = true

func _on_vision_body_exited(body):
	if body.is_in_group("enemy"):
		can_detect_enemy = false
		can_detect_enemy_2 = false
		enemy = null

func _on_see_enemy_time_timeout():
	enemy.player = self
	enemy.anim_tree["parameters/conditions/spawn"] = true


func _on_attack_body_entered(body):
	if body.is_in_group("bush"):
		body.inbush = true


func _on_attack_body_exited(body):
	if body.is_in_group("bush"):
		body.inbush = false
