extends CharacterBody3D
class_name  Player

signal pressed_jump(jump_state : String)
signal pressed_dash
signal pressed_primary_fire
signal set_movement_state(_movement_state : movement_state)
signal set_movement_dir(_movement_dir : Vector3)
var movement_dir : Vector3

@export var movement_states : Dictionary
@onready var ground = $ground

var is_attacking : bool = false
var is_dashing : bool = false

func _input(event):
	if event.is_action_pressed("primary_fire"):
		pressed_primary_fire.emit()
	
	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		movement_dir.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_dir.z = Input.get_action_strength("up") - Input.get_action_strength("down")
		#if is_movement_ongoing():
			##if Input.is_action_just_pressed("sprint"):
				##pressed_dash.emit()
			##if Input.is_action_pressed("sprint"):
				##set_movement_state.emit(movement_states["dash"])
			#if not is_dashing and Input.is_action_pressed("sprint"):
				#set_movement_state.emit(movement_states["run"])
			#if not is_dashing and not Input.is_action_pressed("sprint"):
				#set_movement_state.emit(movement_states["walk"])
		#else:
			#set_movement_state.emit(movement_states["idle"])
	if event.is_action_pressed("jump"):
		ground.enabled = true
		pressed_jump.emit("jump")
	if Input.is_action_pressed("movement") or Input.is_action_just_released("movement"):
		if is_movement_ongoing():
			if event.is_action_pressed("sprint"):
				is_dashing = true
				
				pressed_dash.emit()
				set_movement_state.emit(movement_states["dash"])
			if not is_dashing:
				if Input.is_action_pressed("sprint"):
					set_movement_state.emit(movement_states["run"])
				else:
					set_movement_state.emit(movement_states["walk"])
		else :
			set_movement_state.emit(movement_states["idle"])

func _ready():
	ground.enabled = false
	set_movement_state.emit(movement_states["idle"])

func _physics_process(_delta):
	
	### place this block such that it is activated only while dashing
	if is_dashing:
		$"mc/root/Skeleton3D/original body_003".get_active_material(0).set_shader_parameter('color',Color("red"))
	else:
		$"mc/root/Skeleton3D/original body_003".get_active_material(0).set_shader_parameter('color',Color("white"))
	### place this block such that it is activated only while dashing
	
	if is_movement_ongoing():
		set_movement_dir.emit(movement_dir)
	if velocity.y < -1.0 and not is_movement_ongoing() and ground.is_colliding():
		ground.enabled = false
		pressed_jump.emit("land")

func is_movement_ongoing() -> bool:
	return abs(movement_dir.x) > 0 or abs(movement_dir.z) > 0

func _on_dash_timer_timeout():
	is_dashing = false
	if Input.is_action_pressed("sprint"):
		set_movement_state.emit(movement_states["run"])
	elif Input.is_action_pressed("movement"):
		set_movement_state.emit(movement_states["walk"])
	else:
		set_movement_state.emit(movement_states["idle"])
