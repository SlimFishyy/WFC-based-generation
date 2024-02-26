@tool
extends GridMap


@export var start : bool = false : set = start_generator
@export var h_size = 50
@export var w_size = 50
@export var wait_time : int = 10
enum {FLOOR, WALL, TABLE, CRATE, SHELF, DOOR, EMPTY}

const DUNGEON_TILES = preload("res://dungeon_tiles.tscn")
const CHEST_MODEL = preload("res://chest.tscn")
const CRATE_MODEL = preload("res://crate.tscn")
const FLOOR_MODEL = preload("res://floor.tscn")

var all_cells = []
@onready var map = $".."

var possible_tiles = {FLOOR : 1, WALL : 0, TABLE : 1, CRATE : 1, SHELF :1, DOOR : 0, EMPTY : 1}

func start_generator(value):
	all_cells.clear()
	for child in map.get_children():
		if not child is GridMap:
			child.queue_free()
	#generate_base()
	generate_room_contents()
	start = false
	#clear()
	
# Called when the node enters the scene tree for the first time.
#func _ready():
	#all_cells.clear()
	#for child in get_children():
		#child.queue_free()
	##generate_base()
	#generate_room_contents()
	#clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_base():
	clear()
	all_cells.clear()
	var t : int = 0
	#Create floor
	for h in range(1, h_size):
		for w in range(1, w_size):
			set_cell_item(Vector3(h,0,w), FLOOR)
			#t += 1
			#if t%wait_time == wait_time - 1 : await get_tree().create_timer(0).timeout
	#Create border
	for h in h_size+1:
		set_cell_item(Vector3(h,0,0), WALL)
		set_cell_item(Vector3(h,0,w_size), WALL)
		#t += 1
		#if t%wait_time == wait_time - 1 : await get_tree().create_timer(0).timeout
	for w in w_size+1:
		set_cell_item(Vector3(0,0,w), WALL)
		set_cell_item(Vector3(h_size,0,w), WALL)
		#t += 1
		#if t%wait_time == wait_time - 1 : await get_tree().create_timer(0).timeout

func generate_room_contents():
	clear()
	var t : int = 0
	#Assign tile weights to each cell
	for h in range(1, h_size+2):
		all_cells.append([])
		for w in range(1, w_size+2):
			all_cells[all_cells.size() -1].append(possible_tiles.duplicate())
			
	#Generates upper layer
	var chosen_tile
	var h = randi_range(1,h_size)
	var w = randi_range(1,w_size)
	var i = 0
	while i < 3000:
		chosen_tile = choose_tile(h,w)

		set_cell_item(Vector3(h,1,w), chosen_tile)
		var points = change_weight(h,w, chosen_tile)
		h = points[0]
		w = points[1]
		print(h, " ", w)
		i += 1

	#Create tiles in specific places based on tiles positions on the grid
	for cell in get_used_cells():
		t += 1
		if t%wait_time == wait_time - 1 : await get_tree().create_timer(0).timeout
		if cell.y == 1:
			var new_object : Object
			if get_cell_item(cell) == TABLE:
				new_object = CHEST_MODEL.instantiate()
				map.add_child(new_object)
				new_object.global_position = Vector3(cell) + Vector3(0.5, 0.3,0.5)
				new_object.rotate(Vector3.UP, randf_range(-PI,PI))
			if get_cell_item(cell) == CRATE or get_cell_item(cell) == SHELF:
				new_object = CRATE_MODEL.instantiate()
				map.add_child(new_object)
				new_object.global_position = Vector3(cell) + Vector3(0.5, 0.3,0.5)
				new_object.rotate(Vector3.UP, randf_range(-PI,PI))
		var floor = FLOOR_MODEL.instantiate()
		map.add_child(floor)
		floor.global_position = cell


func change_weight(height,width, tile):
	var weight_change = {}
	var new_points : Array
	#weight_change = {FLOOR : 10, WALL : 0, TABLE : -1, CRATE : -1, SHELF :-1, DOOR : 0, EMPTY : 0}
	match tile:
		CRATE:
			weight_change =  {FLOOR : 6, WALL : 0, TABLE : 1, CRATE : 1, SHELF :1, DOOR : 0, EMPTY : 1}
		SHELF:
			weight_change =  {FLOOR : 11, WALL : 0, TABLE : 1, CRATE : 1, SHELF :1, DOOR : 0, EMPTY : 1}
		TABLE:
			weight_change =  {FLOOR : 11, WALL : 0, TABLE : 1, CRATE : 1, SHELF :1, DOOR : 0, EMPTY : 1}
		EMPTY:
			weight_change =  {FLOOR : 11, WALL : 0, TABLE : 1, CRATE : 1, SHELF :1, DOOR : 0, EMPTY : 1}

	for x in 3:
		for y in 3:
			if h_size > height-1+x and height-1+x > 1 and w_size> width - 1 + y  and width - 1 + y> 1:
				new_points.append([height-1+x,width - 1 + y])
				for key in weight_change:
					all_cells[height-1+x][width - 1 + y][key] = weight_change[key]
	#print(new_points.size())
	var points
	randomize()
	new_points.shuffle()
	for i in new_points.size():
		if get_cell_item(Vector3(new_points[i][0],1,new_points[i][1])) == -1:
			points = new_points[i]
	if points == null:
		points = new_points[0]
	return points
	
func choose_tile(h,w):
	var weight_array = []
	for key in all_cells[h][w]:
		if all_cells[h][w][key] > 0:
			for number in all_cells[h][w][key]:
				weight_array.append(key)
	return weight_array.pick_random()
