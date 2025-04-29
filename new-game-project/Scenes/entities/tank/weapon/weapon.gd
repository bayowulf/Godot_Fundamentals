extends Node2D
class_name Weapon
# by adding class name to a script you improve better integration with godot's engine like autocomplete and better visibility

signal reloaded
signal reload_progress(progress)


enum STATES { READY, FIRING, RELOADING }

@export var BULLET_SCENE: PackedScene
@onready var reload_timer: Timer = $ReloadTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var state: STATES = STATES.READY

func _process(_delta):
	if !reload_timer.is_stopped():
		reload_progress.emit(1 - (reload_timer.time_left / reload_timer.wait_time))
		

func change_state(new_state: STATES):
	state = new_state
	
func fire():
	print("weapon/func fire. FIRST PRINT  STATE = ", state)
	if state == STATES.FIRING || state == STATES.RELOADING:
		return
	change_state(STATES.FIRING)
	print("weapon/func fire. SECOND PRINT  STATE = ", state)
	# Create a bullet at our position and set its direction
	var bullet = BULLET_SCENE.instantiate()
	bullet.direction = Vector2.from_angle(global_rotation)
	bullet.global_position = global_position
	audio_player.play()
	# Add bullet to root scene so that translation is in world space
	get_tree().root.add_child(bullet)
	
	#set our state to reload and start our timer
	change_state(STATES.RELOADING)
	reload_timer.start()
	

func _on_reload_timer_timeout() -> void:
	change_state(STATES.READY)
	reloaded.emit()
