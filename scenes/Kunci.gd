extends Item


var door_id: String

@export var mesh: MeshInstance3D

func _ready() -> void:
	print("ready")

func _init(item_name: String = "KunciKuning"):
	super._init(item_name)
	if item_name == "KunciKuning":
		door_id = "PintuKuning"
	elif item_name == "KunciMerah":
		door_id = "KunciMerah"
	else:
		door_id = "KunciGadungan"

func use():
	print("Using key: " + name + " for door: " + door_id)
	
func hilang():
	mesh.visible = false
