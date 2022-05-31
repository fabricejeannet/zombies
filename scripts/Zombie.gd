extends KinematicBody2D

signal roaring

var neighbours = []
var avg_speed = 0
var target = null
var roaming:bool = true

var linear_velocity:Vector2
var rng = RandomNumberGenerator.new()
	
export var sound_range = 200.0
export var current_speed = 0
export var max_speed = 50
export var acceleration_factor = 1.2
export var rotation_factor = 0.02
export var centering_factor = 0.5
export var roaring_range = 200.0

onready var target_position:Vector2 = position


func _ready():
	connect("roaring", get_parent(), "on_roaring")
	rng.randomize()
	roam()


func roam() -> void:
#	current_speed = int(max_speed * rng.randf_range(0.0, 0.5))
	current_speed = 25
	target_position  = (Vector2 (rng.randf_range(0.0, get_viewport().size.x), rng.randf_range(0.0, get_viewport().size.y)) - position) * current_speed
	rotate(get_angle_to(target_position))


func _physics_process(delta):
	update()
	move_and_slide(get_linear_velocity(), Vector2(0.0, 0.0), false, 1)
	rotate(get_angle_to(target_position) * rotation_factor) 


func on_gun_fired(shot_position):
	if position.distance_to(shot_position) <= sound_range:
		target_position = shot_position


func _on_Sight_body_entered(body):
	if body != self and body.is_in_group("zombie"):
		neighbours.append(body)
	
	if body.is_in_group("prey"):
		choose_target(body)
		emit_signal("roaring", self, body)



func _on_Sight_body_exited(body):
	var index = neighbours.find(body)
	if index > -1 :
		neighbours.remove(index)
		if body.is_in_group("prey"):
			target = null

	
	

func get_linear_velocity() :
	var xs = 0.0
	var ys = 0.0
	var speeds = 0.0
	var sub_herd_size = float(neighbours.size())
	var center_of_mass:Vector2
	
	if target == null:
		if sub_herd_size > 0 :
			for zombie in neighbours:
				xs += zombie.target_position.x
				ys += zombie.target_position.y
				speeds += zombie.current_speed			
			center_of_mass = Vector2 (xs / sub_herd_size, ys / sub_herd_size)
			target_position = center_of_mass
	else:
		target_position = target.position

	return (target_position - position).normalized() * current_speed


func choose_target(prey) -> void :
	if (target != null and position.distance_to(prey.position) < position.distance_to(target.position)) or target == null:
				target = prey


func _draw() :
	var the_color = Color.red
	if target != null:
		the_color = Color.green
		
	draw_circle(to_local(position + Vector2(25.0, 0.0)), 10, the_color)
	
#	draw_arc(to_local(position), roaring_range, 0.0, 360.0, 10, Color.aqua, 1.0, false)
