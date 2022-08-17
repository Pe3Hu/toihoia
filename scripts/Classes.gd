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
		print("%",number.difficulty)
		init_zones()
	
	func init_zones():
		array.zone = []
		var pool = number.difficulty
		
		while pool > 0:
			var options = []
			var max_i = 0
			var index_i 
			
			while Global.array.sequence["A000040"][max_i+1] <= pool:
				max_i += 1
			
			if max_i > 0:
				for _i in max_i:
					for _j in max_i - _i:
						options.append(_i)
				
				print("$",max_i, options,pool)
				randomize()
				options.shuffle()
				Global.rng.randomize()
				var index_r = Global.rng.randi_range(0, options.size()-1)
				index_i = options[index_r]
			else:
				index_i = 0
			
			var input = {}
			input.difficulty = Global.array.sequence["A000040"][index_i]
			input.rank = number.rank
			input.ruin = self
			pool -= input.difficulty
			print("@",input.difficulty, "=", pool)
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
			
			for _i in Global.array.pool.zone[number.rank].size():
				var threat = Global.array.pool.zone[number.rank][_i]
				var max_i = min(Global.array.pool.zone[number.rank].back(), pool)
				
				if threat <= pool:
					#print(threat, "-", pool)
					for _j in pow(max_i-_i, 2):
						options.append(threat)
			
			#print(options)
			randomize()
			options.shuffle()
			Global.rng.randomize()
			var index_i = Global.rng.randi_range(0, options.size()-1)
			
			var input = {}
			input.echelon = options[index_i]
			input.zone = self
			var monster = Classes.Monster.new(input)
			Global.array.monster.append(monster)
			pool -= options[index_i]
			print(monster.number)

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
				number.hp = pow(number.echelon, 2)
				number.threat = number.echelon
				number.worth = pow(number.echelon, 2)
	

class Loot:
	var number = {}
	
	func _init(input_):
		pass
