extends Node2D

onready var collision_polygon: = $CollisionBody
onready var spike_active_timer: = $SpikeActiveTimer
onready var spike_inactive_timer: = $SpikeInactiveTimer
onready var animated_sprite: = $AnimatedSprite
onready var hazard_collider: = $HazardHitbox/HazardCollider

export(bool) var is_spike_active = false

func _ready():
	collision_polygon.disabled = true
	hazard_collider.disabled = true
	animated_sprite.animation = "Inactive"		
				

func spike_active():
	collision_polygon.disabled = false
	hazard_collider.disabled = false
	animated_sprite.animation = "Active"
	

func spike_inactive():
	collision_polygon.disabled = true
	hazard_collider.disabled = true
	animated_sprite.animation = "Inactive"


func _on_SpikeActiveTimer_timeout():
	spike_inactive_timer.start()
	spike_active()
	


func _on_SpikeInactiveTimer_timeout():
	spike_active_timer.start()
	spike_inactive()
	
