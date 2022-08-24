extends Node2D

class_name Level

const PlayerScene = preload ("res://actors/player/Player.tscn")
var player_spawn_location = Vector2.ZERO


onready var player: = $Player
onready var camera: = $Camera2D

func _ready():
	VisualServer.set_default_clear_color(Color.black)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "on_player_died")
	player.connect_camera(camera)
	
func on_player_died():
	var player = PlayerScene.instance()
	add_child(player)
	player.position = player_spawn_location
	player.connect_camera(camera)
	get_tree().reload_current_scene()


func _on_BottomBounds_body_entered(body):
	if body is Player:
		body.insta_death()
