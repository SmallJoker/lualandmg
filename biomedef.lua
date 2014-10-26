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

if yappy.generate_snow then
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
end

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
	temperature_min = 30,
	temperature_max = 36,
	name = "default:junglegrass",
	node_under = "default:dirt_with_grass",
	chance = 8*8
})