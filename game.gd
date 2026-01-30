extends Node3D

#const LOBBY_NAME := "Lobby1"

func _ready() -> void:
	GDSync.connected.connect(_on_GDSync_connected)
	GDSync.connection_failed.connect(_on_GDSync_connection_failed)
	
	GDSync.lobby_created.connect(_on_GDSync_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_GDSync_lobby_creation_failed)
	
	GDSync.lobby_joined.connect(_on_GDSync_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_GDSync_lobby_join_failed)
	
	await get_tree().create_timer(10).timeout
	GDSync.start_multiplayer()

func _physics_process(delta: float) -> void:
	#Walking with RMB
	get_tree().call_group("rmb_walking_c", "update_parent_velocity", delta)
	#Move_and_slide parent. Must be called after all manipulations with Character3d's velocity
	get_tree().call_group("move_and_slide_c", "move_and_slide_parent")

func _on_level_platform_input_event(_camera: Node, event: InputEvent, event_position: Vector3, 
normal: Vector3, _shape_idx: int) -> void:
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	if event.pressed != true: return
	if normal != Vector3(0.0, 1.0, 0.0): return
	for node in get_tree().get_nodes_in_group("rmb_walking_c"):
		if node.is_in_group("having_focus"): 
			node.destination = Vector3(event_position.x, 0, event_position.z)

func _id() -> int: return GDSync.get_client_id()
	
func _on_GDSync_connected() -> void:
	print(_id(), " Connected to GD-Sync")
	GDSync.player_set_username("User%d" % _id())
	print(_id(), " Username ", GDSync.player_get_username(_id()))
	print(_id(), " Player data ", GDSync.player_get_all_data(_id()))
	
	GDSync.lobby_create("Lobby1", "", true, 2)
	
func _on_GDSync_connection_failed(error: int) -> void:
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")      

func _on_GDSync_lobby_created(lobby_name: String) -> void:
	print(_id(), " Lobby was created " + lobby_name)
	GDSync.lobby_join(lobby_name)

func _on_GDSync_lobby_creation_failed(lobby_name: String, error: int) -> void:
	match(error):
		ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
			#push_error(str(_id()) + " Lobby with the name "+lobby_name+" already exists.")
			GDSync.lobby_join(lobby_name)
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_SHORT:
			push_error(lobby_name+" is too short.")
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_LONG:
			push_error(lobby_name+" is too long.")
		ENUMS.LOBBY_CREATION_ERROR.PASSWORD_TOO_LONG:
			push_error("The password for "+lobby_name+" is too long.")
		ENUMS.LOBBY_CREATION_ERROR.TAGS_TOO_LARGE:
			push_error("The tags have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.DATA_TOO_LARGE:
			push_error("The data have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.ON_COOLDOWN:
			push_error("Please wait a few seconds before creating another lobby.")
	  
func _on_GDSync_lobby_joined(lobby_name: String) -> void:
	print(_id(), " Joined lobby ", lobby_name)
	print(_id(), " Host ", GDSync.is_host())
	print("")
	#await get_tree().create_timer(3).timeout
	#GDSync.lobby_leave()
	#GDSync.stop_multiplayer()
	
func _on_GDSync_lobby_join_failed(lobby_name: String, error: int) -> void:
	push_error("Failed to join lobby ", lobby_name, " with error ", str(error))
