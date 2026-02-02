class_name MoveAndSlide
extends Node

@onready var _parent: CharacterBody3D = self.get_parent()
func _ready() -> void:
	self.add_to_group("move_and_slide")
	
func move_and_slide_parent() -> void:
	_parent.move_and_slide()
