extends CharacterBody3D


var SPEED = 20.0
const JUMP_VELOCITY = 25
var angular_velocity = 15

@onready var head = $head
@export var camera_sensitivity = 50
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction
var is_climbing = false

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		head.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		head.rotation.x = clamp(head.rotation.x , -PI/2,PI/2)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	#turns body in the direction of movement
	if direction != Vector3.ZERO and !is_climbing:
		$Wall_check.rotation.y = lerp_angle($Wall_check.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
	elif direction != Vector3.ZERO and is_climbing:
		$Wall_check.rotation.y = -(atan2(get_wall_normal().z, get_wall_normal().x) - PI/2)

func _physics_process(delta):
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	SPEED = 20.0
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if is_on_wall() and Input.is_action_pressed("ui_accept"):
		gravity = 0
		velocity.y = 0
		direction = (transform.basis * Vector3(input_dir.x, -input_dir.y, 0)).normalized()
		SPEED = 2.0
		if direction.y:
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
		#velocity -= gravity * (get_wall_normal())

	move_and_slide()
