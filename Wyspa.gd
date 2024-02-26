@tool
extends GridMap


@export var start : bool = false : set = start_generator
@export var clean : bool = false : set = clean_generator
@export var h_size = 4
@export var w_size = 4
@export var wait_time : int = 10
@export var random_seed : String
enum {NORTH, EAST, SOUTH, WEST}

const TRAWA = preload("res://Trawa.png")
const WODA = preload("res://Woda.png")
const DROGA = preload("res://Droga.png")
const DROGA_ROG = preload("res://Droga_róg.png")
const KLIF = preload("res://Klif.png")
const KLIF_ROG = preload("res://Klif_róg.png")
const KLIF_WODA = preload("res://Klif_woda.png")
const WODA_ROG = preload("res://Woda_róg.png")
const CLIFFCORNER_2 = preload("res://cliffcorner_2.png")
const ROAD_GRASS_CORNER = preload("res://road_grass_corner.png")
const WATERCORNER = preload("res://watercorner.png")

var tiles = []

var all_cells = []
var all_cells_copy = []
var tiles_to_rotate = []
var rules = []
var rules_dictionary = {}
var test = []
var nextTile

@onready var map = $".."

func clean_generator(_value):
	clear()
	for i in map.get_children():
		if not i is GridMap:
			i.queue_free()
	clean = false
	
func start_generator(_value):
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(random_seed)
	seed(rng.seed)
	start = false
	tiles.clear()
	var new_tile = Sprite3D.new()
	new_tile.texture = TRAWA
	new_tile.rotate_x(-PI/2)
	tiles.append(new_tile)
	new_tile = Sprite3D.new()
	new_tile.texture = WODA
	new_tile.rotate_x(-PI/2)
	tiles.append(new_tile)
	rules = [
	[[0,0,0],[0,0,0],[0,0,0],[0,0,0]],[[3,3,3],[3,3,3],[3,3,3],[3,3,3]],
	]
	
	rules_dictionary.clear()
	
	tiles_to_rotate = [
	{"tile" : DROGA, "walls" : [[0,1,1],[1,1,1],[1,1,0],[0,0,0]]},
	{"tile" : DROGA_ROG, "walls" : [[0,0,0],[0,0,0],[0,1,1],[1,1,0]]},
	{"tile" : KLIF, "walls" : [[0,2,0],[0,0,0],[0,2,0],[0,0,0]]},
	{"tile" : KLIF_ROG, "walls" : [[0,0,0],[0,0,0],[0,2,0],[0,2,0]]},
	{"tile" : KLIF_WODA, "walls" : [[0,0,0],[0,2,3],[3,3,3],[3,2,0]]},
	{"tile" : WODA_ROG, "walls" : [[3,3,3],[3,2,0],[0,2,3],[3,3,3]]},
	{"tile" : CLIFFCORNER_2, "walls" : [[0,0,0],[0,2,0],[0,2,0],[0,0,0]]},
	{"tile" : ROAD_GRASS_CORNER, "walls" : [[1,1,0],[0,1,1],[1,1,1],[1,1,1]]},
	{"tile" : WATERCORNER, "walls" : [[0,0,0],[0,2,3],[3,2,0],[0,0,0]]}]
	
	all_cells_copy = []
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

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(random_seed)
	seed(rng.seed)
	start = false
	tiles.clear()
	var new_tile = Sprite3D.new()
	new_tile.texture = TRAWA
	new_tile.rotate_x(-PI/2)
	tiles.append(new_tile)
	new_tile = Sprite3D.new()
	new_tile.texture = WODA
	new_tile.rotate_x(-PI/2)
	tiles.append(new_tile)
	rules = [
	[[0,0,0],[0,0,0],[0,0,0],[0,0,0]],[[3,3,3],[3,3,3],[3,3,3],[3,3,3]],
	]
	
	rules_dictionary.clear()
	
	tiles_to_rotate = [
	{"tile" : DROGA, "walls" : [[0,1,1],[1,1,1],[1,1,0],[0,0,0]]},
	{"tile" : DROGA_ROG, "walls" : [[0,0,0],[0,0,0],[0,1,1],[1,1,0]]},
	{"tile" : KLIF, "walls" : [[0,2,0],[0,0,0],[0,2,0],[0,0,0]]},
	{"tile" : KLIF_ROG, "walls" : [[0,0,0],[0,0,0],[0,2,0],[0,2,0]]},
	{"tile" : KLIF_WODA, "walls" : [[0,0,0],[0,2,3],[3,3,3],[3,2,0]]},
	{"tile" : WODA_ROG, "walls" : [[3,3,3],[3,2,0],[0,2,3],[3,3,3]]},
	{"tile" : CLIFFCORNER_2, "walls" : [[0,0,0],[0,2,0],[0,2,0],[0,0,0]]},
	{"tile" : ROAD_GRASS_CORNER, "walls" : [[1,1,0],[0,1,1],[1,1,1],[1,1,1]]},
	{"tile" : WATERCORNER, "walls" : [[0,0,0],[0,2,3],[3,2,0],[0,0,0]]}]
	
	all_cells_copy = []
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
		
