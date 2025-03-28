extends CharacterBody3D
@export var speed: float = 10.0
@export var sprint_multiplier: float = 1.5  # How much faster when sprinting
@export var crouch_multiplier: float = 0.5  # How much slower when crouching
@export var crouch_height: float = 0.5      # How much character height reduces when crouching
@export var acceleration: float = 5.0
@export var gravity: float = 9.8
@export var jump_power: float = 5.0
@export var mouse_sensitivity: float = 0.3

@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D  # Reference to the collision shape
@onready var standing_height: float = collision_shape.shape.height  # Original height

var camera_x_rotation: float = 0.0
var is_crouching: bool = false
var is_sprinting: bool = false

func _ready():
	raycast.target_position = Vector3(0, 0, -100)
	raycast.add_exception(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		var x_delta = event.relative.y * mouse_sensitivity
		camera_x_rotation = clamp(camera_x_rotation + x_delta, -90.0, 90.0)
		camera.rotation_degrees.x = -camera_x_rotation
		raycast.global_transform.origin = camera.global_transform.origin
		raycast.target_position = -camera.transform.basis.z * 10
		raycast.force_raycast_update()
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Handle crouch while Ctrl is held down
	if Input.is_action_just_pressed("crouch"):
		enter_crouch()
	if Input.is_action_just_released("crouch"):
		exit_crouch()
	
	# Handle sprint while Shift is held down
	# Only allow sprinting when not crouching
	is_sprinting = Input.is_action_pressed("sprint") and !is_crouching

func enter_crouch():
	if !is_crouching:
		is_crouching = true
		
		# Adjust collision shape height when crouching
		collision_shape.shape.height = standing_height * crouch_height
		# Adjust the shape's position to keep feet at the same level
		collision_shape.position.y = standing_height * (1 - crouch_height) / 2
		# Sprint is disabled while crouching (handled in input function)

func exit_crouch():
	if is_crouching:
		# Check if there's enough space to stand up
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = global_position
		query.to = global_position + Vector3(0, standing_height, 0)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		
		if result.is_empty():  # No obstacles above, safe to stand up
			is_crouching = false
			collision_shape.shape.height = standing_height
			collision_shape.position.y = 0  # Reset position
		# If there's not enough space, stay crouched

func _physics_process(delta):
	var movement_vector = Vector3.ZERO
	
	if Input.is_action_pressed("movement_forward"):
		movement_vector -= head.basis.z
	if Input.is_action_pressed("movement_backward"):
		movement_vector += head.basis.z
	if Input.is_action_pressed("movement_left"):
		movement_vector -= head.basis.x
	if Input.is_action_pressed("movement_right"):
		movement_vector += head.basis.x
	
	movement_vector = movement_vector.normalized()
	
	# Calculate current speed based on sprint and crouch status
	var current_speed = speed
	if is_crouching:
		current_speed *= crouch_multiplier
	elif is_sprinting:
		current_speed *= sprint_multiplier
	
	velocity.x = lerp(velocity.x, movement_vector.x * current_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, movement_vector.z * current_speed, acceleration * delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jumping (only when not crouching)
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_crouching:
		velocity.y = jump_power
	
	move_and_slide()
