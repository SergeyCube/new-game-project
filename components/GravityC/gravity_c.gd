class_name GravityC
extends Node

@onready var _parent: CharacterBody3D = self.get_parent()
@onready var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready() -> void:
	self.add_to_group("gravity_c")
	print("Gravity ", self._gravity)
	
func update_parent_gravity() -> void: #without delta, bc of move_and_slide component after that
	self._parent.velocity.y -= self._gravity
