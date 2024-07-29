extends Node

@export var animation_tree : AnimationTree
@export var player : CharacterBody3D

var on_floor_blend : float = 1
var on_floor_blend_target : float = 1

var tween : Tween

func _physics_process(delta):
	if not player.is_on_floor() and not player.is_on_wall():
		on_floor_blend_target = 0
	else:
		on_floor_blend_target = 1
	#on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, (10 / 0.01677) * delta)
	on_floor_blend = move_toward(on_floor_blend,on_floor_blend_target, 2.0 * delta)
	animation_tree["parameters/on_floor_blend/blend_amount"] = on_floor_blend

func _on_set_movement_state(_movement_state : movement_state):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(animation_tree,"parameters/movement_blend/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animarion_speed, 0.7)

func _jump(jump_state : String):
	animation_tree["parameters/" + jump_state + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


#func on_pressed_dash:
	
