@tool
extends GridMap


@export var start : bool = false : set = start_generator
@export var clean : bool = false : set = clean_generator
@export var h_size = 4
@export var w_size = 4
@export var wait_time : int = 10
enum {BLANK, NORTH, EAST, SOUTH, WEST}

const NORTH_TILE = preload("res://NORTH.png")
const BLANK_TILE = preload("res://BLANK.png")
const LINE = preload("res://LINE.png")

var tiles = []

var all_cells = []
var all_cells_copy = []
var tiles_to_rotate = []
var rules = []
var rules_dictionary = {}
var test = []
var nextTile

@onready var map = $".."

func clean_generator(value):
	clear()
	for i in map.get_children():
		if not i is GridMap:
			i.queue_free()
	clean = false
	
func start_generator(value):
	tiles.clear()
	var new_tile = Sprite3D.new()
	new_tile.texture = BLANK_TILE
	new_tile.rotate_x(-PI/2)
	tiles.append(new_tile)
	rules = [
	[[0,0,0],[0,0,0],[0,0,0],[0,0,0]],
	]
	
	rules_dictionary.clear()
	
	tiles_to_rotate = [{"tile" : NORTH_TILE, "walls" : [[0,1,0],[0,1,0],[0,0,0],[0,1,0]]},{"tile" : LINE, "walls" : [[0,0,0],[0,1,0],[0,0,0],[0,1,0]]}]
	
	all_cells_copy = []
	test = [[1,2],[1,2,3],[1]]
	all_cells = []
	for i in map.get_children():
		if not i is GridMap:
			i.queue_free()
	create_tileset()
	clear()
	for i in h_size * w_size:
		all_cells.append({
			"xy" : i,
			"collapsed" : false,
			"domain" : rules_dictionary.duplicate(),
			"picked" : null})
			
	nextTile = all_cells.pick_random()
	generate()
	start = false

func create_tileset():
	var rotated_tiles = []
	var rotated_walls = []
	var new_tile
	for tile in tiles_to_rotate.size():
		for key in tiles_to_rotate[tile]:
			for i in 4:
				if key == "tile":
					new_tile = Sprite3D.new()
					new_tile.texture = tiles_to_rotate[tile][key]
					new_tile.rotate_x(-PI/2)
					new_tile.rotate_y((-PI/2)*i)
					rotated_tiles.append(new_tile)
				if key == "walls":
					var new_walls = tiles_to_rotate[tile][key].duplicate()
					for value in i:
						new_walls.push_front(new_walls.pop_back())
					rotated_walls.append(new_walls)
	for tile in rotated_tiles:
		tiles.append(tile)
	for new_wall in rotated_walls:
		rules.append(new_wall)
	for number in rules.size():
		rules_dictionary[number] = rules[number]
	
#func _ready():
	#all_cells_copy = []
	#test = [[1,2],[1,2,3],[1]]
	#all_cells = []
	#for i in map.get_children():
		#if not i is GridMap:
			#i.queue_free()
	#clear()
	#for i in h_size * w_size:
		#all_cells.append({
			#"xy" : i,
			#"collapsed" : false,
			#"domain" : {BLANK : [0,0,0,0], NORTH : [1,1,0,1], EAST : [1,1,1,0], SOUTH : [0,1,1,1], WEST : [1,0,1,1]},
			#"picked" : null})
			#
	#nextTile = all_cells.pick_random()
	#generate()
	#start = false
	
func generate():
	var running = true
	var iterations = 0
	while running and iterations < 1000:
		var t : int = 0
		t += 1
		var id = nextTile["xy"]
		all_cells[id]["collapsed"] = true
		all_cells[id]["picked"] = all_cells[id]["domain"].keys().pick_random()
		var picked_tile = all_cells[id]["picked"]
		if t%wait_time == wait_time - 1 : await get_tree().create_timer(0.2).timeout
		draw()
		#WEST
		if id-1 >= 0 and id % w_size != 0:
			var sides_to_remove = []
			if all_cells[id-1]["collapsed"] == false:
				for i in all_cells[id-1]["domain"]:
					if all_cells[id-1]["domain"][i][1] != all_cells[id]["domain"][picked_tile][3]:
						sides_to_remove.append(i)
			for i in sides_to_remove:
				all_cells[id-1]["domain"].erase(i)
		#NORTH
		if id-w_size >= 0:
			var sides_to_remove = []
			if all_cells[id-w_size]["collapsed"] == false:
				for i in all_cells[id-w_size]["domain"]:
					if all_cells[id-w_size]["domain"][i][2] != all_cells[id]["domain"][picked_tile][0]:
						sides_to_remove.append(i)
				for i in sides_to_remove:
					all_cells[id-w_size]["domain"].erase(i)
		#EAST
		if id+1 < w_size*h_size and id % w_size != w_size-1:
			var sides_to_remove = []
			if all_cells[id+1]["collapsed"] == false:
				for i in all_cells[id+1]["domain"]:
					if all_cells[id+1]["domain"][i][3] != all_cells[id]["domain"][picked_tile][1]:
						sides_to_remove.append(i)
				for i in sides_to_remove:
					all_cells[id+1]["domain"].erase(i)
		#SOUTH
		if id+w_size < w_size*h_size:
			var sides_to_remove = []
			if all_cells[id+w_size]["collapsed"] == false:
				for i in all_cells[id+w_size]["domain"]:
					if all_cells[id+w_size]["domain"][i][0] != all_cells[id]["domain"][picked_tile][2]:
						sides_to_remove.append(i)
				for i in sides_to_remove:
					all_cells[id+w_size]["domain"].erase(i)
		
		
		all_cells_copy = all_cells.duplicate()
		all_cells_copy.sort_custom(sort_ascending_size)
		var remove_ids = []
		for i in all_cells_copy.size():
			if i <= all_cells_copy.size():
				if all_cells_copy[i]["collapsed"] == true:
					remove_ids.append(i)
		remove_ids.reverse()

		for i in remove_ids:
			if not all_cells_copy.is_empty():
				all_cells_copy.remove_at(i)

		if all_cells_copy.is_empty():
			running = false
		iterations += 1
		randomize()

		# Choose tile to collapse
		for i in all_cells_copy.size():
			if i+1 < all_cells_copy.size():
				if all_cells_copy[i]["domain"].size() < all_cells_copy[i+1]["domain"].size():
					all_cells_copy.resize(i+1)
					break
		nextTile = all_cells_copy.pick_random()

func draw():
	for x in h_size:
		for y in w_size:
			var cell = all_cells[x+y*w_size]
			if cell["collapsed"] == true:
				if cell["picked"] == null:
					cell["picked"] = 6
				set_cell_item(Vector3(x*5,0,y*5),cell["picked"])
				
	for i in get_used_cells():
		var tile 
		tile = tiles[get_cell_item(i)].duplicate()
		tile.position = i
		map.add_child.call_deferred(tile)
func sort_ascending_size(a, b):
	if a["domain"].size() < b["domain"].size():
		return true
	return false
