extends Area3D

@export var sceneName := "Level 1"

func _on_body_entered(body: Node3D) -> void:
	if body.get_name() == "Player":
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file("res://scenes/" + sceneName + ".tscn")
