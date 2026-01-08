extends CharacterBody3D

# Variables
#region variables

# Nodes
@onready var rig = $"../cam_rig"
@onready var cam = $"../cam_rig/cam"
@onready var ani = $visual/ani
@onready var camlock_ui = $"../ui/camlock"
@onready var visual = $visual

# From Global
var sensitivity = global.sens

# Player Stats
var speed = 20
var jump_power = 60
var grav = 250
const coyotetime = 0.1

# Player state variables
var input_vector: Vector2 = Vector2.ZERO
var airtime = 0
var coyote = 0
var jump_check = false

# Camera variables
var cam_mode = "none"
var zoom = 12.5

# Smooth Rotation
const rotation_speed = 15  # Adjust for faster/slower rotation (5 = medium)
const rotation_threshold = 0.1  # Snap when within 0.1 degrees
var target_angle = 0.0  # Store last target angle
var offset = 0
#endregion

# Setup, callables, and other functions
#region callables

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if cam_mode == "none": return
		rig.rotation_degrees.y -= event.relative.x * sensitivity
		rig.rotation_degrees.x -= event.relative.y * sensitivity
		rig.rotation_degrees.x = clamp(rig.rotation_degrees.x, -90, 90)
	

func get_input_vector():
	input_vector = Input.get_vector("left", "right", "front", "back")
	return input_vector
	
func get_rig_basis():
	var old_rotation_x = rig.rotation_degrees.x
	rig.rotation_degrees.x = 0
	var rig_basis = rig.transform.basis
	rig.rotation_degrees.x = old_rotation_x
	return rig_basis

func vector2_to_deg(value):
	match value:
		Vector2(0, 1): return 180
		Vector2(1, 0): return 270
		Vector2(0, -1): return 0
		Vector2(-1, 0): return 90
		
	if value == Vector2(1, 1).normalized(): return 235
	elif value == Vector2(-1, 1).normalized(): return 135
	elif value == Vector2(-1, -1).normalized(): return 45
	elif value == Vector2(1, -1).normalized(): return 315
		
	return 0

func find_shortest_turn():
	while target_angle > 360: target_angle -= 360
	while target_angle < 0: target_angle += 360
	
	target_angle += 360
	var best_angle = 99999
	for count in range(4):
		if abs(target_angle - rotation_degrees.y) < abs(best_angle - rotation_degrees.y): best_angle = target_angle
		target_angle -= 360
	target_angle = best_angle

#endregion

# Function Groups & Process
#region groups
func _process(delta: float) -> void: # Runs every frame
	
	# Run each part of the script
	get_input_vector()
	camera()
	movement(delta)
	player_rotation(delta)
	animation()
	move_and_slide()
	rig.position = position + Vector3(0, 1.5, 0)
	#debug()
	
	
func vertical_movement(delta: float) -> void:
	gravity(delta)
	jump(delta)
	quick_drop()
	
func movement(delta: float) -> void:
	get_input_vector()
	move() # WASD movement
	vertical_movement(delta)
	

	
#endregion

# Functions
#region functions
func move():
	var normalized_input_vector = input_vector.normalized() # Corrects speed if you go diagonally
	velocity = get_rig_basis() * Vector3(normalized_input_vector.x * speed, velocity.y, normalized_input_vector.y * speed)
	# Set velocity to WASD * speed * transform.basis (angle), and keep the y velocity.
	# Planning to add a sort of deccelleration feature, where if you're faster than your walkspeed (maxspeed),
	# you'll slow down, instead of instantly snapping to low speed

func jump(delta):
	if is_on_floor():
		coyote = 0
		if Input.is_action_pressed("jump"):
			velocity.y = jump_power # Jump is space pressed and on ground.
			ani.play("jump")
			jump_check = true
			coyote = 1
	
	else:
		coyote += delta
		if coyote < coyotetime and Input.is_action_pressed("jump"):
			velocity.y = jump_power
			ani.play("jump")
			jump_check = true
			coyote = 1
	

func gravity(delta):
	if is_on_floor():
		velocity.y = 0 # Remove y velocity when grounded
		airtime = 0
	else:
		velocity.y -= grav * delta # Speed up vertical fall speed when airborne, multiplied by framerate.
		airtime += delta
		
func animation():
	if is_on_floor():
		if not is_equal_approx(abs(input_vector.x) + abs(input_vector.y), 0): ani.play("walk")
		else: ani.play("idle")
	elif jump_check == true:
		ani.play("jump")
		jump_check = false
	elif ani.current_animation != "jump": ani.play("air")
	

	
func quick_drop():
	if Input.is_action_just_pressed("quick_drop") and !is_on_floor(): velocity.y = -grav/2.0

func camera():
	# Handle camlock
	if Input.is_action_just_pressed("camlock"):
		if cam_mode != "camlock":
			cam_mode = "camlock"
			camlock_ui.show()
		else:
			camlock_ui.hide()
			if Input.is_action_pressed("rmb"): cam_mode = "move"
			else: cam_mode = "none"

	if cam_mode != "camlock":
		cam.position.x = 0
		if Input.is_action_pressed("rmb"): cam_mode = "move"
		else: cam_mode = "none"
		camlock_ui.hide()
	else: cam.position.x = 1 if zoom != 0 else 0
	
	if cam_mode == "camlock": rotation.y = rig.rotation.y
	
	# Handle zoom
	
	if Input.is_action_just_pressed("scroll_up"): zoom -= 2.5
	elif Input.is_action_just_pressed("scroll_down"): zoom += 2.5
	
	zoom = clamp(zoom, 0, 50)
	if zoom == 0: visual.hide()
	else: visual.show()
	
	cam.position.z = zoom
func player_rotation(delta):
	if cam_mode == "camlock": return
	offset = vector2_to_deg(input_vector)
	target_angle = rig.rotation_degrees.y + offset
	find_shortest_turn()
	if input_vector != Vector2.ZERO: rotation_degrees.y = lerp(rotation_degrees.y, target_angle, rotation_speed * delta)
	
	
func debug():
	$"../debug/target_angle".rotation_degrees.y = target_angle
	$"../debug/target_angle".position = position + Vector3(0, 1.5, 0)
#endregion
