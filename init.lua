yappy = {}
yappy.mod_path = minetest.get_modpath("yappy")
yappy.settings_file = minetest.get_worldpath().."/yappy_settings.txt"
yappy.scale = 1
yappy.skip_overgen		= true
yappy.caves_everywhere	= true
yappy.use_mudflow		= true
yappy.ore_chance		= 8*8*9
yappy.ore_min_chance	= 5*6*6
yappy.tree_chance		= 16*16
yappy.tree_max_chance	= 21*21
yappy.clay_chance		= 18*18
yappy.gravel_chance		= 20*20*20

local file = io.open(yappy.settings_file, "r")
if file then
	io.close(file)
	dofile(yappy.settings_file)
end

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
	spread = {x=512, y=512, z=512},
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
	{45,	yappy.c_desert_stone,	yappy.c_desert_sand,	yappy.c_desert_sand,	0},
	{38,	yappy.c_sandstone,		yappy.c_sand,			yappy.c_sand,			0},
	{34,	0,						yappy.c_sand,			0,						0},
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
	-- Read world seed
	yappy.np_base.seed = mgparams.seed
	yappy.np_mountains.seed = mgparams.seed + 20
	yappy.np_trees.seed = mgparams.seed - 20
	yappy.np_caves.seed = mgparams.seed + 40
	yappy.np_temperature.seed = mgparams.seed - 40
	if mgparams.mgname ~= "singlenode" then
		minetest.set_mapgen_params({mgname="singlenode"})
	end
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
			local trees = nvals_trees[nixz] + 0.1
			local temp = (nvals_temperature[nixz] + 0.2) * 40
			
			if mt_elev > 0 then
				surf = surf + (mt_elev * 90)
			end
			
			if trees > 0.9 then
				trees = 0.9
			end
			
			if trees > 0.3 then
				trees = yappy.tree_chance - (yappy.tree_chance * trees)
			else
				trees = yappy.tree_max_chance
			end
			
			if surf < 0 then
				surf = surf * 2.5
			end
			
			surf = math.floor((surf * yappy.scale) + 0.5)
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
	local chance_ore = -1
	local chance_clay = yappy.clay_chance
	local chance_gravel = yappy.gravel_chance
	local force_caves = yappy.caves_everywhere
	
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
			if cave > 0.93 and y < -20 then
				-- Cave, filled with lava
				data[vi] = yappy.c_lava
			elseif cave < -0.7 and ((y - surf < -20) or (force_caves and y < surf + 2)) then
				-- Empty cave
			elseif y == surf and y < 0 then
				-- Sea ground
				data[vi] = c_under
			elseif y == surf then
				local placed = false
				if trees > 2 and math.random(trees) == 2 then
					if temp > 39 then
						for i=1, math.random(4, 6) do
							data[area:index(x, y + i, z)] = yappy.c_cactus
						end
						data[vi] = c_under
					else
						local tree_pos = vector.new(x, y + 1, z)
						if temp > 35 then
							default.grow_jungletree(data, area, tree_pos, trees)
							data[vi] = yappy.c_dirt
							placed = true
						elseif temp > 10 then
							if math.random(20) > 2 then
								default.grow_tree(data, area, tree_pos, math.random(20) > 14, trees)
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
			elseif y == surf + 1 and y > 0 then
				if c_top ~= 0 then
					if data[vi] == yappy.c_air then
						data[vi] = c_top
					end
				elseif temp > 35 and temp < 38 and math.random(5*5) == 2 then
					data[vi] = yappy.c_jgrass
				end
			elseif y - surf >= -3 and y < surf then
				data[vi] = c_under
			elseif y > surf and y <= 0 then
				-- Water
				if temp < -35 then
					data[vi] = yappy.c_ice
				elseif temp < -25 and math.random(20) > 5 then
					data[vi] = yappy.c_ice
				elseif temp < 45 then
					data[vi] = yappy.c_water
					if y == surf + 1 and math.random(chance_clay) == 2 then
						yappy.gen_sheet(data, area, {x=x, y=y, z=z}, yappy.c_clay, yappy.c_sand)
					end
				elseif temp == 45 then
					data[vi] = c_under
				end
			elseif y < surf then
				-- calculate ore chance by depth, if not calculated yet
				if chance_ore < 0 then
					chance_ore = yappy.ore_chance - ((surf - y) / 7)
					chance_ore = math.max(math.floor(chance_ore), yappy.ore_min_chance)
				end
				
				if math.random(chance_ore) == 2 then
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
					if math.random(chance_gravel) == 2 then
						yappy.gen_sheet(data, area, {x=x, y=y, z=z}, yappy.c_gravel)
					else
						data[vi] = c_stone
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
	
	if yappy.use_mudflow and is_surface then
		nixz = 1
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local cache = surface[nixz]
			local surf, c_stone, c_under, c_above = cache[1], cache[4], cache[5], cache[6]
			
			-- out of range
			if surf - 16 > maxp.y then
				surf = minp.y + 1
			end
			
			-- node at surface got removed
			local vi = area:index(x, surf, z)
			local node = data[vi]
			--if node == c_above or node == c_under then
			--	surf = minp.y + 1
			--end
			
			local max_depth = 4
			local ground, depth = 6.66, 0
			local covered = false
			for y = surf, minp.y + 1, -1 do
				vi = area:index(x, y, z)
				node = data[vi]
				local is_air = (node == yappy.c_air)
				
				if node == yappy.c_water then
					break
				end
				
				if depth >= max_depth then
					ground = y + max_depth
					break
				end
				
				if is_air then
					if depth > 0 then
						covered = true
						data[vi] = c_stone
					end
					depth = 0
				else
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
			nixz = nixz + 1
		end
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	if force_caves then
		-- Let water flow into the caves
		vm:update_liquids()
	end
	
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[yappy] "..minetest.pos_to_string(minp).." - "..chugent.." ms")
	
end)