class_name GravityC
extends Node

@onready var _parent: CharacterBody3D = self.get_parent()
@onready var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready() -> void:
	self.add_to_group("gravity_c")
	#print(self._parent.name)
	#print("Gravity ", self._gravity)
	
func _physics_process(delta: float) -> void:
	self._parent.velocity.y -= self._gravity * delta
