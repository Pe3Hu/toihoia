extends Node


var circle_texture = load("res://assets/icons/uicons/circle.png")
var square_texture = load("res://assets/icons/uicons/square.png")
var triangle_texture = load("res://assets/icons/uicons/triangle.png")
var cross_texture = load("res://assets/icons/uicons/cross.png")

func _ready():
	#generate_action()
	init_champions()
	init_ruins()
	
func init_champions():
	var champion = Classes.Champion.new()
	Global.array.champion.append(champion)

func init_ruins():
	var input = {}
	input.rank = 0
	input.type = "Basic"
	var ruin = Classes.Ruin.new(input)
	Global.array.ruin.append(ruin)

func init_monsters():
	pass

func generate_action():
	for _i in 3:
		var node_path = "/root/Game/Action/TextureRect"+str(_i+1)
		var node = get_node(node_path) 
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, 2)
		
		match index_r:
			0:
				node.set_texture(circle_texture) 
			1:
				node.set_texture(square_texture) 
			2:
				node.set_texture(triangle_texture) 

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.generate:
			generate_action()
			Global.flag.generate = !Global.flag.generate
		else:
			Global.flag.generate = !Global.flag.generate
			
	if event is InputEventMouseMotion:
		for _i in Global.array.button.response[0].size():
			var button_path = "/root/Game/ChampionPanel/ResponseValues/ResponseButton"+str(_i+1)
			var button = get_node(button_path) 
			if Global.array.button.response[0][_i] != "Pressed":
				Global.array.button.response[0][_i] = "Normal"
			
			if button.is_hovered():
				var flag = _i < Global.array.button.response[0].size()-2
				
				for _j in 3:
					flag = flag && Global.array.button.response[0][_i] == "Normal"
				
				if flag:
					for _j in Global.array.button.response[0].size():
						var enable_button_path = "/root/Game/ChampionPanel/ResponseValues/ResponseButton"+str(_j+1)
						var enable_button = get_node(enable_button_path)
						enable_button.disabled = false
			
					for _j in 3:
						var parent_path = "/root/Game/Action/TextureRect"+str(_j+1)
						var parent_node = get_node(parent_path) 
						var hovered_button_path = "/root/Game/ChampionPanel/ResponseValues/ResponseButton"+str(_i+1+_j)
						var hovered_button = get_node(hovered_button_path)  
						hovered_button.disabled = true
						hovered_button.set_disabled_texture(parent_node.texture)
						Global.array.button.response[0][_i] = "Disabled"

func _process(delta):
	pass

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
