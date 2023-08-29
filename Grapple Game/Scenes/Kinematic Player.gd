extends KinematicBody2D


export var jump_height = 150
export var jump_time_to_peak = 0.45
export var jump_time_to_fall = 0.38
export var terminal_velocity = 1700

var can_jump := false


var move_speed = 360
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

onready var label = get_node("Label")
onready var grapple = get_node("Grapple")
onready var camera = get_node("Camera2D")

#timers
onready var jump_buffer = get_node("Jump_buffer")
onready var coyote_time = get_node("Coyote_time")

#equations to make jump adjustments easier
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)) * -1.0


func _ready():
	pass

func _physics_process(delta):
	
	velocity.y += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start()
	
	if is_on_floor():
		can_jump = true
		coyote_time.start()
	
	if jump_buffer.time_left > 0 && can_jump:
		jump()
		coyote_time.stop()
		jump_buffer.stop()
		can_jump = false
	
	
	#for a gradual slowdown/friction
	if !(Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left") || !is_on_floor()):
		velocity.x = velocity.x/1.25
	elif is_on_floor():
		velocity.x = velocity.x/1.1
	
	#base movement
	if Input.is_action_pressed("move_left"):
		if velocity.x > move_speed * -1:
			velocity.x += move_speed/6 * -1
	if Input.is_action_pressed("move_right"):
		if velocity.x < move_speed:
			velocity.x += move_speed/6
	
	#grapple movements
	if Input.is_action_pressed("left_click") && grapple.is_in_use:
		var previous_magnitude = velocity.length()
		var slide_arch = grapple.get_grapple_force()
		#first bit ensures mantained momentum
		if Input.is_action_just_pressed("left_click"):
			velocity = (velocity).slide(slide_arch.normalized()).normalized() * previous_magnitude
			print(slide_arch.normalized())
		else:
			#this is similar to the last few lines but is focused on mantaining momentum
			velocity = (velocity).slide(slide_arch.normalized())
			velocity += grapple.get_grapple_force() * delta
	
	if velocity.length() > terminal_velocity:
		velocity = velocity.normalized() * terminal_velocity
	
	#velocity.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * move_speed
	position_camera()
	velocity = move_and_slide(velocity, Vector2.UP)

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump():
	velocity.y = jump_velocity

func _on_Coyote_time_timeout():
	can_jump = false

func position_camera():
	var offset = get_viewport().get_mouse_position() - get_viewport().size / 2
	var dampen = 2.75
	camera.position = offset/dampen
