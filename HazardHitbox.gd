extends Area2D

func _on_HazardHitbox_body_entered(body):
	if body is Player:
		body.player_take_damage()
