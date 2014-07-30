yappy = {}
yappy.mod_path = minetest.get_modpath("yappy")
yappy.scale = 1 --set to 1 for normal
yappy.skip_overgen = true

yappy.ore_chance = 8*8*8
yappy.ore_min_chance = 6*6*6

yappy.np_base = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 5,
	persist = 0.5
}

yappy.np_mountains = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	octaves = 4,
	persist = 0.5
}

yappy.np_trees = {
	offset = 0,
	scale = 1,
	spread = {x=64, y=64, z=64},
	octaves = 3,
	persist = 0.5
}

yappy.np_caves = {
	offset = 0,
	scale = 1,
	spread = {x=24, y=20, z=24},
	octaves = 2,
	persist = 0.5
}

-- A value between: 60.0 and -50.0
yappy.np_temperature = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 2,
	persist = 0.5
}

dofile(yappy.mod_path.."/nodes.lua")

yappy.biomes = { -- 0 = default
	--min temp,		under (stone),	middle (3),				ground (1),				top (1)
	{50,	yappy.c_desert_stone,	yappy.c_desert_sand,	yappy.c_desert_sand,	0},
	{40,	yappy.c_sandstone,		yappy.c_sand,			yappy.c_sand,			0},
	{30,	0,						yappy.c_sand,			0,						0},
	{-5,	0,						0,						0,						0},
	{-15,	0,						0,						yappy.c_dirt_snow,		0},
	{-20,	0,						0,						yappy.c_snowblock,		yappy.c_snow},
	{-99,	yappy.c_ice,			yappy.c_snowblock,		yappy.c_snowblock,		yappy.c_snow},
}
dofile(yappy.mod_path.."/functions.lua")


if yappy.scale ~= 1 then
	yappy.np_base.spread = vector.multiply(yappy.np_base.spread, yappy.scale)
	yappy.np_mountains.spread = vector.multiply(yappy.np_mountains.spread, yappy.scale)
	yappy.np_trees.spread = vector.multiply(yappy.np_trees.spread, yappy.scale)
	yappy.np_caves.spread = vector.multiply(yappy.np_caves.spread, yappy.scale)
	yappy.np_temperature.spread = vector.multiply(yappy.np_temperature.spread, yappy.scale)
end

minetest.register_on_mapgen_init(function(mgparams)
	yappy.np_base.seed = mgparams.seed
	yappy.np_mountains.seed = mgparams.seed + 20
	yappy.np_trees.seed = mgparams.seed - 20
	yappy.np_caves.seed = mgparams.seed + 40
	yappy.np_temperature.seed = mgparams.seed - 40
	minetest.set_mapgen_params({mgname="singlenode"})
end)

local lastPos = {x=6.66,y=6.66,z=6.66}

