extends CharacterBody2D

# Speed of the player
var speed = 100

# Reference to the player parent nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var shadow_sprite: Sprite2D = $Shadow

func _ready():
	# Initialization (if needed)
	shadow_sprite.scale = Vector2(1,1) # Set initial shadow_sprite scale (normal size when idle)
	shadow_sprite.modulate = Color(1, 1, 1, 0.5)  # RGBA (1, 1, 1, 0.5) for a little transparancy
	

func _process(delta):
	# Reset velocity
	velocity = Vector2()

	# Get input direction and play "Run" animation
	if Input.is_action_pressed("Right"):
		velocity.x += 0.1
		animated_sprite.play("Run")
	if Input.is_action_pressed("Left"):
		velocity.x -= 0.1
		animated_sprite.play("Run")
	if Input.is_action_pressed("Down"):
		velocity.y += 0.1
		animated_sprite.play("Run")
	if Input.is_action_pressed("Up"):
		velocity.y -= 0.1
		animated_sprite.play("Run")
		
	# If not moving play "Idle animation"
	if velocity.y == 0 && velocity.x == 0:
		animated_sprite.play("Idle")

	# Normalize velocity to ensure consistent speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	# Move the player
	move_and_slide()
	
	# Flip player sprite and it's shadow based on direction
	if velocity.x > 0:
		animated_sprite.flip_h = false  # Facing righ
	elif velocity.x < 0:
		animated_sprite.flip_h = true   # Facing left
		
	# Ensure the shadow sprite doesn't flip
	shadow_sprite.flip_h = false
		
	# Adjust shadow_sprite scale and transparancy based on movement
	if velocity.length() > 0:
		# Shrink shadow_sprite when moving (e.g., by reducing the Y scale) and add more transparancy
		shadow_sprite.scale = lerp(shadow_sprite.scale, Vector2(0.55, 0.55), 0.1) # Scale
		shadow_sprite.modulate.a = lerp(shadow_sprite.modulate.a, 0.3, 0.1) # Transparancy
	else:
		# Reset to normal size and transparancy when idle
		shadow_sprite.scale = lerp(shadow_sprite.scale, Vector2(0.7, 0.7), 0.1) # Scale
		shadow_sprite.modulate.a = lerp(shadow_sprite.modulate.a, 0.4, 0.1) # Transparancy
