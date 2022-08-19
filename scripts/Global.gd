extends Node


var rng = RandomNumberGenerator.new()
var list = {}
var array = {}
var scene = {}
var node = {}
var ui = {}
var obj = {}
var flag = {}
var data = {}

func init_window_size():
	list.window_size = {}
	list.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	list.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	list.window_size.center = Vector2(list.window_size.width/2, list.window_size.height/2)

func init_primary_key():
	list.primary_key = {}
	list.primary_key.encounter = 0
	list.primary_key.champion = 0
	list.primary_key.ruin = 0
	list.primary_key.zone = 0
	list.primary_key.monster = 0

func init_list():
	init_window_size()
	init_primary_key()

func init_array():
	array.button = {}
	array.button.response = []
	array.button.response.append([])
	
	for _i in 12:
		array.button.response[0].append("Normal")
	
	array.champion = []
	array.ruin = []
	array.monster = []
	
	array.sequence = {} 
	array.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	array.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	
	array.pool = {}
	array.pool.monster = [
		[1, 2, 3],
		[1, 2, 3, 4],
		[2, 3, 4],
		[2, 3, 4, 5]
	]
	
	init_pool_zone()
	init_pool_pizza()

func init_pool_zone():
	array.pool.zone = []
	
	for sum in array.sequence["A000124"]:
		var options = []
		var partition = []
		
		partition.resize(sum)
		partition.fill(1)
		
		while partition != null:
			var flag = true
			
			for num in partition:
				flag = flag && array.sequence["A000040"].has(num)
			
			if flag:
				
				options.append(partition.duplicate())
				
			partition = get_next_partition(partition)
			
		array.pool.zone.append(options)

func init_pool_pizza():
	array.pool.pizza = []
	
	for _i in range(0,3):
		for _r in range(0,3):
			for _s in range(0,3):
				if _i+_r+_s == 3 && max(_i,max(_r,_s)) == 2:
					var pizza = {}
					pizza.I = _i
					pizza.R = _r
					pizza.S = _s
					array.pool.pizza .append(pizza)

func get_next_partition(partition):
	if partition.size() == 1:
		return null
	
	var index_min = 0
	
	for _i in partition.size()-1:
		if partition[_i] < partition[index_min]:
			index_min = _i
	
	partition[index_min] += 1
	partition[-1] -= 1
	
	var part_sum = 0
	for _j in range(index_min+1, partition.size()):
		part_sum += partition[_j]
	partition.resize(index_min+1) 
	for _i in part_sum:
		partition.append(1)
	return partition

func init_scene():
	pass

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 
	
func init_obj():
	obj.field = {}
	ui.bar = []

func init_data():
	data.size = {}
	data.size.bar = Vector2(91,30)
	data.size.top = 10
	data.monster = {}
	data.monster.n = 4

func init_flag():
	flag.ready = false
	flag.generate = true

func _ready():
	init_list()
	init_array()
	init_scene()
	init_node()
	init_obj()
	init_data()
	init_flag()


	
