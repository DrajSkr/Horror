extends Node

@export var player : Player
@export var anim_tree : AnimationTree
@export var skills_container : SkillsContainer
@export var movement_controller : MovementController
@export var camera_controller : CameraController

var last_movement_state : movement_state
var is_fired : bool = false


func _ready():
	skills_container.anim_tree = anim_tree
	skills_container.completed_recovery.connect(_on_completed_recovery)

func _process(_delta):
	if player.is_attacking and player.is_dashing:
		skills_container._reset()
		player.is_attacking = false

func _on_pressed_primary_fire():
	if is_skill_active():
		is_fired = true
		return
	
	player.is_attacking = true
	
	var current_skill : ActiveSkill = skills_container.get_current_skill()
	movement_controller.acceleration = current_skill.acceleration
	movement_controller.dash(current_skill.dash_velocity, current_skill.dash_duration, current_skill.dash_delay)
	
	camera_controller.set_fov(current_skill.camera_fov)

	skills_container.start_attack()


func _on_completed_recovery():
	player.is_attacking = false
	movement_controller._on_set_movement_state(last_movement_state)
	camera_controller.set_fov(last_movement_state.camera_fov)
	if is_fired:
		is_fired = false
		_on_pressed_primary_fire()


func _on_set_movement_state(_movement_state : movement_state):
	last_movement_state = _movement_state


func is_skill_active() -> bool:
	return skills_container.attack_state != ActiveSkill.State.READY
