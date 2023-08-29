extends RigidBody2D


export var jump_height = 170
export var jump_time_to_peak = 0.5
export var jump_time_to_fall = 0.42

var grounded := false


var move_speed = 360
var direction := Vector2.ZERO
var velocity := Vector2.ZERO

onready var label = get_node("Label")
onready var grapple = get_node("Grapple")

#equations to make jump adjustments easier
onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)) * -1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	
	gravity_scale = get_gravity()/100
	if Input.is_action_just_pressed("jump") and grounded:
		jump()
	
	if Input.is_action_just_pressed("left_click"):
		pass
	
	calc_horz_velocity()


func get_gravity() -> float:
	return jump_gravity if linear_velocity.y < 0.0 else fall_gravity

func jump():
	linear_velocity.y = jump_velocity
	print("jump")
	grounded = false

func calc_horz_velocity():
	label.text = str(linear_velocity.y)
	if velocity.x < move_speed && velocity.x > -1 * move_speed:
		velocity.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * move_speed
	else:
		velocity.x = linear_velocity.x
	linear_velocity.x = velocity.x


func _on_Grounded_body_entered(body):
	grounded = true
