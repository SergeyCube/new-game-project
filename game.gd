extends Node3D

func _ready() -> void:
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	GDSync.start_multiplayer()
	
func _on_level_platform_input_event(_camera: Node, event: InputEvent, event_position: Vector3, 
normal: Vector3, _shape_idx: int) -> void:
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	if event.pressed != true: return
	if normal != Vector3(0.0, 1.0, 0.0): return
	for node in get_tree().get_nodes_in_group("rmb_walking_c"):
		if node.is_in_group("having_focus"): 
			node.destination = Vector3(event_position.x, 0, event_position.z)

func _physics_process(delta: float) -> void:
	#Walking with RMB
	get_tree().call_group("rmb_walking_c", "update_parent_velocity", delta)
	#Move_and_slide parent. Must be called after all manipulations with Character3d's velocity
	get_tree().call_group("move_and_slide_c", "move_and_slide_parent")
	
func connected():
	print("You are connected now")
func connection_failed(error : int):
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")      
