extends Node2D

signal gun_fired

var Zombie = preload("res://scenes/Zombie.tscn")
var HumanBeing = preload("res://scenes/HumanBeing.tscn")
var herd  = []


onready var rows = $TileMap.get_used_rect().size.y
onready var cols = $TileMap.get_used_rect().size.x
onready var margin = max($TileMap.cell_size.x, $TileMap.cell_size.y)

export var zombie_count:int = 10

func _ready():
	for i in zombie_count:
		var zombie = Zombie.instance()
		place_on_tile_map(zombie)
		herd.append(zombie)
		add_child(zombie)
		connect("gun_fired", zombie, "on_gun_fired")


func place_on_tile_map(zombie) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cell_is_full = true
	var xpos:int 
	var ypos:int
	while (cell_is_full) :
		xpos = rng.randi_range(margin, int(get_viewport().size.x) - margin)
		ypos = rng.randi_range(margin, int(get_viewport().size.y) - margin)
		cell_is_full = $TileMap.get_cellv($TileMap.world_to_map(Vector2(xpos, ypos))) != $TileMap.INVALID_CELL	
	zombie.position = Vector2(xpos, ypos)
	

func _unhandled_input(event):
	if event is InputEventMouseButton and  event.button_index == BUTTON_LEFT and event.pressed:
#		emit_signal("gun_fired", get_global_mouse_position())
		var human = HumanBeing.instance()
		human.position = get_global_mouse_position()
		add_child(human)

func on_roaring(roarer, prey) -> void :
	for zombie in herd:
		if zombie.position.distance_to(roarer.position) <= roarer.roaring_range:
			zombie.choose_target(prey)
			


