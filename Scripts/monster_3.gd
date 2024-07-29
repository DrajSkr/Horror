extends CharacterBody3D

@onready var hip = $metarig/Skeleton3D/hip
@onready var hands = $Armature/Skeleton3D/Basemesh_F_004
@onready var ani = $AnimationPlayer


func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hands.global_position = hip.global_position - Vector3(0,1.3,0)
