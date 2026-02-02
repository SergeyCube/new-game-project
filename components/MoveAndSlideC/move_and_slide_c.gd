class_name MoveAndSlideC
extends Node

#var time := 0.0

@onready var _parent: CharacterBody3D = self.get_parent()
func _ready() -> void:
	self.add_to_group("move_and_slide_c")
	
func move_and_slide_parent(delta: float) -> void:
	#self.time += delta
	_parent.move_and_slide()
	#print(self._parent.name, 
		#snapped(self.time, 0.001), 
		#"    ", snapped(self._parent.velocity.y, 0.001), 
		#"    ", snapped(self._parent.global_position.y - 0.5, 0.001))
