extends CharacterBody3D


var SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var camera_sensitivity = 50
@onready var head = $Head

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		head.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		head.rotation.x = clamp(head.rotation.x , -PI/2,PI/2)

func _physics_process(delta):
	wall_min_slide_angle = 15
	floor_max_angle = deg_to_rad(45)
	floor_stop_on_slope = true
	SPEED = 5.0
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	# Add the gravity.
	floor_block_on_wall = true
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("crouch") and is_on_floor():
		head.position = Vector3(0.0,1.7,0.0).lerp(Vector3(0.0,1.9,0.0),delta*0.1)
	if Input.is_action_just_released("crouch"):
		head.position = Vector3(0.0,1.9,0.0).lerp(Vector3(0.0,1.7,0.0),delta*0.1)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if get_floor_angle()>deg_to_rad(45) and Input.is_action_pressed("ui_accept"):
		floor_stop_on_slope = false
		floor_max_angle = deg_to_rad(90)
		if is_on_floor():
			gravity = 0.0
			SPEED = 2.0
			wall_min_slide_angle = 90
			floor_block_on_wall = false
	if Input.is_action_pressed("sprint"):
		SPEED = 10
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
