extends KinematicBody2D

class_name Player

enum {MOVE, CLIMB, DEAD, HURT, JUMP, FALL}

export(int) var friction = 75
export(int) var max_speed = 75
export(int) var acceleration = 75
export(int) var gravity_multiplier = 5
export(int) var free_fall_velocity = -35
export(int) var jump_impulse = -160
export(int) var double_jump = 1
export(int) var double_jumps = 1
export(int) var health = 4
export(int) var climb_speed = 15
export(int) var free_fall_multiplier = 2

var is_dead = false
var can_be_hit = true
var velocity = Vector2.ZERO
var is_hurt = false
var state = MOVE
var player_hurt = false

onready var animated_sprite: = $AnimatedSprite
onready var death_timer: = $DeathTimer
onready var hit_cooldown: = $HitCooldown
onready var animation_player: = $AnimationPlayer
onready var remote_transform_2D: = $RemoteTransform2D
onready var ladder_check: = $LadderCheck
onready var collision_shape : = $CollisionShape2D
onready var jump_buffer_timer: = $JumpBufferTimer

func _physics_process(delta):
	var input = Vector2.ZERO	
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("climb_up", "climb_down")

	
	match state:
		MOVE: move_player(input, delta)
		CLIMB: climb_player(input)
		DEAD: player_dead()
		HURT: player_damaged(input, delta)
		JUMP: player_jump(input, delta)
		FALL: player_fall(input, delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	
func horizontal_move_check(input):
	return input.x != 0
	
func move_player(input, delta):
	if is_on_ladder() and Input.is_action_just_pressed("climb_up") or is_on_ladder() and Input.is_action_just_pressed("climb_down"):
		state = CLIMB
	if Input.is_action_just_pressed("Jump"):
		state = JUMP
	if player_hurt == true:
		state = HURT
	if is_dead == true:
		state = DEAD
	if velocity.y > 0:
		state = FALL
	apply_gravity(delta)
	if not horizontal_move_check(input):
		apply_friction(delta)
		animated_sprite.animation = "Idle"
		if velocity.y < 0:
			animated_sprite.animation = "Jump"
	else:
		apply_acceleration(input.x, delta)
		animated_sprite.animation = "Run"
		if velocity.y < 0:
			animated_sprite.animation = "Jump"
		animated_sprite.flip_h = input.x < 0

func climb_player(input):
	if not is_on_ladder():
		state = MOVE
	if is_dead == true:
		state = DEAD
	if input.length()!= 0:
		animated_sprite.animation = "Climb"
	else:
		animated_sprite.animation = "ClimbIdle"
	velocity = input * climb_speed
	
func player_dead():
		animated_sprite.animation = "Death"
		velocity.y = 30
		velocity.x = 0
		
func player_jump(input, delta):
	if velocity.y >= jump_impulse or Input.is_action_just_released("Jump"):
		state = FALL
	if player_hurt == true:
		state = HURT
	velocity.y = jump_impulse
	if velocity.y > 0:
		velocity.y += free_fall_multiplier * delta
	apply_acceleration(input.x, delta)
	velocity.x += input.x * max_speed * delta
	animated_sprite.animation = "Jump"
		
func is_on_ladder():
	if not ladder_check.is_colliding():
		return false
	var ladder_check_collider = ladder_check.get_collider()
	if not ladder_check_collider is Ladder:
		return false
	return true

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, friction * delta)


func apply_acceleration(amount, delta):
	var move_acceleration = max_speed * amount
	velocity.x = move_toward(velocity.x, move_acceleration, acceleration * delta)

func apply_gravity(delta):
	velocity.y += gravity_multiplier * delta
	velocity.y = min(velocity.y, 200)
		

func player_take_damage():
	if health > 0 and can_be_hit == true:
		health -= 1
		player_hurt = true
		hit_cooldown.start()
	if health == 1:
		health -= 1
		death_timer.start()
		is_dead = true

func player_damaged(input, delta):
	if player_hurt == false and is_on_floor():
		state = MOVE
	elif player_hurt == false and !is_on_floor():
		state = FALL
	animated_sprite.animation = "Hurt"
	animation_player.play("Hurt")
	player_hurt = false
	velocity.y = 0
	if input.x > 0:
		velocity.x -= 4 * delta
	if input.x < 0:
		velocity.x += 4 * delta
		
func connect_camera(camera):
	var camera_path = camera.get_path()
	remote_transform_2D.remote_path = camera_path
		

func player_fall(input, delta):
	if is_on_floor():
		state = MOVE
	elif player_hurt == true:
		state = HURT
	elif is_dead == true:
		state = DEAD
	apply_gravity(delta)
	apply_acceleration(input.x, delta)
	if velocity.y > 0:
		velocity.y += free_fall_multiplier * delta
	velocity.x += input.x * max_speed * delta
	
	if velocity.y >= 0:
		animated_sprite.animation = "Fall"
	

func free_fall():
	if Input.is_action_just_released("Jump") and velocity.y < free_fall_velocity:
		velocity.y = free_fall_velocity 
	


func _on_DeathTimer_timeout():
	Events.emit_signal("player_died")
	queue_free()

func insta_death():
	is_dead = true
	animation_player.play("Hurt")
	death_timer.start()

func _on_HitCooldown_timeout():
	can_be_hit = true
