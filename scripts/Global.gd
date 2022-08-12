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

func init_list():
	init_window_size()
	init_primary_key()

func init_array():
	array.button = {}
	array.button.response = []
	array.button.response.append([])
	
	for _i in 12:
		array.button.response[0].append("Normal") 

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


	
