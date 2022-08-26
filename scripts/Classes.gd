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
		list.argument[input.name] = argument
		input.name = "Expansion"
		argument = Classes.Argument.new(input)
		list.argument[input.name] = argument
		input.name = "Storm"
		argument = Classes.Argument.new(input)
		list.argument[input.name] = argument

	func calc_t():
		#find correct time w.o. glitch
		var t = 0
		var flag = true
		var glitchs = []
		
		for _i in obj.argument.list.stat.S.number.value:
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
		var a = obj.argument
		var power = pow(obj.argument.list.stat.I.number.value, 2) * obj.argument.list.stat.R.number.value
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
		
		var kills = calc_kills()
		var experience = {}
		experience.I = kills
		experience.R = result.wound.value
		experience.S = result.time.value
		
		for key in experience.keys():
			obj.argument.list.stat[key].get_experience(experience[key])
		
		obj.ruin.generate_rewards(kills)
		
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

class Servitor:
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
		list.stat = {}
		
		for key in Global.list.stat[string.name]:
			var input = {}
			input.argument = string.name
			input.key = key
			list.stat[key] = Classes.Stat.new(input)

class Stat:
	var number = {}
	var string = {}
	var key = {}

	func _init(input_):
		string.argument = input_.argument
		key = {}
		key.self = input_.key
		number.stage = 0
		
		get_base()

	func get_base():
		number.value = Global.list.stat[string.argument][key.self].base
		number.step = Global.list.stat[string.argument][key.self].step
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
		list.appraisal = {}
		
		init_zones()
		init_pizzas()

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

	func init_pizzas():
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
					
				list.appraisal[type_] = degree

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

	func generate_rewards(kills_):
		var score = round(sqrt(kills_)) - list.appraisal["time"]
		#print(kills_)
		#print(score)

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
				number.timer = 0
				number.cd = 1

class LootBox:
	var number = {}

	func _init(input_):
		pass

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

class Minimap:
	var number = {}
	var array = {}

	func _init():
		array.district = []
		array.region = []
		init_districts()
		init_borderlands()
		init_associates()
		#hue_districts()

	func init_districts():
		for _i in Global.number.size.minimap:
			array.district.append([])
			
			for _j in Global.number.size.minimap:
				var district = Classes.District.new()
				array.district[_i].append(district)
		

	func init_borderlands():
		array.borderland = []
		
		for _i in array.district.size():
			for _j in array.district[_i].size():
				var district = array.district[_i][_j]
				
				for neighbor in Global.array.neighbor["4"]:
					var grid = Vector2(_j,_i)
					grid += neighbor
					
					if check_border(grid):
						var neighbor_district = array.district[grid.y][grid.x]
						add_borderland(district,neighbor_district)

	func init_center():
		var mid = round(Global.number.size.minimap/2)
		var grids = [Vector2(mid,mid)]
		var shifts = [
			[Vector2(-1,0),Vector2(1,0)],
			[Vector2(0,-1),Vector2(0,1)]
			]
		
		for _i in shifts.size():
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, shifts.size()-1)
			var index_f =  Global.rng.randi_range(0, shifts[index_r].size()-1)
			var grid = Vector2(grids.back().x,grids.back().y)
			grid += shifts[index_r][index_f]
			grids.append(grid)
			shifts.pop_at(index_r)
		
		for grid in grids:
			array.district[grid.y][grid.x].obj.self.color = Color().from_hsv(0.5,1,1) 

	func hue_districts():
		#init_center()
		init_associates()

	func init_associates():
		array.region.append([])
		var unused = []
		
		for districts in array.district:
			for district in districts:
				unused.append(district)
		
		while unused.size() > 0 && Global.flag.stop:
			generate_associate(unused)
		
		for region in array.region[0]:
			for district in region.array.district:
				var hue = float(region.number.index)/float(array.region[0].size())
				district.obj.self.color = Color().from_hsv(hue,1,1) 
		
		
		for districts in array.district:
			for district in districts:
				if district.flag.free:
					district.obj.self.color = Color().from_hsv(0,0,0) 

	func click_f():
		array.region.append([])
		var unused = []
		
		for districts in array.district:
			for district in districts:
				if district.flag.free: 
					unused.append(district)
		
		generate_associate(unused)
		var isolated = detect_isolated(unused)
		if isolated != null:
			shift_isolated(isolated)
		
		for region in array.region[0]:
			for district in region.array.district:
				var hue = float(region.number.index)/float(array.region[0].size())
				district.obj.self.color = Color().from_hsv(hue,1,1) 
		
		
		for districts in array.district:
			for district in districts:
				if district.flag.free:
					district.obj.self.color = Color().from_hsv(0,0,0) 

	func generate_associate(unused_):
		var rank = 0
		var input = {}
		input.rank = rank
		var region = Classes.Region.new(input)
		array.region[rank].append(region)
		var begin = corner_district(unused_)
		region.add_district(begin)
		var districts = [begin]
		var size = 1
		
		while size < Global.number.size.associate:
			var options = []
			
			for district in districts:
				for neighbor in district.array.neighbor:
					if neighbor.flag.free:
						var mid = round(Global.number.size.minimap/2)
