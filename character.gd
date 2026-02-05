class_name Character
extends CharacterBody3D

#@onready var gdsync_global_basis := self.global_basis

func _ready() -> void:
	$Camera3D.look_at(self.global_transform.origin)
	#print("global basis ", self.global_basis)

#func _physics_process(_delta: float) -> void:
	#self.gdsync_global_basis = self.global_basis
