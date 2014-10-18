yappy.register_biome({
	temperature_min = 45,
	stone = "default:desert_stone",
	middle = "default:desert_sand",
	cover = "default:desert_sand"
})

yappy.register_biome({
	temperature_min = 38,
	stone = "default:sandstone",
	middle = "default:sand",
	cover = "default:sand"
})

yappy.register_biome({
	temperature_min = 34,
	middle = "default:sand",
})

yappy.register_biome({
	temperature_min = -5
})

yappy.register_biome({
	temperature_min = -10,
	cover = "default:dirt_with_snow"
})

yappy.register_biome({
	temperature_min = -15,
	cover = "default:dirt_with_snow",
	top = "default:snow"
})

yappy.register_biome({
	temperature_min = -100,
	stone = "default:ice",
	middle = "default:snowblock",
	cover = "default:snowblock"
})

yappy.register_tree({
	temperature_min = 36,
	temperature_max = 54,
	chance = 20*20,
	node_under = {"default:sand", "default:desert_sand"},
	action = function(pos, data, area, seed)
		local x, y, z = pos.x, pos.y, pos.z
		for i = 0, math.random(3, 5) do
			data[area:index(x, y + i, z)] = yappy.c_cactus
		end
	end
})

yappy.register_tree({
	temperature_min = 25,
	temperature_max = 35,
	chance = 6*6,
	node_under = "default:dirt_with_grass",
	action = function(pos, data, area, seed)
		default.grow_jungletree(data, area, pos, seed)
	end
})

yappy.register_tree({
	temperature_min = 5,
	temperature_max = 30,
	chance = 12*12,
	node_under = "default:dirt_with_grass",
	action = function(pos, data, area, seed)
		default.grow_tree(data, area, pos, seed % 3 == 0, seed)
	end
})

yappy.register_tree({
	temperature_min = 20,
	temperature_max = 35,
	chance = 20*20,
	node_under = "default:dirt_with_grass",
	action = function(pos, data, area, seed)
		yappy.gen_oak_tree(pos.x, pos.y, pos.z, area, data)
	end
})

yappy.register_tree({
	temperature_min = -15,
	temperature_max = 10,
	chance = 10*10,
	node_under = {"default:dirt_with_grass", "default:dirt_with_snow"},
	action = function(pos, data, area, seed)
		yappy.gen_pine_tree(pos.x, pos.y, pos.z, area, data)
	end
})

yappy.register_decoration({
	temperature_min = 33,
	temperature_max = 36,
	name = "default:junglegrass",
	node_under = "default:dirt_with_grass",
	chance = 8*8
})

for i = 1, 5 do
	yappy.register_decoration({
		temperature_min = 0,
		temperature_max = 34,
		name = "default:grass_"..i,
		node_under = "default:dirt_with_grass",
		chance = 7*7
	})
end

yappy.register_decoration({
	temperature_min = 35,
	temperature_max = 47,
	name = "default:dry_shrub",
	node_under = {"default:dirt_with_grass", "default:sand", "default:desert_sand"},
	chance = 10*10
})