#						var d = max(abs(mid-neighbor.number.x),abs(mid-neighbor.number.y))
#						var n = d + 1
#						for _i in pow(n,3): 
#							options.append(neighbor)
						var option = {}
						option.n = neighbor.array.delimited.size()
						option.d = max(abs(mid-neighbor.number.x),abs(mid-neighbor.number.y))
						option.neighbor = neighbor
						options.append(option)
			
			var min_n = Global.array.neighbor["4"].size()

			for option in options:
				if min_n > option.n:
					min_n = option.n
			
			for option in options:
				if min_n != option.n:
					options.erase(option)
			var max_d = 0
			
			for option in options:
				if option.d > max_d:
					max_d = option.d
					
			for option in options:
				if max_d != option.d:
					options.erase(option)
			
			if options.size() > 0:
				Global.rng.randomize()
				var index_r = Global.rng.randi_range(0, options.size()-1)
				var option = options[index_r].neighbor
				unused_.erase(option)
				option.flag.free = false
				districts.append(option)
				region.add_district(option)
			
			size += 1
		
		if districts.size() != Global.number.size.associate:
			print("district size error")
			#Global.flag.stop = false
		

	func weak_district(unused_):
		var min_neighbor = Global.array.neighbor["4"].size()
		var options = []
		
		for district in unused_:
			if min_neighbor > district.array.delimited.size():
				min_neighbor = district.array.delimited.size()
		
		for district in unused_:
			if min_neighbor == district.array.delimited.size():
				options.append(district)
		
		var weak = {}
		weak.sum = -1
		weak.option = null
		
		for option in options:
			if option.number.x + option.number.y > weak.sum:
				weak.sum = option.number.x + option.number.y
				weak.option = option
		
		unused_.erase(weak.option)
		weak.option.flag.free = false
		return weak.option

	func corner_district(unused_):
		var min_neighbor = Global.array.neighbor["4"].size()
		var options = []
		
		for district in unused_:
			if min_neighbor > district.array.delimited.size():
				min_neighbor = district.array.delimited.size()
		
		for district in unused_:
			if min_neighbor == district.array.delimited.size():
				options.append(district)
		
		var mid = round(Global.number.size.minimap/2)
		var max_far_away = 0
		
		for option in options:
			var d = abs(mid-option.number.x)+abs(mid-option.number.y)
			
			if d > max_far_away:
				max_far_away = d
		
		var options_2 = []
		
		for option in options:
			var d = abs(mid-option.number.x)+abs(mid-option.number.y)
			
			if d == max_far_away:
				options_2.append(option)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options_2.size()-1) 
		var option = options_2[index_r]
		unused_.erase(option)
		option.flag.free = false
		return option

	func detect_isolated(unused_):
		for option in unused_:
			if option.array.delimited.size() == 0:
				return option
		
		return null

	func shift_isolated(isolated_):
		var regions = []
		var rank = 0
		
		for neighbor in isolated_.array.neighbor:
			regions.append(neighbor.array.region[rank])
		
		var options = []
		
		for _i in regions:
			var region = array.region[rank][_i]
			for district in region.array.district:
				for neighbor in district.array.neighbor:
					if neighbor.flag.free:
						options.append(region)
			
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		var region = options[index_r]
		#var swap = 
		#region.add_district(isolated_)

	func add_borderland(parent_district_,child_district_):
		if !parent_district_.array.neighbor.has(child_district_):
			parent_district_.array.neighbor.append(child_district_)
			child_district_.array.neighbor.append(parent_district_)
			parent_district_.array.delimited.append(child_district_)
			child_district_.array.delimited.append(parent_district_)

	func check_border(grid_):
		return grid_.x >= 0 && grid_.x < Global.number.size.minimap && grid_.y >= 0 && grid_.y < Global.number.size.minimap

