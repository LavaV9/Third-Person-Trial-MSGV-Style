extends CharacterBody3D

@onready var cam_piv = $CamPiv
@onready var spring_arm = $CamPiv/SpringArm3D
@export var movement_states : Dictionary
var SPEED = 2.8
var walking_speed = 3
var JUMP_VELOCITY = 5
@export var sensy = 0.5
@export var sensx = 0.5
@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature
@export var running_speed = 28.0
var running =false
var walking = false
var idle = false
var is_attacking = false
var default_fov = 120.0
var sprinting_fov= 80.0
@onready var camera_3d = $CamPiv/SpringArm3D/Camera3D
@onready var shake = $shake
var inital_rotation: Vector3
var in_air = false
@onready var attack_timer = $attack_timer




var acceleration = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_3d.set_fov(80)
	inital_rotation = camera_3d.rotation_degrees
	
	

func _process(delta):
	if not attack_timer.is_stopped():
		animation_player.play("punch left2")
	else:
		animation_player.play("idle")
		
	
func camera_shake():
	var x =randf_range(1,1.3)
	var y =randf_range(1,1.3)
	var z =randf_range(1,1.3)
	camera_3d.rotation_degrees = Vector3(x,y,z)
func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x))
		
		cam_piv.rotate_y(deg_to_rad(-event.relative.x*sensy))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y*sensx))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x,-PI/4,PI/4)
		armature.rotate_y(deg_to_rad(event.relative.x*sensy))
	
			


	
			
func _physics_process(delta):
	
	
	if  Input.is_action_pressed("run") and (Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		SPEED = running_speed
		$AnimationTree.set("parameters/lwr_blend/blend_amount", lerp($AnimationTree.get("parameters/lwr_blend/blend_amount"),1.0,delta*acceleration))
		$AnimationTree.set("parameters/in air/transition_request","false")
		$AnimationTree.set("parameters/attacking/transition_request","not_attacking")
		is_attacking = false
		
		
		running = true
		camera_3d.set_fov(60)
		camera_shake()
		spring_arm.position = Vector3(1,2.097,.398)
		
	elif Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		SPEED = walking_speed
		$AnimationTree.set("parameters/lwr_blend/blend_amount", lerp($AnimationTree.get("parameters/lwr_blend/blend_amount"),0.0,delta*acceleration))
		is_attacking = false
		running = false
		walking = true
		camera_3d.set_fov(80)
		$AnimationTree.set("parameters/in air/transition_request","false")
		$AnimationTree.set("parameters/attacking/transition_request","not_attacking")
		spring_arm.position = Vector3(0,2.097,.398)
	elif Input.is_action_just_pressed("attack") and is_on_floor():
		if animation_player.current_animation != "punch left":
			is_attacking = true
			animation_player.play("punch left")
			idle = false
			print("poop")
			$AnimationTree.set("parameters/attacking/transition_request","attacking")
	elif is_attacking and animation_player.current_animation == "punch left" and animation_player.current_animation_position >= animation_player.current_animation_length:
		is_attacking = true
		idle = true
		$AnimationTree.set("parameters/attacking/transition_request","attacking")
	
	else:
		SPEED = 0
		$AnimationTree.set("parameters/lwr_blend/blend_amount", lerp($AnimationTree.get("parameters/lwr_blend/blend_amount"),-1.0,delta*acceleration))
		is_attacking = false
		running = false
		idle = true
		camera_3d.set_fov(80)
		$AnimationTree.set("parameters/in air/transition_request","false")
		$AnimationTree.set("parameters/attacking/transition_request","not_attacking")
		spring_arm.position = Vector3(0,2.097,.398)
		
		
	if Input.is_action_pressed("run"):
		
		SPEED = running_speed
		running = true
		
	else:
		SPEED = walking_speed
		running = false
	
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimationTree.set("parameters/in air/transition_request","true")
		animation_player.play("jump")
		
	
		running = false
		idle = false
		walking = false
		camera_3d.set_fov(80)
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_piv.rotation.y)
	if direction:
		armature.look_at(global_position + direction)
		
		if running and Input.is_action_pressed("run"):
			if animation_player.current_animation != "run":
				animation_player.play("run")
		else:
			if animation_player.current_animation != "walk":
				animation_player.play("walk")
			

			
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
		
		


	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "punch_left":
		attack_timer.start(5.0)
		
		
	
	# Replace with function body.

