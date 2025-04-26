extends CharacterBody2D
class_name Tank
## World(Node2D)/Tank(characterbody2D)

signal collected(collectable)
signal reloaded
signal reload_progress(progress)


const SPEED = 64.0
const TURN_SPEED = 2
const ROTATE_SPEED = 20

@export var weapon : Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body_sprite: Sprite2D = $BodySprite
@onready var collider: CollisionShape2D = $CollisionShape2D

var direction := Vector2.RIGHT

func _ready() -> void:
	# NOTE read about lambda functions
	weapon.reloaded.connect(func (): reloaded.emit())
	weapon.reload_progress.connect(func(progress): reload_progress.emit(progress))
	

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("turn_left","turn_right","move_backward","move_forward")
	if input_direction.x != 0:
		#rotate direction based on our input vector and applyturn speed
		#NOTE 'direction' and 'rotation' are Node2D properties
		direction = direction.rotated(input_direction.x * (PI/2) * TURN_SPEED * delta)
		rotation = direction.angle()
	if input_direction.y != 0:
		# Move in a forward/backward direction and play animation
		animation_player.play("move")
		#NOTE 'velocity' is a Vector2D property
		velocity = lerp(velocity, (direction.normalized() * input_direction.y) * SPEED, SPEED * delta)
	else:
		velocity = Vector2.ZERO
		animation_player.play("idle")
	
	# Apply our movement velocity
	move_and_slide()
	
	# Apply weapon rotation
	var weapon_rotate_direction := Input.get_axis("rotate_weapon_left","rotate_weapon_right")
	weapon.rotation_degrees += (weapon_rotate_direction * ROTATE_SPEED * delta * PI)
	
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_fire"):
		weapon.fire()
		
func collect(collectable):
	collected.emit(collectable)
	
