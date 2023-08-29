extends RayCast2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_in_use = false
var anchor_position := Vector2.ZERO
var parent_position := Vector2.ZERO
export var grapple_force = 10000
export var grapple_distance = 600

onready var test_rect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	parent_position = get_parent().position
	
	if Input.is_action_pressed("left_click"):
		if is_colliding():
			is_in_use = true
	else:
		is_in_use = false
	
	if !is_in_use:
		cast_to = (get_global_mouse_position() - parent_position).normalized() * grapple_distance
		force_raycast_update()
		anchor_position = get_collision_point()
		if !is_colliding():
			anchor_position = Vector2(0,0)
	else:
		cast_to = anchor_position - parent_position
		force_raycast_update()
	test_rect.rect_position = get_collision_point() - parent_position

func get_cast_point() -> Vector2:
	return get_collision_point() - parent_position

func get_grapple_force() -> Vector2:
	return get_cast_point().normalized() * grapple_force
