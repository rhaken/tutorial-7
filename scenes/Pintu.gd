extends Interactable

@export var sceneName := "WinScreen"

func _ready():
	pass

func interact():
	if Global.selected_index != 1:
		print("lewat")
		if Global.items[Global.selected_index].name == "KunciKuning" and self.name == "PintuKuning":
			get_tree().change_scene_to_file("res://scenes/" + sceneName + ".tscn")
	else:
		pass
