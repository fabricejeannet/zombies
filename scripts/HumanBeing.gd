extends KinematicBody2D



func _on_VitalArea_body_entered(body):
	if body.is_in_group("zombie") :
		get_parent().remove_child(self)

