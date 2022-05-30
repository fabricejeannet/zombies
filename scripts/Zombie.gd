extends KinematicBody2D


var neighbours = []
var avg_speed = 0

export var sound_range = 200.0
export var current_speed = 0
export var max_speed = 50
export var acceleration_factor = 1.2
export var rotation_factor = 0.02
export var centering_factor = 0.5

onready var target:Vector2 = position

func _physics_process(delta):
	update_speed()
	var motion = (target - position).normalized() * centering_factor * current_speed
	move_and_slide(motion)
	rotate(get_angle_to(target) * rotation_factor)
#	update()
	
func on_gun_fired(shot_position):
	if position.distance_to(shot_position) <= sound_range:
		target = shot_position


func _on_Sight_body_entered(body):
	if body != self and body is KinematicBody2D:
		neighbours.append(body)
		update_motion()


func _on_Sight_body_exited(body):
	var index = neighbours.find(body)
	if index > -1 :
		neighbours.remove(index)


func update_speed() -> void :
	if current_speed < avg_speed and current_speed < max_speed:
		current_speed *= acceleration_factor


func update_motion() :
	var xs = 0.0
	var ys = 0.0
	var speeds = 0.0
	var sub_herd_size = float(neighbours.size())
	
	for zombie in neighbours:
		xs += zombie.position.x
		ys += zombie.position.y
		speeds += zombie.current_speed
		
		
	var center_of_mass= Vector2 (xs / sub_herd_size, ys / sub_herd_size)
	avg_speed = speeds / sub_herd_size
	

	
	$SpeedLabel.text = str(current_speed) + " / " + str(max_speed)

func _draw() :
	draw_line(to_local(position), to_local(target), Color.white)
