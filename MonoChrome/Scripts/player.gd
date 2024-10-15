extends CharacterBody3D

# Nodes
@onready var head = $Head
@onready var stand = $Standing_collision
@onready var crouch = $Crouching_collision
@onready var ray_cast_3d = $RayCast3D
@onready var interaction = $Head/Interaction
@onready var hand = $Head/Hand

# States
var walking = false
var crouching = false
var sprinting = false

# Speed
@export var current_speed = 3.0

@export var walking_speed = 3.0
@export var sprinting_speed = 5.0
@export var crouching_speed = 2.0

const jump_velocity = 4.5

# Movement
var lerp_speed = 10.0
var crouching_depth = -1.1

# Input
const mouse_sens = 0.25

var direction = Vector3.ZERO
var is_crouching = false

# Object picking
var picked_obj
var pull_power = 4

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("do_setup")

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jumping
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Sprinting
	if Input.is_action_pressed("Sprint"):
		current_speed = sprinting_speed
		walking = false
		sprinting = true
		
	else:
		current_speed = walking_speed
		walking = true
		sprinting = false
	
	# Crouching
	if Input.is_action_pressed("Crouch"):
		current_speed = crouching_speed
	
		head.position.y  = lerp(head.position.y, 0.7 + crouching_depth, delta * lerp_speed) 
			
		stand.disabled = true
		crouch.disabled = false
		walking = false
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		current_speed = walking_speed
			
		head.position.y = lerp(head.position.y, 0.7, delta * lerp_speed)
			
		stand.disabled = false
		crouch.disabled = true
		walking = true
		crouching = false
	
	if picked_obj != null:
		var a = picked_obj.global_transform.origin
		var b = hand.global_transform.origin
		picked_obj.set_linear_velocity((b-a) * pull_power)
	
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backwards")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()

# Mouse Input
func _input(event):
	# Mouse camera movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
	# Mouse pickup input
	if Input.is_action_just_pressed("PickUp"):
		if picked_obj == null:
			pick_object()
		elif picked_obj != null:
			drop_object()
	
func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_obj = collider

func drop_object():
	if picked_obj != null:
		picked_obj = null

func _process(delta):
	if Input.is_action_just_pressed("Quit (testing)"):
		get_tree().quit()