class District:
	var number = {}
	var obj = {}
	var array = {}
	var flag = {}

	func _init():
		number.index = Global.number.primary_key.district
		Global.number.primary_key.district += 1
		number.x = number.index % Global.number.size.minimap
		number.y = number.index / Global.number.size.minimap
		obj.parent = Global.node.minimap
		obj.self = preload("res://scenes/District.tscn").instance()
		obj.self.rect_min_size = Vector2(Global.number.size.district,Global.number.size.district)
		obj.parent.add_child(obj.self)
		array.region = []
		array.neighbor = []
		array.associated = []
		array.delimited = []
		flag.free = true
		
		for _i in Global.number.size.regions:
			array.region.append(-1)

class Region:
	var number = {}
	var array = {}

	func _init(input_):
		number.index = Global.number.primary_key.region
		Global.number.primary_key.region += 1
		number.rank = input_.rank
		array.district = []

	func add_district(district_):
		array.district.append(district_)
		district_.array.region[number.rank] = number.index
		
		for neigbhor in district_.array.neighbor:
			if array.district.has(neigbhor):
				district_.array.associated.append(neigbhor)
			district_.array.delimited.erase(neigbhor)
			neigbhor.array.delimited.erase(district_)

class Ability:
	var number = {}
	var string = {}
	var array = {}

	func _init(input_):
		number.index = Global.number.primary_key.ability
		Global.number.primary_key.ability += 1
		string.name = input_.name
		string.elemental = input_.elemental
		number.factor = input_.factor
		set_divide(input_.divide)

	func calc_result(work_):
		number.work = {}
		var result = {}
		var champion_factor_ = {}
		champion_factor_.a = 0
		champion_factor_.b = 0
		
		for key in array.key:
			number.work[key] = number.divide[key] * work_
			var k = Global.list.elemental[string.elemental][key]
			var base = 5
			var result_0 = (base+k)/base*number.work[key]  
			base = 12
			var result_1 = ((number.factor.a+champion_factor_.a)*result_0+(number.factor.b+champion_factor_.b))/base
			var result_2 = round(sqrt(result_1))
			result[key] = result_2
			
		return result
	
	func set_divide(divide_):
		array.key = []
		for key in divide_:
			array.key.append(key)
		
		number.divide = {}
		var sum = 0
		
		for key in array.key:
			sum += divide_[key]
		
		for key in array.key:
			number.divide[key] = float(divide_[key]) / float(sum) 

class Sorter:
    static func sort_ascending(a, b):
        if a.value < b.value:
            return true
        return false

    static func sort_descending(a, b):
        if a.value > b.value:
            return true
        return false
