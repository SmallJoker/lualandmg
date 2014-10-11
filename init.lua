yappy = {}
yappy.mod_path = minetest.get_modpath("yappy")
yappy.settings_file = minetest.get_worldpath().."/yappy_settings.txt"
yappy.ores_table = {}
yappy.scale				= 1
yappy.terrain_scale		= 1
yappy.details			= 0
yappy.use_mudflow		= true
yappy.tree_chance		= 14*14
yappy.tree_max_chance	= 21*21

local file = io.open(yappy.settings_file, "r")
if file then
	io.close(file)
	dofile(yappy.settings_file)
end

yappy.np_base = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	octaves = 4,
	seed = 42692,
	persist = 0.5
}

yappy.np_mountains = {
	offset = 0,
	scale = 1,
	spread = {x=192, y=192, z=192},
	octaves = 4,
	seed = 3853,
	persist = 0.5
}

yappy.np_trees = {
	offset = 0,
	scale = 1,
	spread = {x=64, y=64, z=64},
	octaves = 2,
	seed = -5432,
	persist = 0.6
}

yappy.np_caves = {
	offset = 0,
	scale = 1,
	spread = {x=32, y=24, z=32},
	octaves = 2,
	seed = -11842,
	persist = 0.7
}

-- A value between: 60.0 and -50.0
yappy.np_temperature = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=512, z=512},
	octaves = 2,
	seed = 921498,
	persist = 0.5
}

dofile(yappy.mod_path.."/nodes.lua")

yappy.biomes = { -- 0 = default
	--min temp,		under (stone),	middle (3),				ground (1),				top (1)
	{45,	yappy.c_desert_stone,	yappy.c_desert_sand,	yappy.c_desert_sand,	0},
	{38,	yappy.c_sandstone,		yappy.c_sand,			yappy.c_sand,			0},
	{34,	0,						yappy.c_sand,			0,						0},
	{-5,	0,						0,						0,						0},
	{-15,	0,						0,						yappy.c_dirt_snow,		0},
	{-20,	0,						0,						yappy.c_snowblock,		yappy.c_snow},
	{-99,	yappy.c_ice,			yappy.c_snowblock,		yappy.c_snowblock,		yappy.c_snow},
}
dofile(yappy.mod_path.."/functions.lua")
dofile(yappy.mod_path.."/default_mapgen.lua")

local np_list = {"np_base", "np_mountains", "np_trees", "np_temperature"}
if yappy.scale ~= 1 then
	for _,v in ipairs(np_list) do
		yappy[v].spread = vector.multiply(yappy[v].spread, yappy.scale)
	end
end
if yappy.details ~= 0 then
	for _,v in ipairs(np_list) do
		if v ~= "np_temperature" and v ~= "np_trees" then
			yappy[v].octaves = yappy[v].octaves + yappy.details
		end
	end
end

minetest.register_on_mapgen_init(function(mgparams)
	if mgparams.mgname ~= "singlenode" then
		print("[yappy] Set mapgen to singlenode")
		minetest.set_mapgen_params({mgname="singlenode"})
	end
end)

