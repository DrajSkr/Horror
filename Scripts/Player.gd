extends CharacterBody3D


const SPEED = 300
const JUMP_VELOCITY = 5

var dir : Vector2

@onready var cam=$Camera3D
@export var camera_sensitivity = 50 #1 to 100 only,baaki v ho skte hai wese...
@onready var flashlight = $Camera3D/Flashlight


var gravity = 12




func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.connect("hiddeninbush",_hiddeninbush)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (0.0001+camera_sensitivity*0.0001))
		cam.rotate_x(-event.relative.y * (0.0001+camera_sensitivity*0.0001))
		cam.rotation.x = clamp(cam.rotation.x , -PI/2,PI/2)
	

func _physics_process(delta):
	dir = Input.get_vector("left","right","up","down").normalized()
	if not is_on_floor():
		velocity.y -= gravity * delta
	if(not Global.insidebush):
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
	
func _hiddeninbush():
	if(Global.insidebush):
		flashlight.visible =false
	else:
		flashlight.visible =true
