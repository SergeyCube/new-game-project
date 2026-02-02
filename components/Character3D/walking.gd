class_name Walking
extends Node3D

@export var walk_speed := 2.0

@onready var destination := Vector3(self.global_position.x, 0.0, self.global_position.z)
@onready var _parent: CharacterBody3D = self.get_parent()

func _ready() -> void:
	self.add_to_group("walking")

func update_parent_velocity(delta: float) -> void:
	if not _parent.is_on_floor(): return
	self.global_position.y = 0.0
	var direction: Vector3 = self.destination - self.global_position
	var half_step: float = self.walk_speed * delta / 2.0
	if half_step == 0.0: half_step = 0.01
	if direction.length() <= half_step:
		direction = Vector3.ZERO
	direction = direction.normalized()
	self._parent.velocity.x = direction.x * self.walk_speed
	self._parent.velocity.z = direction.z * self.walk_speed
	#print(_parent.velocity)
