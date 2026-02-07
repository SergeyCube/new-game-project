extends Node3D

const CHARACTER = preload("uid://ckudr8chj1kgo") # character scene
const PORT: int = 5000

func _ready() -> void:
	pass

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
		if node.is_multiplayer_authority() == true:
			node.destination = Vector3(event_position.x, 0, event_position.z)

#region ENet_multiplayer

func _on_host_button_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 2)
	self.multiplayer.multiplayer_peer = peer
	if error == OK: print(self.multiplayer.get_unique_id(), " Server was created")
	else: print(error)
	self.multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	_on_multiplayer_peer_connected(1) # for host itself
	
func _on_join_button_pressed() -> void:
	var peer := ENetMultiplayerPeer.new()
	var error = peer.create_client("127.0.0.1", PORT)
	self.multiplayer.multiplayer_peer = peer
	if error == OK: print(self.multiplayer.get_unique_id(), " Client was created")
	else: print(error)
	
func _on_multiplayer_peer_connected(id: int) -> void:
	print(id, " connected")
	var character = CHARACTER.instantiate()
	character.name = str(id)
	call_deferred("add_child", character)


#endregion

#region GDSync_multiplayer

#func _on_GDSync_connected() -> void:
	#print(GDSync.get_client_id(), " Connected to GD-Sync")
	#GDSync.player_set_username("Player" + str(GDSync.get_client_id()))
	##print(GDSync.get_client_id(), " Username ", GDSync.player_get_username(GDSync.get_client_id()))
	##print(GDSync.get_client_id(), " Player data ", GDSync.player_get_all_data(GDSync.get_client_id()))
	#$ClientIDLabel.text = "ClientID " + str(GDSync.get_client_id())
	#GDSync.lobby_create("Lobby" + str(self.lobby_number), "", true, 2)
#
#func _on_GDSync_connection_failed(error: int) -> void:
	#match(error):
		#ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			#push_error("The public or private key you entered were invalid.")
		#ENUMS.CONNECTION_FAILED.TIMEOUT:
			#push_error("Unable to connect, please check your internet connection.")      
#
#func _on_GDSync_lobby_created(lobby_name: String) -> void:
	#print(GDSync.get_client_id(), " Lobby was created " + lobby_name)
	#GDSync.lobby_join(lobby_name)
#
#func _on_GDSync_lobby_creation_failed(lobby_name: String, error: int) -> void:
	#match(error):
		#ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
			##push_error(str(GDSync.get_client_id()) + " Lobby with the name " + lobby_name + " already exists.")
			#GDSync.lobby_join(lobby_name)
		#ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_SHORT:
			#push_error(lobby_name+" is too short.")
		#ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_LONG:
			#push_error(lobby_name+" is too long.")
		#ENUMS.LOBBY_CREATION_ERROR.PASSWORD_TOO_LONG:
			#push_error("The password for "+lobby_name+" is too long.")
		#ENUMS.LOBBY_CREATION_ERROR.TAGS_TOO_LARGE:
			#push_error("The tags have exceeded the 2048 byte limit.")
		#ENUMS.LOBBY_CREATION_ERROR.DATA_TOO_LARGE:
			#push_error("The data have exceeded the 2048 byte limit.")
		#ENUMS.LOBBY_CREATION_ERROR.ON_COOLDOWN:
			#push_error("Please wait a few seconds before creating another lobby.")
#
#func _on_GDSync_lobby_joined(lobby_name: String) -> void:
	#print(GDSync.get_client_id(), " Joined lobby ", lobby_name)
	#
	#var character: CharacterBody3D = $CharacterInstantiator.instantiate_node()
	#character.global_position = Vector3(0.0, 10.8, 0.0)
	#character.velocity = Vector3(0.0, 0.0, 0.0)
	#character.name = "Character" + str(GDSync.get_client_id())
	#character.get_node("Label3D").text = str(GDSync.get_client_id())
	#GDSync.set_gdsync_owner(character, GDSync.get_client_id())
	#character.get_node("Camera3D").current = true
#
#func _on_GDSync_lobby_join_failed(lobby_name: String, error: int) -> void:
	#push_error("Failed to join lobby ", lobby_name, " with error ", str(error))
	#
#func _on_GDSync_client_id_changed(own_id: int) -> void:
	#GDSync.player_set_data("ID", own_id)
	#print(GDSync.get_client_id(), " ClientID was changed ")
	#GDSync.player_set_username("Player" + str(own_id))
#
#func _on_GDSync_host_changed(is_host: bool, _new_host_id: int) -> void:
	#if is_host: print(GDSync.get_client_id(), " Host true")
	#else: print(GDSync.get_client_id(), " Host false")
#
#func _on_GDSync_client_joined(client_id: int) -> void:
	#if client_id != GDSync.get_client_id():
		#var ping: float = await GDSync.get_client_ping(client_id)
		#print(GDSync.get_client_id(), " Raw ping to ", client_id, ": ",  snapped(ping*1000, 1))
		#var perceived_ping: float = await GDSync.get_client_percieved_ping(client_id)
		#print(GDSync.get_client_id(), " Perceived ping to ", client_id, ": ",  snapped(perceived_ping*1000, 1))
		#self.enemy_client_id = client_id
#
#func _on_GDSync_client_left(client_id: int) -> void:
	#print(client_id, " Left lobby")
	#var character: CharacterBody3D = self.get_node_or_null("Character" + str(client_id))
	#if character != null: character.queue_free()
#
#func _on_character_instantiator_node_instantiated(node: Node) -> void:
	##print(GDSync.get_client_id(), "    ", self.get_children())
	#if GDSync.is_gdsync_owner(node): return
	#if not node.name.begins_with("Character"): return
	##if !(node is Character): return
	##print(GDSync.get_client_id(), "    ", node.name)
	#node.get_node("Walking").remove_from_group("walking")
	#node.get_node("Gravity").remove_from_group("gravity")
	#node.get_node("MoveAndSlide").remove_from_group("move_and_slide")
	#node.get_node("Camera3D").current = false
	##print(GDSync.get_gdsync_owner(node), " is owner of ", node)
	##GDSync.sync_var(node.get_node("Label3D"), "text")

#endregion
