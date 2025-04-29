extends CharacterBody2D
class_name Tank
## World(Node2D)/Tank(characterbody2D)
## BodySprite: has 2 frames - set Hframes -> 2

##AnimationPlayer 
signal collected(collectable)
signal reloaded
signal reload_progress(progress)

const SPEED = 64.0
const TURN_SPEED = 2
const ROTATE_SPEED = 20

@export var weapon : Weapon
@export var drive_water_audio: AudioStream
@export var default_drive_audio: AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_sprite: Sprite2D = $BodySprite
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var right_track_particles: GPUParticles2D = $RightTrackParticles
@onready var left_track_particles: GPUParticles2D = $LeftTrackParticles
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var direction := Vector2.RIGHT
#speed_modifier is painted onto the terrain (in tilesets and tilemaps)
var speed_modifier := 1.0
var particle_gradient: GradientTexture1D = null
var in_water:= false:
	set(value):
		if in_water != value:
			# if value = true we are in water
			if value:
				audio_player.stream = drive_water_audio
			else:
				audio_player.stream = default_drive_audio
		in_water = value
var debug_speed = null


func _ready() -> void:
	# NOTE read about lambda functions
	# 'reloaded' signal is connected to the function 'reloaded.emit()'
	weapon.reloaded.connect(func (): reloaded.emit())
	# 'reload_progress' signal is connected to the function 'reload_progress.emit(progress)'
	weapon.reload_progress.connect(func(progress): reload_progress.emit(progress))
	

func _physics_process(delta: float) -> void:
	# HACK Original code changed.  'if' statement added to allow for continuous fire.
	# syntax from Reddit post https://www.reddit.com/r/godot/comments/1bjktw5/continuous_shooting_when_holding_a_key/
	if Input.is_action_pressed("weapon_fire"):
		weapon.fire()
	# Input.get_vector(-x,+x,-y,+y); 
	var input_direction := Input.get_vector("turn_left","turn_right","move_backward","move_forward")
	#if input_direction != Vector2.ZERO:
		#print("input_direction = ", input_direction)
	if input_direction.x != 0:
		#rotate direction based on our input vector and applyturn speed
		#NOTE 'direction' and 'rotation' are Node2D properties
		direction = direction.rotated(input_direction.x * (PI/2) * TURN_SPEED * delta)
		rotation = direction.angle()
	if input_direction.y != 0:
		# Move in a forward/backward direction and play animation
		animation_player.play("move")
		in_water = World.get_custom_data_at(position, "is_water")
		particle_gradient = World.get_gradient_at(position)
		#speed_modifier comes from the custom data in the tilemaplayer
		speed_modifier = World.get_custom_data_at(position, "speed_modifier")
		
		var move_speed = SPEED * speed_modifier
		if debug_speed != move_speed:
			print("move_speed = ", move_speed)
			debug_speed = move_speed
		
		#NOTE 'velocity' is a Vector2D property
		velocity = lerp(velocity, (direction.normalized() * input_direction.y) * move_speed, SPEED * delta)
		if !audio_player.playing:
			audio_player.play()
	else:
		if audio_player.playing:
			audio_player.stop()
		velocity = Vector2.ZERO
		animation_player.play("idle")
		
	# add the ability to modify the gradient (of the right and left track particles)
	# based off what our world states our gradient should be.
	if particle_gradient and velocity:
		# enable the emitters 
		left_track_particles.process_material.color_ramp = particle_gradient
		right_track_particles.process_material.color_ramp = particle_gradient
		left_track_particles.emitting = true
		right_track_particles.emitting = true
	else:
		left_track_particles.emitting = false
		right_track_particles.emitting = false
		
		
	
	# Apply our movement velocity
	move_and_slide()
	
	# Apply weapon rotation
	var weapon_rotate_direction := Input.get_axis("rotate_weapon_left","rotate_weapon_right")
	weapon.rotation_degrees += (weapon_rotate_direction * ROTATE_SPEED * delta * PI)
	
		
# NOTE Original code from tutorial - have to press and release space bar to fire.
# I want to fire continuously while hold  down space bar.  so added code at top
# of tank.gd physics_process to do that.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("weapon_fire"):
		#weapon.fire()
		#
func collect(collectable):
	collected.emit(collectable)
	
