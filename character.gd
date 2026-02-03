#class_name Character
extends CharacterBody3D

func _ready() -> void:
	$Camera3D.look_at(self.global_transform.origin)
