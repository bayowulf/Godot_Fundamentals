extends Area2D
class_name Pickup


func _on_body_entered(body: Node2D) -> void:
	if body is Tank:
		queue_free()