minetest.register_on_generated(function(minp, maxp, seed)
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
	local terrain_scale = yappy.terrain_scale
	
	if is_surface then
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local surf = nvals_base[nixz] * 20 + 16
			local mt_elev = nvals_mountains[nixz] - 0.2
			local trees = nvals_trees[nixz] + 0.4
			local temp = (nvals_temperature[nixz] + 0.3) * 38
			
			if mt_elev > 0 then
				surf = surf + (mt_elev * 75)
			end
			
			if trees > 0.85 then
				trees = 0.85
			end
			
			if trees > 0.6 then
				trees = yappy.tree_chance - (yappy.tree_chance * trees)
			else
				trees = yappy.tree_max_chance
			end
			
			if surf < 0 then
				surf = surf * 2.5
			end
			
			surf = math.floor((surf * terrain_scale) + 0.5)
			trees = math.floor(trees + 0.5)
			temp = math.floor((temp * 4) + 0.5) / 4
			
			local c_stone = yappy.c_stone
			local c_under = yappy.c_dirt
			local c_above = yappy.c_grass
			local c_top = 0
			local noise = math.random(-3, 3)
			
			for _,v in ipairs(yappy.biomes) do
				if temp + noise > v[1] then
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
			
			local rand = math.random(5*5)
			if temp > 33 and temp < 36 and rand == 2 then
				c_top = yappy.c_jgrass
			elseif temp > 0 and temp < 35 and rand == 3 then
				c_top = yappy["grass_"..math.random(5)]
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
	local mid_chunk = minp.y + (sidelen / 2)
	local ores_table = yappy.ores_table
	local mudflow_check = {}
	
	for i, v in ipairs(ores_table) do
		if v.height_min <= maxp.y and v.height_max >= minp.y then
			local chance = v.clust_scarcity
			if chance >= 8*8 then
				chance = v.clust_scarcity - ((v.height_max - mid_chunk) / 10)
				chance = math.max(chance, v.clust_scarcity * 0.75)
			end
			v.current_chance = math.floor(chance)
		end
	end
	
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
			if cave > 0.93 and y < -20 and not (is_surface and temp < 5) then
				-- Cave, filled with lava
				data[vi] = yappy.c_lava
			elseif cave < -0.7 and y <= surf + 1 then
				-- Empty cave
				if is_surface then
					mudflow_check[nixz] = true
				end
			elseif y == surf and y < 0 then
				-- Sea ground
				data[vi] = c_under
			elseif y == surf then
				local placed = false
				if trees > 2 and math.random(trees) == 2 then
					if temp > 39 then
						if trees % 2 == 0 then
							for i = 1, math.random(4, 6) do
								data[area:index(x, y + i, z)] = yappy.c_cactus
							end
							data[vi] = yappy.c_desert_sand
							placed = true
						end
					elseif x + 4 < maxp.x and 
							x - 4 > minp.x and 
							y + 10 < maxp.y and 
							z + 4 < maxp.z and 
							z - 4 > minp.z then
						local tree_pos = vector.new(x, y + 1, z)
						if temp > 32 then
							default.grow_jungletree(data, area, tree_pos, trees)
							data[vi] = yappy.c_dirt
							placed = true
						elseif temp > 0 then
							local rand = math.random(20)
							if rand > 2 then
								default.grow_tree(data, area, tree_pos, rand % 3 == 0, trees)
							else
								yappy.gen_oak_tree(x, y, z, area, data)
							end
							data[vi] = yappy.c_dirt
							placed = true
						elseif temp > -20 then
							yappy.gen_pine_tree(x, y, z, area, data)
							data[vi] = yappy.c_dirt
							placed = true
						end
					end
				end
				if not placed then
					data[vi] = c_above
				end
			elseif y == surf + 1 and y > 0 and c_top ~= 0 then
				if data[vi] == yappy.c_air then
					if data[area:index(x, y - 1, z)] == c_above then
						data[vi] = c_top
					end
				end
			elseif y - surf >= -3 and y < surf then
				data[vi] = c_under
			elseif y > surf and y <= 0 then
				-- Water
				if temp + math.random(-2, 2) < -18 then
					data[vi] = yappy.c_ice
				elseif temp < 43 then
					data[vi] = yappy.c_water
				elseif temp >= 43 and temp <= 44 then
					data[vi] = c_under
				end
			elseif y < surf then
				data[vi] = c_stone
			end
			
			if y <= surf then
				local node = data[vi]
				local stones = yappy.stones
				for i, v in ipairs(ores_table) do
					if v.height_min <= y and v.height_max >= y then
						local valid = (math.random(v.current_chance) == 1)
						if valid then
							if v.wherein == -1 then
								valid = stones[node]
							elseif v.wherein ~= -2 then
								valid = (node == v.wherein)
							end
						end
						if valid and v.current_chance < 10 then
							data[vi] = v.ore
							break
						end
						if valid then
							if v.ore_type == "scatter" then
								yappy.gen_ores(data, area, {x=x, y=y, z=z}, v.ore, v.wherein, v.clust_size)
							elseif v.ore_type == "sheet" then
								yappy.gen_sheet(data, area, {x=x, y=y, z=z}, v.ore, v.wherein, v.clust_size)
							end
							break
						end
					end
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
	
	local t2 = os.clock()
	local log_message = (minetest.pos_to_string(minp).." generated in "..
			math.ceil((t2 - t1) * 1000).." ms")
	
	if yappy.use_mudflow and is_surface then
		nixz = 1
		local height = 2
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			if mudflow_check[nixz] then
				local cache = surface[nixz]
				local r_surf = cache[1]
				local surf = r_surf + height
				local c_stone, c_under, c_above =  cache[4], cache[5], cache[6]
				
				-- out of range
				if r_surf - 16 > maxp.y then
					surf = minp.y + 1
				end
				
				-- node at surface got removed
				local max_depth = 5
				local ground, depth = 6.66, 0
				local covered, water = false, false
				for y = surf, minp.y + 1, -1 do
					vi = area:index(x, y, z)
					node = data[vi]
					local is_air = (node == yappy.c_air)
					
					if node == yappy.c_water then
						water = true
					end
					
					if depth >= max_depth then
						ground = y + max_depth
						break
					end
					
					if is_air then
						if water then
							data[vi] = yappy.c_water
						elseif depth > 0 then
							covered = true
							data[vi] = c_stone
						end
						depth = 0
					elseif y <= r_surf then
						depth = depth + 1
					end
				end
				
				if ground ~= 6.66 and ground ~= surf then
					vi = area:index(x, ground, z)
					if ground >= 0 and not covered then
						data[vi] = c_above
					else
						data[vi] = c_under
					end
					vi = area:index(x, ground - 1, z)
					data[vi] = c_under
				end
			end
			nixz = nixz + 1
		end
		end
		
		local td = math.ceil((os.clock() - t2) * 1000)
		if td > 0 then
			log_message = log_message..", mudflow in "..td.."ms"
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()
	minetest.log("action", log_message)
end)