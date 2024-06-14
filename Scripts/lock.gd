extends Control

var entered_pass = ""
@onready var wrong_timer = $wrong_timer

func update():
	for i in range(1,5):
		if(entered_pass.length()>=i):
			get_node("Nums").get_child(i-1).visible = true
			get_node("Nums").get_child(i-1).frame = int(entered_pass[-i])+26
		else:
			get_node("Nums").get_child(i-1).visible = false

func _ready():
	update()
	get_node("wrong").visible = false

func add(a):
	if(entered_pass.length() <4):
		entered_pass += str(a)
	update()

func _on0__pressed():
	add(0)

func _on1__pressed():
	add(1)
	print(1)

func _on2__pressed():
	add(2)

func _on3__pressed():
	add(3)

func _on4__pressed():
	add(4)

func _on5__pressed():
	add(5)

func _on6__pressed():
	add(6)

func _on7__pressed():
	add(7)

func _on8__pressed():
	add(8)

func _on9__pressed():
	add(9)

func _on_enter_pressed():
	if(entered_pass == Global.password):
		Global.emit_signal("correct_pass_entered")
		Global.emit_signal("not_lock_screen")

	else:
		wrong_timer.start(0.5)
		get_node("wrong").visible = true
		entered_pass = ""
		update()


func _on_wrong_timer_timeout():
	get_node("wrong").visible = false
