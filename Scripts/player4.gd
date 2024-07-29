extends CharacterBody3D


var SPEED = 15.0
const JUMP_VELOCITY = 4.5
@export var camera_sensitivity = 50
@onready var head = $Head
@onready var wall_check = $Wall_check/still_on_wall_check

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
	floor_block_on_wall = true
	wall_min_slide_angle = 15
	floor_max_angle = 45
	SPEED = 15.0
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if is_on_wall() and Input.is_action_pressed("ui_accept"):
		floor_block_on_wall = false
	else:
		wall_min_slide_angle = 15
		floor_max_angle = 45
		#velocity.z -= gravity

	move_and_slide()

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
