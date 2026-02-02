extends Node3D

const CHARACTER = preload("uid://ckudr8chj1kgo") # character.tscn

func _ready() -> void:
	GDSync.connected.connect(_on_GDSync_connected)
	GDSync.connection_failed.connect(_on_GDSync_connection_failed)
	
	GDSync.lobby_created.connect(_on_GDSync_lobby_created)
	GDSync.lobby_creation_failed.connect(_on_GDSync_lobby_creation_failed)
	
	GDSync.lobby_joined.connect(_on_GDSync_lobby_joined)
	GDSync.lobby_join_failed.connect(_on_GDSync_lobby_join_failed)
	GDSync.client_id_changed.connect(_on_GDSync_client_id_changed)
	GDSync.host_changed.connect(_on_GDSync_host_changed)
	
	GDSync.client_joined.connect(_on_GDSync_client_joined)
	GDSync.client_left.connect(_on_GDSync_client_left)
	
	await get_tree().create_timer(10).timeout
	GDSync.start_multiplayer()

func _physics_process(delta: float) -> void:
	
	# Walking with RMB. First, bc initiializes parent's x and z velocity
	get_tree().call_group("walking", "update_parent_velocity", delta)
	# Gravity
	get_tree().call_group("gravity", "update_parent_gravity", delta)
	# Move_and_slide parent. Must be called after all manipulations with Character3d's velocity
	get_tree().call_group("move_and_slide", "move_and_slide_parent")	

func _on_level_platform_input_event(_camera: Node, event: InputEvent, event_position: Vector3, 
normal: Vector3, _shape_idx: int) -> void:
	if event is not InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_RIGHT: return
	if event.pressed != true: return
	if normal != Vector3(0.0, 1.0, 0.0): return
	for node in get_tree().get_nodes_in_group("walking"):
		node.destination = Vector3(event_position.x, 0, event_position.z)

#region Multiplayer

func _on_GDSync_connected() -> void:
	print(GDSync.get_client_id(), " Connected to GD-Sync")
	GDSync.player_set_username("Player" + str(GDSync.get_client_id()))
	#print(GDSync.get_client_id(), " Username ", GDSync.player_get_username(GDSync.get_client_id()))
	#print(GDSync.get_client_id(), " Player data ", GDSync.player_get_all_data(GDSync.get_client_id()))
	GDSync.lobby_create("Lobby1", "", true, 2)
func _on_GDSync_connection_failed(error: int) -> void:
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")      

func _on_GDSync_lobby_created(lobby_name: String) -> void:
	print(GDSync.get_client_id(), " Lobby was created " + lobby_name)
	GDSync.lobby_join(lobby_name)
func _on_GDSync_lobby_creation_failed(lobby_name: String, error: int) -> void:
	match(error):
		ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
			#push_error(str(GDSync.get_client_id()) + " Lobby with the name " + lobby_name + " already exists.")
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
	print(GDSync.get_client_id(), " Joined lobby ", lobby_name)
	
	var character: CharacterBody3D = GDSync.multiplayer_instantiate(CHARACTER, self)
	#self.add_child(character)
	character.global_position = Vector3(0.0, 10.8, 0.0)
	character.name = "Character" + str(GDSync.get_client_id())
	GDSync.set_gdsync_owner(character, GDSync.get_client_id())
func _on_GDSync_lobby_join_failed(lobby_name: String, error: int) -> void:
	push_error("Failed to join lobby ", lobby_name, " with error ", str(error))
	#match(error):
		#ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			#GDSync.lobby_create("Lobby1", "", true, 2)
		#ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			#await get_tree().create_timer(1).timeout
			#GDSync.lobby_join(lobby_name)
		#_:
			#push_error("Failed to join lobby ", lobby_name, " with error ", str(error))
	
func _on_GDSync_client_id_changed(own_id: int) -> void:
	GDSync.player_set_data("ID", own_id)
	print(GDSync.get_client_id(), " ClientID was changed ")
	GDSync.player_set_username("User" + str(own_id))
func _on_GDSync_host_changed(is_host: bool, _new_host_id: int) -> void:
	if is_host: print(GDSync.get_client_id(), " Host true")
	else: print(GDSync.get_client_id(), " Host false")

func _on_GDSync_client_joined(client_id: int) -> void:
	if client_id != GDSync.get_client_id():
		var ping: float = await GDSync.get_client_ping(client_id)
		print(GDSync.get_client_id(), " Raw ping to ", client_id, ": ", ping * 60.0)
		var perceived_ping: float = await GDSync.get_client_percieved_ping(client_id)
		print(GDSync.get_client_id(), " Perceived ping to ", client_id, ": ", perceived_ping * 60.0)
		
	#var character: CharacterBody3D = GDSync.multiplayer_instantiate(CHARACTER, self)
	##self.add_child(character)
	#character.global_position = Vector3(0.0, 10.8, 0.0)
	#character.name = "Character" + str(client_id)
	#GDSync.set_gdsync_owner(character, client_id)
func _on_GDSync_client_left(client_id: int) -> void:
	print(client_id, " Left lobby")
	var character: CharacterBody3D = self.get_node_or_null("Character" + str(client_id))
	if character != null: character.queue_free()

#endregion
