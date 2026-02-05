extends CharacterBody3D

#var time := 0.0
#
#func _physics_process(delta: float) -> void:
	#self.time += delta
	#print(self.name,
		#"    ", snapped(self.time, 0.001), 
		#"    ", snapped(self.velocity.y, 0.001), 
		#"    ", snapped(self.global_position.y - 0.5, 0.001))
