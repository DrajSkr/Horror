extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var cam=$Camera3D
@export var camera_sensitivity = 50 #1 to 100 only,baaki v ho skte hai wese...

var gravity = 12


func _ready():
	#cam.enabled = is_multiplayer_authority()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event):
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		cam.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		cam.rotation.x = clamp(cam.rotation.x , -PI/2,PI/2)

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
