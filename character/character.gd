extends CharacterBody3D

func _ready() -> void:
	self.add_to_group("having_focus")
	$Camera3D.look_at(self.global_transform.origin)
