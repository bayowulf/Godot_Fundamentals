extends Area2D
class_name Pickup
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _on_body_entered(body: Node2D) -> void:
	if body is Tank:
		body.collect(self)
		audio_player.play()
		await audio_player.finished
		queue_free()
