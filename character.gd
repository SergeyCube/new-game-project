class_name Character
extends CharacterBody3D

func _enter_tree() -> void:
	self.set_multiplayer_authority(self.name.to_int())
	if is_multiplayer_authority():
		self.get_node("Camera3D").current = true
	else:
		self.get_node("Walking").remove_from_group("walking")
		self.get_node("Gravity").remove_from_group("gravity")
		self.get_node("MoveAndSlide").remove_from_group("move_and_slide")
		self.get_node("Camera3D").current = false

func _ready() -> void:
	$Camera3D.look_at(self.global_transform.origin)
	self.global_position = Vector3(0.0, 10.8, 0.0)
	self.velocity = Vector3(0.0, 0.0, 0.0)
	
