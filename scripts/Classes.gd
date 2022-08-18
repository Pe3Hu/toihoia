extends Node


class Champion:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}
	var stats = {}
	
	func _init():
		number.index = Global.list.primary_key.champion
		Global.list.primary_key.champion += 1
		array.argument = []
		
		var input = {}
		input.name = "Art"
		var argument = Classes.Argument.new(input)
		array.argument.append(argument)
		input.name = "Expansion"
		argument = Classes.Argument.new(input)
		array.argument.append(argument)
		input.name = "Storm"
		argument = Classes.Argument.new(input)
		array.argument.append(argument)
		
		init_stats()

	func init_stats():
		#intensity of current
		stats.I = 10
		#resistance
		stats.R = 100
		#seclusion
		stats.S = 10

	func calc_p():
		#power
		stats.P = pow(stats.I, 2) * stats.R

	func calc_t():
		#find correct time w.o. glitch
		var t = 0
		var flag = true
		var glitchs = []
		
		for _i in stats.S:
			glitchs.append(0)
		
		while flag:
			t+=1 
			glitchs.append(1)
			
			randomize()
			glitchs.shuffle()
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, glitchs.size()-1)
			flag = glitchs[index_r] == 0
		
		return t

	func overcome(ruin):
		calc_p()
		ruin.init_zones()
		
		for zone in ruin.array.zone:
			for monster in zone.array.monster:
				while monster.number.hp > 0:
					var time = calc_t()
					ruin.number.time += time
					var work = stats.P * time / monster.number.uof
					monster.number.hp -= work
		
		print("time: ",ruin.number.time)

class Worker:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}
	var stats = {}
	
	func _init(input_):
		number.index = input_.index

class Argument:
	var number = {}
	var string = {}
	
	func _init(input_):
		string.name = input_.name
		number.stage = 0

class Ruin:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}
	
	func _init(input_):
		number.index = Global.list.primary_key.ruin
		Global.list.primary_key.ruin += 1
		
		string.type = input_.type
		number.rank = input_.rank
		number.difficulty = Global.array.sequence["A000124"][number.rank]
	
	func init_zones():
		number.time = 0 
		array.zone = []
		var pool = Global.array.pool.zone[number.rank]
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, pool.size()-1)
		
		print(pool[index_r])
		for difficulty in pool[index_r]:
			var input = {}
			input.difficulty = difficulty
			input.rank = number.rank
			input.ruin = self
			var zone = Classes.Zone.new(input)
			array.zone.append(zone)

class Zone:
	var number = {}
	var array = {}
	var obj = {}
	
	func _init(input_):
		number.index = Global.list.primary_key.zone
		Global.list.primary_key.zone += 1
		
		number.rank = input_.rank
		number.difficulty = input_.difficulty
		obj.ruin = input_.ruin 
		init_monsters()
	
	func init_monsters():
		array.monster = []
		var pool = number.difficulty
		
		while pool > 0:
			var options = []
			
			for _i in Global.array.pool.monster[number.rank].size():
				var threat = Global.array.pool.monster[number.rank][_i]
				var max_i = min(Global.array.pool.monster[number.rank].back(), pool)
				
				if threat <= pool:
					#print(threat, "-", pool)
					for _j in pow(max_i-_i, 2):
						options.append(threat)
			
			randomize()
			options.shuffle()
			Global.rng.randomize()
			var index_i = Global.rng.randi_range(0, options.size()-1)
			
			var input = {}
			input.echelon = options[index_i]
			input.zone = self
			var monster = Classes.Monster.new(input)
			array.monster.append(monster)
			pool -= options[index_i]

class Monster:
	var number = {}
	var obj = {}
	
	func _init(input_):
		number.index = Global.list.primary_key.monster
		Global.list.primary_key.monster += 1
		
		number.echelon = input_.echelon
		obj.zone = input_.zone 
		attach_to_ruin()
	
	func attach_to_ruin():
		match obj.zone.obj.ruin.string.type:
			"Basic":
				#work
				number.hp = pow(number.echelon, 2) * 10
				number.threat = number.echelon
				number.worth = pow(number.echelon, 2)
				#unit of measurement
				number.uof = 10000

class Loot:
	var number = {}
	
	func _init(input_):
		pass
