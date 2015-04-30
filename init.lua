yappy = {}
yappy.mod_path = minetest.get_modpath("yappy")
yappy.settings_file = minetest.get_worldpath().."/yappy_settings.txt"
yappy.scale				= 1
yappy.terrain_scale		= 1
yappy.details			= 0
yappy.use_mudflow		= true
yappy.tree_chance		= 14*14
yappy.tree_max_chance	= 21*21
yappy.generate_snow		= true

local file = io.open(yappy.settings_file, "r")
if file then
	io.close(file)
	dofile(yappy.settings_file)
end

-- Carbone special
if minetest.setting_getbool("generate_snow") ~= nil then
	yappy.generate_snow = minetest.setting_getbool("generate_snow")
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
	octaves = 1,
	seed = -5432,
	persist = 0.6
}

yappy.np_caves = {
	offset = 0,
	scale = 1,
	spread = {x=32, y=24, z=32},
	octaves = 2,
	seed = -11842,
	persist = 0.7,
	flags = "eased",
	eased = true
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
dofile(yappy.mod_path.."/functions.lua")
dofile(yappy.mod_path.."/treegen.lua")
dofile(yappy.mod_path.."/biomedef.lua")
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

minetest.register_chatcommand("regenerate", {
	description = "Regenerates <size * 8>^3 nodes around you",
	params = "<size * 8>",
	privs = {server=true},
	func = function(name, param)
		local size = tonumber(param) or 1
		
		if size > 8 then
			size = 8 -- Limit: 8*8 -> 64
		elseif size < 1 then
			return false, "Nothing to do."
		end
		
		size = size * 8
		local player = minetest.get_player_by_name(name)
		local pos = vector.floor(vector.divide(player:getpos(), size))
		local minp = vector.multiply(pos, size)
		local maxp = vector.add(minp, size - 1)
		
		yappy.generate(minp, maxp, math.random(0, 9999), true)
		return true, "Done!"
	end
})

function yappy.generate(minp, maxp, seed, regen)
	local is_surface = maxp.y > -80
	
	local t1 = os.clock()
	local sidelen = maxp.x - minp.x + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local mid_chunk = minp.y + (sidelen / 2)
	
	local terrain_scale = yappy.terrain_scale
	local ores = yappy.ores
	local trees = yappy.trees
	local biomes = yappy.biomes
	local decorations = yappy.decorations
	local stones = yappy.stones
	local surface = {}
	local mudflow_check = {}
	
	local nvals_base, nvals_mountains, nvals_trees, nvals_temp
	if is_surface then
		nvals_base = minetest.get_perlin_map(yappy.np_base, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_mountains = minetest.get_perlin_map(yappy.np_mountains, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_trees = minetest.get_perlin_map(yappy.np_trees, chulens):get2dMap_flat({x=minp.x, y=minp.z})
		nvals_temp = minetest.get_perlin_map(yappy.np_temperature, chulens):get2dMap_flat({x=minp.x, y=minp.z})
	end
	
	for i, v in ipairs(ores) do
		if v.height_min <= maxp.y and v.height_max >= minp.y then
			local chance = v.clust_scarcity
			if chance >= 8*8 then
				chance = v.clust_scarcity - ((v.height_max - mid_chunk) / 10)
				chance = math.max(chance, v.clust_scarcity * 0.75)
			end
			v.current_chance = math.floor(chance)
		end
	end
	
	local nixz = 1
	if is_surface then
		for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local surf = nvals_base[nixz] * 20 + 16
			local mt_elev = nvals_mountains[nixz] - 0.2
			local tree_chance = nvals_trees[nixz]
			local temp = (nvals_temp[nixz] + 0.4) * 44
			temp = math.floor((temp * 4) + 0.5) / 4
			local r_temp, tree = temp, 0
			
			if mt_elev > 0 then
				surf = surf + (mt_elev * 75)
			end
			
			if surf < 0 then
				surf = surf * 2.5
			end
			
			surf = math.floor((surf * terrain_scale) + 0.5)
			temp = temp + math.random(-3, 3)
			local c_stone, c_middle, c_cover, c_top
			
			for i, v in ipairs(biomes) do
				if temp > v.temperature_min or i == #biomes then
					c_stone = v.stone
					c_middle = v.middle
					c_cover = v.cover
					c_top = v.top
					break
				end
			end
			
			if c_top == 0 then
				for i, v in ipairs(decorations) do
					if temp >= v.temperature_min and
							temp <= v.temperature_max and
							(v.chance <= 1 or math.random(v.chance) == 1) then
						
						if yappy.is_valid_ground(v.node_under, c_cover) then
							c_top = v.name
							break
						end
					end
				end
			end
			
			local tree_factor = 1
			if tree_chance > 0.4 then
				tree_factor = 0.4
			elseif tree_chance < -0.4 then
				tree_factor = 2
			end
			
			for i, v in ipairs(trees) do
				if temp >= v.temperature_min and
						temp <= v.temperature_max and
						math.random(math.ceil(v.chance * tree_factor)) == 1 then
					
					if yappy.is_valid_ground(v.node_under, c_cover) then
						tree = i + 1
						c_top = 0
						break
					end
				end
			end
			
			surface[nixz] = {surf, tree, r_temp,
					c_stone, c_middle, c_cover, c_top}
			nixz = nixz + 1
		end
		end
		nixz = 1
	end
	
	local vm, emin, emax
	if regen then
		vm = minetest.get_voxel_manip()
		emin, emax = vm:read_from_map(minp, maxp)
	else
		vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	end
	
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	if regen then
		local air = yappy.c_air
		for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			local vi = area:index(minp.x, y, z)
			for x = minp.x, maxp.x do
				data[vi] = air
				vi = vi + 1
			end
		end
		end
	end
	
	local nvals_caves = minetest.get_perlin_map(yappy.np_caves, chulens):get3dMap_flat(minp)
	local nixyz = 1
	
	for z = minp.z, maxp.z do
	for y = minp.y, maxp.y do
		local vi = area:index(minp.x, y, z)
		for x = minp.x, maxp.x do
			local surf, tree, temp = 0, 0, 0
			local c_stone = yappy.c_stone
			local c_middle, c_cover, c_top = 0, 0, 0
			
			if is_surface then
				local cache = surface[nixz]
				surf = cache[1]
				tree = cache[2]
				temp = cache[3]
				
				c_stone = cache[4]
				c_middle = cache[5]
				c_cover = cache[6]
				c_top = cache[7]
			end
			local cave = nvals_caves[nixyz]
			if cave > 1.1 and y < -20 and not (is_surface and temp < 5) then
				-- Cave, filled with lava
				data[vi] = yappy.c_lava
			elseif cave < -0.8 and y <= surf + 1 then
				-- Empty cave
				if is_surface then
					mudflow_check[nixz] = true
				end
			elseif y == surf and y < 0 then
				-- Sea ground
				data[vi] = c_middle
			elseif y == surf then
				if tree > 0 then
					trees[tree - 1].action(vector.new(x, y + 1, z), data, area, seed)
					data[vi] = c_middle
				else
					data[vi] = c_cover
				end
			elseif y == surf + 1 and y > 0 and c_top ~= 0 then
				if data[vi] == yappy.c_air then
					if data[area:index(x, y - 1, z)] == c_cover then
						data[vi] = c_top
					end
				end
			elseif y - surf >= -3 and y < surf then
				data[vi] = c_middle
			elseif y > surf and y <= 0 then
				-- Water
				if temp + math.random(-2, 2) < -18 then
					data[vi] = yappy.c_ice
				elseif temp < 43 then
					data[vi] = yappy.c_water
				elseif temp >= 43 and temp <= 44 then
					data[vi] = c_middle
				end
			elseif y < surf then
				data[vi] = c_stone
			end
			
			if y <= surf then
				local node = data[vi]
				for i, v in ipairs(ores) do
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
							local size = v.clust_size
							if size >= 3 then
								size = size + math.random(2) - 2
							end
							if v.ore_type == "scatter" then
								yappy.gen_ores(data, area, {x=x, y=y, z=z}, v.ore, v.wherein, size)
							elseif v.ore_type == "sheet" then
								yappy.gen_sheet(data, area, {x=x, y=y, z=z}, v.ore, v.wherein, size)
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
				local c_stone, c_middle, c_cover = cache[4], cache[5], cache[6]
				
				-- out of range
				if r_surf - 16 > maxp.y then
					surf = minp.y + 1
				end
				
				-- node at surface got removed
				local max_depth = 5
				local vi, node
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
						data[vi] = c_cover
					else
						data[vi] = c_middle
					end
					vi = area:index(x, ground - 1, z)
					data[vi] = c_middle
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
	if regen then
		vm:set_param2_data({})
	end
	if not regen then
		vm:set_lighting({day=0, night=0})
	end
	vm:calc_lighting()
	vm:write_to_map(data)
	vm:update_liquids()
	if regen then
		vm:update_map()
	end
	minetest.log("action", log_message)
end

table.insert(minetest.registered_on_generateds, 1, yappy.generate)