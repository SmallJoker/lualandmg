-- BIOME: Desert
lualandmg.register_biome({
	temperature_min = 45,
	stone = "default:desert_stone",
	middle = "default:desert_sand",
	top = "default:desert_sand"
})

lualandmg.register_biome({
	temperature_min = 40,
	stone = "default:sandstone",
	middle = "default:sand",
	top = "default:sand"
})

lualandmg.register_decoration({
	temperature_max = 45,
	temperature_min = 30,
	name = "default:dry_shrub",
	node_under = "default:sand",
	chance = 10*10
})

local c_cactus = minetest.get_content_id("default:cactus")
lualandmg.register_tree({
	temperature_max = 50,
	temperature_min = 30,
	chance = 20*20,
	node_under = {"default:sand", "default:desert_sand"},
	action = function(pos, vm, data, area, seed)
		local x, z = pos.x, pos.z
		local height = math.random(3, 4)
		for y = pos.y, pos.y + height do
			data[area:index(x, y, z)] = c_cactus
		end
	end
})

-- BIOME: Hot grasslands
lualandmg.register_biome({
	temperature_min = 34,
	middle = "default:sand",
	top = "default:dirt_with_dry_grass"
})

lualandmg.register_tree({
	temperature_max = 40,
	temperature_min = 27,
	chance = 6*6,
	node_under = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
	action = function(pos, vm, data, area, seed)
		lualandmg.grow_jungletree(pos.x, pos.y, pos.z, area, data, seed)
	end
})

lualandmg.register_decoration({
	temperature_max = 40,
	temperature_min = 35,
	name = "default:dry_grass_2",
	node_under = {"default:dirt_with_grass", "default:dirt_with_dry_grass"},
	chance = 7*7
})

lualandmg.register_decoration({
	temperature_max = 35,
	temperature_min = 28,
	name = "default:junglegrass",
	node_under = "default:dirt_with_grass",
	chance = 4*4
})

-- BIOME: Regular grasslands
lualandmg.register_biome({
	temperature_min = -5
})

lualandmg.register_tree({
	temperature_max = 35,
	temperature_min = 20,
	chance = 20*20,
	node_under = "default:dirt_with_grass",
	action = function(pos, vm, data, area, seed)
		lualandmg.gen_oak_tree(pos.x, pos.y, pos.z, area, data)
	end
})

lualandmg.register_tree({
	temperature_max = 36,
	temperature_min = 10,
	chance = 12*12,
	node_under = "default:dirt_with_grass",
	action = function(pos, vm, data, area, seed)
		lualandmg.grow_tree(pos.x, pos.y, pos.z, area, data, seed % 3 == 0, seed)
	end
})

lualandmg.register_decoration({
	temperature_max = 30,
	temperature_min = -5,
	name = "default:grass_3",
	node_under = "default:dirt_with_grass",
	chance = 6*6
})

lualandmg.register_tree({
	temperature_max = 10,
	temperature_min = -10,
	chance = 10*10,
	node_under = {"default:dirt_with_grass", "default:dirt_with_snow"},
	action = function(pos, vm, data, area, seed)
		lualandmg.gen_pine_tree(pos.x, pos.y, pos.z, area, data)
	end
})

-- BIOME: Snowy
lualandmg.register_biome({
	temperature_min = -15,
	top = "default:dirt_with_snow"
})

-- BIOME: Cold and somewhat cold
lualandmg.register_biome({
	temperature_min = -25,
	top = "default:dirt_with_snow",
	cover = "default:snow"
})

lualandmg.register_biome({
	temperature_min = -100,
	stone = "default:ice",
	middle = "default:snowblock",
	top = "default:snowblock"
})