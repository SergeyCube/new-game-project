extends Node

func _physics_process(delta: float) -> void:
	get_tree().call_group("gravity_c", "update_parent_gravity", delta)
	get_tree().call_group("move_and_slide_c", "move_parent", delta)
