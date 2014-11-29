minetest.register_ore({
	ore				= "default:stone_with_coal",
	wherein			= "default:stone",
	clust_scarcity	= 8*8*8,
	clust_num_ores	= 7,
	clust_size		= 4,
	height_min		= -31000,
	height_max		= 64,
})

minetest.register_ore({
	ore				= "default:stone_with_iron",
	wherein			= "default:stone",
	clust_scarcity	= 8*8*8,
	clust_num_ores	= 5,
	clust_size		= 4,
	height_min		= -31000,
	height_max		= 64,
})

minetest.register_ore({
	ore				= "default:stone_with_mese",
	wherein			= "default:stone",
	clust_scarcity	= 15*15*15,
	clust_num_ores	= 5,
	clust_size		= 3,
	height_min		= -31000,
	height_max		= -96,
})

minetest.register_ore({
	ore				= "default:mese",
	wherein			= "default:stone",
	clust_scarcity	= 35*35*35,
	clust_num_ores	= 4,
	clust_size		= 2,
	height_min		= -31000,
	height_max		= -1024,
})

minetest.register_ore({
	ore				= "default:stone_with_gold",
	wherein			= "default:stone",
	clust_scarcity	= 14*14*14,
	clust_num_ores	= 5,
	clust_size		= 3,
	height_min		= -31000,
	height_max		= -64,
})

minetest.register_ore({
	ore				= "default:stone_with_diamond",
	wherein			= "default:stone",
	clust_scarcity	= 15*15*15,
	clust_num_ores	= 4,
	clust_size		= 3,
	height_min		= -31000,
	height_max		= -256,
})

minetest.register_ore({
	ore				= "default:stone_with_copper",
	wherein			= "default:stone",
	clust_scarcity	= 10*10*10,
	clust_num_ores	= 6,
	clust_size		= 3,
	height_min		= -31000,
	height_max		= 64,
})

minetest.register_ore({
	ore_type		= "sheet",
	ore				= "default:clay",
	wherein			= "default:sand",
	clust_scarcity	= 15*15*15,
	clust_num_ores	= 4,
	clust_size		= 5,
	height_min		= -10,
	height_max		= 0,
})

minetest.register_ore({
	ore_type		= "sheet",
	ore				= "default:gravel",
	clust_scarcity	= 25*25*25,
	clust_num_ores	= 6,
	clust_size		= 5,
	height_min		= -6000,
	height_max		= -10,
})