minetest.register_on_generated(function(minp, maxp, seed)
	if yappy.skip_overgen and vector.equals(minp, lastPos) then
		print("[yappy] Nope.")
		return
	end
	lastPos = vector.new(minp)
	local is_surface = maxp.y > -80
	
	local t1 = os.clock()
	local sidelen = maxp.x - minp.x + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	
	local nvals_base, nvals_mountains, nvals_trees, nvals_temperature
	if is_surface then
		nvals_base = minetest.get_perlin_map(yappy.np_base, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_mountains = minetest.get_perlin_map(yappy.np_mountains, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_trees = minetest.get_perlin_map(yappy.np_trees, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_temperature = minetest.get_perlin_map(yappy.np_temperature, chulens):get2dMap_flat({x=minp.x, y=minp.z})
	end
	
	local nixz = 1
	local surface = {}
	if is_surface then
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local surf = math.abs(nvals_base[nixz] * 25) - 2
			local mt_elev = nvals_mountains[nixz] - 0.2
			local trees = math.abs(nvals_trees[nixz]) - 0.2
			local temp = (nvals_temperature[nixz] + 0.2) * 40
			
			if mt_elev > 0 then
				surf = surf + (mt_elev * 75 * yappy.scale)
			end
			
			trees = trees * trees * 20000 + 10
			if trees < 10 then
				trees = 10
			end
			
			if surf < 0 then
				surf = surf * 2.5
			end
			
			surf = math.floor(surf + 0.5)
			trees = math.floor(trees + 0.5)
			temp = math.floor((temp * 4) + 0.5) / 4
			
			local c_stone = yappy.c_stone
			local c_under = yappy.c_dirt
			local c_above = yappy.c_grass
			local c_top = 0
			
			for _,v in ipairs(yappy.biomes) do
				if temp > v[1] then
					if v[2] ~= 0 then
						c_stone = v[2]
					end
					if v[3] ~= 0 then
						c_under = v[3]
					end
					if v[4] ~= 0 then
						c_above = v[4]
					end
					if v[5] ~= 0 then
						c_top = v[5]
					end
					break
				end
			end
			
			surface[nixz] = {surf, trees, temp,
				c_stone, c_under, c_above, c_top}
			nixz = nixz + 1
		end
		end
		nixz = 1
	end
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local nvals_caves = minetest.get_perlin_map(yappy.np_caves, chulens):get3dMap_flat(minp)
	
	local nixyz = 1
	local real_ore_chance = -1
	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		local vi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
			local surf, trees, temp = 0, 0, 0
			local c_stone = yappy.c_stone
			local c_under, c_above, c_top = 0, 0, 0
			if is_surface then
				local cache = surface[nixz]
				surf = cache[1]
				trees = cache[2]
				temp = cache[3]
				
				c_stone = cache[4]
				c_under = cache[5]
				c_above = cache[6]
				c_top = cache[7]
			end
			local cave = nvals_caves[nixyz]
			if cave > 0.9 and y - surf < -60 then
				--lava cave
				data[vi] = yappy.c_lava
			elseif cave < -0.7 and y - surf < -20 then
				--cave, without lava
			elseif y == surf then
				if y >= 0 then
					if trees > 2 and math.random(trees) == 2 then
						if temp > 35 then
							for i=1, math.random(4, 6) do
								data[area:index(x, y + i, z)] = yappy.c_cactus
							end
							data[vi] = c_under
						elseif temp > 10 then
							default.grow_tree(data, area, vector.new(x, y + 1, z), math.random(20) > 14, trees)
							data[vi] = yappy.c_dirt
						elseif temp > -20 then
							yappy.gen_pine_tree(x, y, z, area, data)
							data[vi] = yappy.c_dirt
						else
							data[vi] = c_above
						end
					elseif data[vi] == yappy.c_air then
						data[vi] = c_above
					end
				else
					data[vi] = c_under
				end
			elseif y == surf + 1 and y > 0 and c_top ~= 0 then
				if data[vi] == yappy.c_air then
					data[vi] = c_top
				end
			elseif y - surf > -3 and y < surf then
				data[vi] = c_under
			elseif y > surf and y <= 0 then
				if temp < -35 then
					data[vi] = yappy.c_ice
				elseif temp < -25 and math.random(20) > 5 then
					data[vi] = yappy.c_ice
				elseif temp < 45 then
					data[vi] = yappy.c_water
				elseif temp == 45 then
					data[vi] = c_under
				end
			elseif y < surf then
				-- calculate ore chance by depth, if not calculated yet
				if real_ore_chance < 0 then
					real_ore_chance = yappy.ore_chance - ((surf - y) / 6)
					real_ore_chance = math.max(math.floor(real_ore_chance), yappy.ore_min_chance)
				end
				
				if math.random(real_ore_chance) == 2 then
					local osel = math.random(50)
					local ore = yappy.c_scoal
					if osel >= 48 then
						ore = yappy.c_sdiamond
					elseif osel >= 45 then
						ore = yappy.c_smese
					elseif osel == 42 then
						ore = yappy.c_sgold
					elseif osel >= 36 then
						ore = yappy.c_scopper
					elseif osel >= 18 then
						ore = yappy.c_siron
					end
					-- spread sphere-like the ores
					yappy.gen_ores(data, area, {x=x, y=y, z=z}, ore)
				elseif data[vi] == yappy.c_air then
					data[vi] = c_stone
				end
			end
			nixyz = nixyz + 1
			nixz = nixz + 1
			vi = vi + 1
		end
		nixz = nixz - sidelen
	end
	nixz = nixz + sidelen
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[yappy] "..minetest.pos_to_string(minp).." - "..chugent.." ms")
	
end)