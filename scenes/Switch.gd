extends Interactable

@export var light : NodePath
@export var mesh : NodePath
@export var collision : NodePath
@export var on_by_default = true
@export var energy_when_on = 10
@export var energy_when_off = 3
@export var extended_size = 1.5
@export var default_size = 1.0

@onready var light_node : Light3D = get_node(light)

var on = on_by_default

func _ready():
	light_node.light_energy = energy_when_on if on else energy_when_off

func interact():
	var new_size = extended_size if on else default_size
	var mesh_node = get_node(mesh) as MeshInstance3D
	var collision_node = get_node(collision) as CollisionShape3D
	mesh_node.scale.z = new_size
	var shape: BoxShape3D = collision_node.shape
	shape.size.z = new_size
	on = !on
	light_node.light_energy = energy_when_on if on else energy_when_off
