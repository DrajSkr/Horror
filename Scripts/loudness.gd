extends Node

@onready var item_list = get_node("ItemList")
@onready var Awazmeter = $Awazmeter
@onready var device_info = $DeviceInfo


func _ready():
	Global.
	for item in AudioServer.get_input_device_list():
		item_list.add_item(item)

	var device = AudioServer.input_device
	for i in range(item_list.get_item_count()):
		if device == item_list.get_item_text(i):
			item_list.select(i)
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var power = AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index("Record"),0) + 200
	if(power>100):
		Awazmeter.value = power
	else:
		Awazmeter.value=0
	device_info.text = "Currently selected: " + AudioServer.input_device
	
	

func _on_select_pressed():
	for item in item_list.get_selected_items():
		var device = item_list.get_item_text(item)
		AudioServer.input_device = device


func _on_reload_pressed():
	get_tree().reload_current_scene()
