extends Node

var time := 0.0

@onready var _parent: CharacterBody3D = self.get_parent()
func _ready() -> void:
	self.add_to_group("move_and_slide_c")
	
func move_parent(delta: float) -> void:
	self.time += delta
	#self.velocity.y -= 9.8 * delta
	_parent.move_and_slide()
	print(snapped(self.time, 0.001), "    ", snapped(self._parent.velocity.y, 0.001), 
	"    ", snapped(self._parent.global_position.y, 0.001))
