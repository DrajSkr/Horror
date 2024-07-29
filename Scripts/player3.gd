extends CharacterBody3D

#movement variables
var speed = 15
@export var run_speed = 15.0
@export var climb_speed = 3.0

#acceleration
@export var  ACCEL_DEFAULT = 10.0
@export var  ACCEL_AIR = 2.0
@onready var accel = ACCEL_DEFAULT

#jump
@export var gravity = 30.0
@export var jump = 5.0

#physics
var player_velocity
@export var inertia = 200
var movement_enabled = true
var gravity_enabled = true
var is_falling

#camera
var cam_accel = 40
@export var mouse_sense = 0.1
var snap
var angular_velocity = 15

#Vectors
var direction = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

#references
@onready var mesh = $Wall_check
@onready var collider = $CollisionShape3D
@onready var head = $Head
@onready var head_pos = head.transform
#@onready var campivot = $Head/Camera_holder
@onready var camera = $Head/Camera3D

#climbing
@onready var still_on_wall_check := $Wall_check/still_on_wall_check
@onready var wall_check := $Wall_check/wall_check
@onready var stick_point_holder = $Wall_check/Stick_point_holder
@onready var stick_point = $Wall_check/Stick_point_holder/Stick_point
var is_climbing = false

func _ready():
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
	mesh.top_level = true
	set_process_input(true)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	#turns body in the direction of movement
	if direction != Vector3.ZERO and !is_climbing:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
	elif direction != Vector3.ZERO and is_climbing:
		mesh.rotation.y = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI/2)
	
	physics_interpolation(delta)

func _physics_process(delta):
	input()
	climbing()
	_movement(delta)

func input():
	#get keyboard input
	if !is_climbing:
		direction = Vector3.ZERO
		var h_rot = global_transform.basis.get_euler().y
		var f_input = Input.get_action_strength("down") - Input.get_action_strength("up")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()

func _jump():
	if is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump

func climbing():
	#check if player is able to climb
	if wall_check.is_colliding():
		if still_on_wall_check.is_colliding():
			if Input.is_action_pressed("jump"):
				if is_on_floor():
					is_climbing  = false
				else:
					is_climbing = true
			else:
				is_climbing = false
		else:
			#if player is at the top of a climb, boost them over the top
			_jump()
			await get_tree().create_timer(0.3).timeout
			is_climbing = false
	else:
		is_climbing = false
	
	
	if is_climbing:
		#if player is climbing disable gravity
		gravity_enabled = false
		speed = climb_speed
		direction = Vector3.ZERO
		gravity_vec = Vector3.ZERO #gravity is set to zero to prevent it building up
		
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
		speed = run_speed
		gravity_enabled = true

func _movement(delta):
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	elif is_on_ceiling():
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	#jump
	if Input.is_action_just_pressed("jump") :
		_jump()
	
	#make it move#
	if movement_enabled:
		velocity = velocity.lerp(direction * speed, accel * delta)
	
	if gravity_enabled:
		velocity = velocity + gravity_vec
	
	move_and_slide()
	

func physics_interpolation(_delta):
	mesh.global_transform.origin = global_transform.origin
