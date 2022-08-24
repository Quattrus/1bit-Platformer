extends Enemy

var enemy_health = health + 1
var can_be_hit = true
var player_bounce = -80

onready var animated_sprite: = $AnimatedSprite
onready var death_timer: = $DeathTimer
onready var enemy_hitbox_collider: = $EnemyHitbox/EnemyHitboxCollision
onready var ledge_check_right: = $LedgeCheckRight
onready var ledge_check_left: = $LedgeCheckLeft
onready var animation_player: = $AnimationPlayer
onready var hit_cooldown: = $HitCooldown

func _physics_process(delta):
	
	if is_dead == true:
		animated_sprite.animation = "Death"
	else:
		enemy_move_with_ledge_and_walls()
	
func enemy_move_with_ledge_and_walls():
	var found_wall = is_on_wall()
	var found_ledge = not ledge_check_right.is_colliding() or not ledge_check_left.is_colliding()

	if found_wall or found_ledge:
		direction *= -1
		direction.x > 0
		
	velocity = direction * 25
	move_and_slide(velocity, Vector2.UP)

func take_damage():
	if can_be_hit == true:
		enemy_health -= 1
		can_be_hit = false
		hit_cooldown.start()
		animation_player.play("Hurt")
	if enemy_health == 0:
		disable_hitbox()
		is_dead = true
		death_timer.start()
		

func _on_EnemyHurtbox_body_entered(body):
	if body is Player:
		take_damage()
		body.velocity.y = player_bounce
		
func disable_hitbox():
	enemy_hitbox_collider.disabled = true

func _on_DeathTimer_timeout():
	queue_free()

func _on_HitCooldown_timeout():
	can_be_hit = true
