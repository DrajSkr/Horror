extends Node3D
class_name  CameraController

signal set_cam_rotation(_cam_rotation : float)

@export var player : Player

@onready var yaw_node = $camyaw
@onready var pitch_node = $camyaw/campitch
@onready var camera = $camyaw/campitch/SpringArm3D/Camera3D

var yaw := 0.0
var pitch := 0.0

var yaw_sensitivity := 0.07
var pitch_sensitivity := 0.07

var yaw_acceleration := 15.0
var pitch_acceleration := 15.0

var pitch_max := 75.0
var pitch_min := -55.0

var tween : Tween

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity

func _physics_process(delta):
	pitch  = clamp(pitch,pitch_min,pitch_max)
	
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y,yaw,yaw_acceleration*delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x,-pitch,pitch_acceleration*delta)
	
	set_cam_rotation.emit(yaw_node.rotation.y)

func _on_set_movement_state(_movement_state : movement_state):
	if player.is_attacking:
		return
	
	set_fov(_movement_state.camera_fov)

func set_fov(value : float):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(camera, "fov", value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
