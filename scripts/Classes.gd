extends Node


class Champion:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}
	var obj = {}
	
	func _init():
		number.index = Global.number.primary_key.champion
		Global.number.primary_key.champion += 1
		list.argument = {}
		obj.ruin = null
		obj.argument = null
		number.wound = 0
		
		var input = {}
		input.name = "Art"
		var argument = Classes.Argument.new(input)
		list.argument [input.name] = argument
		input.name = "Expansion"
		argument = Classes.Argument.new(input)
		list.argument [input.name] = argument
		input.name = "Storm"
		argument = Classes.Argument.new(input)
		list.argument [input.name] = argument

	func calc_t():
		#find correct time w.o. glitch
		var t = 0
		var flag = true
		var glitchs = []
		
		for _i in obj.argument.list.S.number.value:
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
		obj.ruin = ruin
		obj.argument = list.argument["Storm"]
		var power = pow(obj.argument.list.I.number.value, 2) * obj.argument.list.R.number.value
		#ruin.init_zones()
		
		for zone in obj.ruin.array.zone:
			for monster in zone.array.monster:
				while monster.number.hp > 0:
					var time = calc_t()
					ruin.number.time.current += time
					var work = power * time / monster.number.uof
					monster.number.hp -= work
					var wound = zone.calc_wounds()
					number.wound += wound
		
		ruin.get_appraisal("time")
		leave_ruin()

	func leave_ruin():
		var result = {}
		result.time = {}
		result.time.owner = number.index
		result.time.value = obj.ruin.number.time.current
		result.wound = {}
		result.wound.owner = number.index
		result.wound.value = number.wound
		obj.ruin.update_top(result)
		
		var experience = {}
		experience.I = calc_kills()
		experience.R = result.wound.value
		experience.S = result.time.value
		
		for key in experience.keys():
			obj.argument.list[key].get_experience(experience[key])
			print()
		
		reset()

	func calc_kills():
		var kills = 0
		
		for zone in obj.ruin.array.zone:
			var index_f = Global.array.sequence["A000040"].find(zone.number.difficulty) 
			var koef = Global.array.sequence["A001358"][index_f]
			
			for monster in zone.array.monster:
				kills += monster.number.worth * koef
		
		return kills

	func reset():
		number.wound = 0
		obj.ruin.reset()
		obj.ruin = null
		obj.argument = null

class Worker:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}
	
	func _init(input_):
		number.index = input_.index

class Argument:
	var list = {}
	var string = {}
	
	func _init(input_):
		string.name = input_.name
		init_stats()
	
	func init_stats():
		for key in Global.list.stat[string.name]:
			var input = {}
			input.argument = string.name
			input.key = key
			list[key] = Classes.Stat.new(input)

class Stat:
	var number = {}
	var string = {}
	var key = null
	
	func _init(input_):
		string.argument = input_.argument
		key = input_.key
		number.stage = 0
		
		get_base()

	func get_base():
		number.value = Global.list.stat[string.argument][key].base
		number.step = Global.list.stat[string.argument][key].step
		number.current = 0
		number.max = pow(Global.number.argument.base, Global.number.argument.degree)
	
	func get_experience(experiance):
		number.current += experiance
		update_growth()

	func update_growth():
		while number.current >= number.max:
			number.current -= number.max
			number.stage += 1
			number.value += number.step
			number.max = pow(Global.number.argument.base + number.stage, Global.number.argument.degree)

class Ruin:
	var number = {}
	var string = {}
	var array = {}
	var list = {}
	var flag = {}

	func _init(input_):
		number.index = Global.number.primary_key.ruin
		Global.number.primary_key.ruin += 1
		
		string.type = input_.type
		number.rank = input_.rank
		number.difficulty = Global.array.sequence["A000124"][number.rank]
		number.time = {}
		number.appraisal = {}
		flag.stat = {}
		flag.stat.I = input_.I
		flag.stat.R = input_.R
		flag.stat.S = input_.S
		array.top = {}
		array.top.time = []
		array.top.wound = []
		string.sort = {}
		string.sort.time = "sort_ascending"
		string.sort.wound = "sort_ascending"
		
		init_zones()
		init_rewards()

	func init_zones():
		number.time.perfect = 0 
		number.time.current = 0
		number.appraisal.time = 0
		array.zone = []
		var pool = Global.array.pool.zone[number.rank]
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, pool.size()-1)
		
		for difficulty in pool[index_r]:
			var input = {}
			input.difficulty = difficulty
			input.rank = number.rank
			input.ruin = self
			var zone = Classes.Zone.new(input)
			array.zone.append(zone)

	func init_rewards():
		array.pizza = []
		
		for key in flag.stat.keys():
			if flag.stat[key]:
				for pizza in Global.array.pool.pizza:
					if pizza[key] == 2:
						array.pizza.append(pizza)

	func get_appraisal(type_):
		match type_:
			"time":
				var koef = stepify(number.time.current/number.time.perfect, 0.01)
				var k = koef * 100 - 100
				var degree = 0
				var n = 2
				
				while n <= k:
					degree += 1
					n *= 2

	func update_top(result_):
		for key in result_.keys():
			var top = array.top[key]
			top.append(result_[key])
			
			top.sort_custom(Sorter, string.sort[key])
			
			if top.size() > Global.number.size.top:
				top.resize(Global.number.size.top)
			
			var arr = []
			for a in array.top[key]:
				arr.append(a.value)
			#print(arr, key)
			Global.array.memory[key].append(result_[key].value)
			

	func generate_rewards():
		pass

	func reset():
		number.time.current = 0
		number.appraisal.time = 0
		
		for zone in array.zone:
			zone.reset()

class Zone:
	var number = {}
	var array = {}
	var obj = {}
	
	func _init(input_):
		number.index = Global.number.primary_key.zone
		Global.number.primary_key.zone += 1
		
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
			obj.ruin.number.time.perfect += monster.number.hp

	func calc_wounds():
		var wound = 0
		
		for monster in array.monster:
			if monster.number.hp > 0:
				wound += monster.number.threat
		
		return wound

	func reset():
		for monster in array.monster:
			monster.number.hp = pow(monster.number.echelon, 2) * 10

class Monster:
	var number = {}
	var obj = {}
	
	func _init(input_):
		number.index = Global.number.primary_key.monster
		Global.number.primary_key.monster += 1
		
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

class Pizza:
	var number = {}
	var string = {}
	
	func _init(input_):
		string.abundance = {}
		string.abundance.rank = ""
		string.abundance.name = ""
		
		string.chart = {}
		string.chart.name = ""
		
		number.purity = {} 
		number.purity.rank = -1
		number.purity.value = -1

class Sorter:
    static func sort_ascending(a, b):
        if a.value < b.value:
            return true
        return false

    static func sort_descending(a, b):
        if a.value > b.value:
            return true
        return false
