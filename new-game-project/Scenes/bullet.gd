extends Area2D
class_name Bullet

const SPEED = 500

var direction: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * SPEED * delta


func _on_area_entered(area: Area2D) -> void:
	queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body is Crate:
		body.destroy()
	queue_free() 
		
	
