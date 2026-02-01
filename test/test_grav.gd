extends Node

@onready var _parent: CharacterBody3D = self.get_parent()
func _ready() -> void:
	self.add_to_group("gravity_c")

func update_parent_gravity(delta: float) -> void:
	self._parent.velocity.y -= 9.8 * delta
