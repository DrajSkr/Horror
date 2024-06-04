extends RigidBody3D

@onready var s1= preload("res://Assets/Sticks/small_stick_1.tscn")
@onready var s2= preload("res://Assets/Sticks/small_stick_2.tscn")
@onready var s3= preload("res://Assets/Sticks/small_stick_3.tscn")



func _on_area_3d_body_entered(body):
	print(body.name)
	if body.name == "Player":
		var num = randi_range(1,3)
		var stick1 :Node
		var stick2 :Node
		if(num==1):
			stick1 = s1.instantiate()
		if(num==2):
			stick1 = s2.instantiate()
		if(num==3):
			stick1 = s3.instantiate()
		
		num = randi_range(1,3)
		if(num==1):
			stick2 = s1.instantiate()
		if(num==2):
			stick2 = s2.instantiate()
		if(num==3):
			stick2 = s3.instantiate()
		
		get_parent().get_node("Sticks").add_child(stick1)
		get_parent().get_node("Sticks").add_child(stick2)
		stick1.global_position = self.global_position
		stick1.global_position.y+=1
		stick2.global_position.y+=1
		stick2.global_position = self.global_position
		print(stick1.position)
		print(body.position)
		queue_free()
		
		
