extends RayCast3D

var current_collider
@export var inventory: Inventory
@export var label: RichTextLabel

func _ready():
	exclude_parent = true
	if label:
		label.visible = false

func _process(delta):
	var collider = get_collider()
	
	if label:
		label.visible = false
	if is_colliding() and collider is Interactable:
		if label:
			label.text = "Press E to interact"
			label.visible = true
		if Input.is_action_just_pressed("interact"):
			collider.interact()
	elif is_colliding() and collider is Item:
		if label:
			label.text = "Press E to pick up " + collider.name
			label.visible = true

		if Input.is_action_just_pressed("interact"):
			inventory.pickup(collider)
			collider.queue_free()
			
