extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_big_jump_sprite_2d: AnimatedSprite2D = $AnimatedBigJumpSprite2D
@onready var animated_small_jump_sprite_2d: AnimatedSprite2D = $AnimatedSmallJumpSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var stomp_hitbox: Area2D = $StompHitbox

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
var alive = true
var can_move = true

func _ready() -> void:
	stomp_hitbox.monitoring = false
	animated_big_jump_sprite_2d.animation = "collected"
	animated_small_jump_sprite_2d.animation = "collected"
	animated_big_jump_sprite_2d.hide()
	animated_small_jump_sprite_2d.hide()

func _physics_process(delta: float) -> void:
	
	if !alive:
		return

	if is_on_floor():
		_can_air_jump = true
		
	#Add animation 
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
			animated_sprite_2d.animation = "idel"
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping"
		
	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_sound.play()

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true
		
func die() -> void:
	if not alive:
		return
	stomp_hitbox.monitoring = false
	death_sound.play()
	animated_sprite_2d.animation = "dying"
	alive = false
	get_tree().create_timer(3.0).timeout.connect(_restart_level)


func _restart_level() -> void:
	get_tree().reload_current_scene()
