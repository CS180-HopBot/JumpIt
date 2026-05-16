extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_big_jump_sprite_2d: AnimatedSprite2D = $AnimatedBigJumpSprite2D
@onready var animated_small_jump_sprite_2d: AnimatedSprite2D = $AnimatedSmallJumpSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var stomp_hitbox: Area2D = $StompHitbox

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const BEAT_TOLERANCE_SEC := 0.2
const STOMP_ACTIVE_SEC := 0.12
var alive := true
var _can_air_jump := true


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

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
		elif _can_air_jump:
			_try_rhythm_stomp()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if stomp_hitbox.monitoring:
		for a in stomp_hitbox.get_overlapping_areas():
			if a.is_in_group("snail") and a.has_method("kill"):
				a.kill()
	
	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true


func _try_rhythm_stomp() -> void:
	var scene := get_tree().current_scene
	if scene == null or not scene.has_method("is_within_beat_window"):
		return
	if scene.is_within_beat_window(BEAT_TOLERANCE_SEC):
		_show_big_jump()
		_activate_stomp_hitbox()
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		jump_sound.play()
		_can_air_jump = false
	else:
		_show_small_jump()


func _activate_stomp_hitbox() -> void:
	stomp_hitbox.monitoring = true
	get_tree().create_timer(STOMP_ACTIVE_SEC).timeout.connect(_deactivate_stomp_hitbox)


func _deactivate_stomp_hitbox() -> void:
	if is_instance_valid(stomp_hitbox):
		stomp_hitbox.monitoring = false

func _show_big_jump() -> void:
	animated_big_jump_sprite_2d.show()
	get_tree().create_timer(0.24).timeout.connect(animated_big_jump_sprite_2d.hide)

func _show_small_jump() -> void:
	animated_small_jump_sprite_2d.show()
	get_tree().create_timer(0.2).timeout.connect(animated_small_jump_sprite_2d.hide)

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