func generate():
	var running = true
	var iterations = 0
	while running and iterations < h_size*w_size:
		var id = nextTile["xy"]
		all_cells[id]["collapsed"] = true
		all_cells[id]["picked"] = all_cells[id]["domain"].keys().pick_random() 
		var picked_tile = all_cells[id]["picked"]
		all_cells[id]["domain"] = {picked_tile : all_cells[id]["domain"][picked_tile]}
		
		var ids_to_check = []
		for evaluations in 5:
			if evaluations > 0 and not ids_to_check.is_empty():
				id = ids_to_check.pop_front()
			for side in 4:
				var sides_to_remove = []
				var differential
				#Assign tile shift based on the side we look at
				match side:
					NORTH:
						if id-w_size >= 0:
							differential = -w_size
					EAST:
						if (id + 1) % w_size != 0 and id+1 < w_size*h_size:
							differential = 1
					SOUTH:
						if id+w_size < w_size*h_size:
							differential = w_size
					WEST:
						if id-1 >= 0 and id % w_size != 0:
							differential = -1

				if differential != null and picked_tile != null:
					if  evaluations == 0:
						ids_to_check.append(id+differential)
					if all_cells[id+differential]["collapsed"] == false:
						for i in all_cells[id+differential]["domain"]:
							var reversed_walls = all_cells[id+differential]["domain"][i][side-2].duplicate()
							reversed_walls.reverse()
							for tile in all_cells[id]["domain"]:
								if reversed_walls != all_cells[id]["domain"][tile][side]:
									sides_to_remove.append(i)
					for tile_id in tiles.size():
						for options in all_cells[id]["domain"].size()-1:
							if sides_to_remove.has(tile_id):
								sides_to_remove.erase(tile_id)
							else:
								break
					for n in sides_to_remove:
						all_cells[id+differential]["domain"].erase(n)
		
		all_cells_copy = all_cells.duplicate()
		all_cells_copy.sort_custom(sort_ascending_size)
		
		var remove_ids = []
		for i in all_cells_copy.size():
			if i <= all_cells_copy.size():
				if all_cells_copy[i]["collapsed"] == true:
					remove_ids.append(i)
		remove_ids.reverse()

		for id_to_remove in remove_ids:
			if not all_cells_copy.is_empty():
				all_cells_copy.remove_at(id_to_remove)

		#Calculate the entropy of not collapsed tiles
		for i in all_cells_copy.size():
			if i+1 < all_cells_copy.size():
				if all_cells_copy[i]["domain"].size() < all_cells_copy[i+1]["domain"].size():
					all_cells_copy.resize(i+1)
					break
		# Choose next tile to collapse
		if all_cells_copy.is_empty():
			running = false
		else:
			nextTile = all_cells_copy.pick_random()
		iterations += 1
		
		draw()
#Places boxes on chosen spots and then replaces them with tiles
func draw():
	var t : int = 0
	#Grid based
	for x in h_size:
		for y in w_size:
			var cell = all_cells[x+y*w_size]
			if cell["collapsed"] == true:
				if cell["picked"] == null:
					pass
				set_cell_item(Vector3(x*2,0,y*2),cell["picked"])
	for i in get_used_cells():
		t += 1
		if t%2 == 0 : await get_tree().create_timer(0.1).timeout
		var tile 
		tile = tiles[get_cell_item(i)].duplicate()
		tile.position = i
		map.add_child.call_deferred(tile)



	###Tile based

	#for x in h_size:
		#for y in w_size:
			#var cell = all_cells[x+y*w_size]
			#if cell["collapsed"] == true:
				#if cell["picked"] == null:
					#pass
				#t += 1
				#if t%2 == 0 : await get_tree().create_timer(0).timeout
				#var tile 
				#tile = tiles[cell["picked"]].duplicate()
				#tile.position = Vector3(x*1.95,0,y*1.95)
				#map.add_child.call_deferred(tile)



#Places smalles dictionaries at the start of the array
func sort_ascending_size(a, b):
	if a["domain"].size() < b["domain"].size():
		return true
	return false
