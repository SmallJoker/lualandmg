yappy.stones = {}
yappy.ores = {}
yappy.trees = {}
yappy.biomes = {}
yappy.decorations = {}

minetest.after(1, function()
	for i, v in ipairs(yappy.biomes) do
		yappy.stones[v.stone] = true
	end
	table.sort(yappy.biomes, function(a, b)
		return a.temperature_min > b.temperature_min
	end)
	
	minetest.log("action", "yappy mapgen inited with "..
			#yappy.ores.." ores, "..
			#yappy.trees.." trees, "..
			#yappy.biomes.." biomes and "..
			#yappy.decorations.." decorations")
end)

function yappy.register_tree(treedef)
	treedef.node_under = yappy.get_content_id(treedef.node_under)
	table.insert(yappy.trees, treedef)
end

function yappy.register_biome(biomedef)
	biomedef.stone = biomedef.stone or "default:stone"
	biomedef.middle = biomedef.middle or "default:dirt"
	biomedef.cover = biomedef.cover or "default:dirt_with_grass"
	biomedef.top = biomedef.top or 0 --snow?
	
	biomedef.stone = minetest.get_content_id(biomedef.stone)
	biomedef.middle = minetest.get_content_id(biomedef.middle)
	biomedef.cover = minetest.get_content_id(biomedef.cover)
	if biomedef.top ~= 0 then
		biomedef.top = minetest.get_content_id(biomedef.top)
	end
	table.insert(yappy.biomes, biomedef)
end

function yappy.register_decoration(decodef)
	decodef.name = minetest.get_content_id(decodef.name)
	decodef.node_under = yappy.get_content_id(decodef.node_under)
	table.insert(yappy.decorations, decodef)
end

function yappy.get_content_id(t)
	local n = 0
	if type(t) == "table" then
		n = {}
		for i, v in ipairs(t) do
			n[i] = minetest.get_content_id(v)
		end
	else
		n = minetest.get_content_id(t)
	end
	return n
end

function yappy.is_valid_ground(t, c)
	if type(t) == "table" then
		for i, v in ipairs(t) do
			if v == c then
				return true
			end
		end
	else
		return t == c
	end
	return false
end

function minetest.register_ore(oredef)
	if not oredef.ore_type then
		oredef.ore_type = "scatter"
	end
	if oredef.ore_type == "sheet" then
		oredef.clust_size = oredef.clust_size / 2
	end
	oredef.clust_size = math.ceil((oredef.clust_size + oredef.clust_num_ores) / 3)
	if oredef.clust_size > 3 then
		oredef.clust_size = 3
	end
	
	if oredef.clust_scarcity > 1 and oredef.clust_size > 1 then
		oredef.clust_scarcity = oredef.clust_scarcity * oredef.clust_size * 2
	end
	oredef.clust_scarcity = math.ceil(oredef.clust_scarcity)
	
	if not oredef.wherein then
		oredef.wherein = -2
	elseif oredef.wherein == "default:stone" then
		oredef.wherein = -1
	else
		oredef.wherein = minetest.get_content_id(oredef.wherein)
	end
	
	oredef.ore = minetest.get_content_id(oredef.ore)
	
	table.insert(yappy.ores, oredef)
end

function yappy.gen_ores(data, area, pos, node, wherein, size)
	local noise = math.random(5, 8) / 10
	local len1 = size + math.random(-1, 1)
	local len2 = size + math.random(-1, 1)
	local depth = size + math.random(-1, 1)
	local lim = len1 * len2 * depth * noise
	
	for z = -len2, len2 do
	for y = 0, depth * 2 do
		local vil = area:index(pos.x - len1, pos.y - y, pos.z + z)
		for x = -len1, len1 do
			if x == 0 and y == 0 and z == 0 then
				data[vil] = node
			elseif math.random(3) == 2 then
				local valid = true
				if wherein == -1 then
					valid = yappy.stones[data[vil]]
				elseif wherein ~= -2 then
					valid = (data[vil] == wherein)
				end
				if valid then
					if (math.abs(x) + 1) * (math.abs(y - depth) + 1) * (math.abs(z) + 1) <= lim then
						data[vil] = node
					end
				end
			end
			vil = vil + 1
		end
	end
	end
end

function yappy.gen_sheet(data, area, pos, node, wherein, size)
	local len1 = size + math.random(-1, 1)
	local len2 = size + math.random(-1, 1)
	local depth = size + math.random(-1, 1)
	
	for z = -len2, len2 do
	for y = 0, depth do
		local vil = area:index(pos.x - len1, pos.y - y, pos.z + z)
		for x = -len1, len1 do
			local valid = true
			if wherein == -1 then
				valid = yappy.stones[data[vil]]
			elseif wherein ~= -2 then
				valid = (data[vil] == wherein)
			end
			if valid then
				data[vil] = node
			end
			vil = vil + 1
		end
	end
	end
end

function yappy.gen_oak_tree(x, y, z, area, data)
	local c_air = minetest.get_content_id("air")
	local c_tree = minetest.get_content_id("yappy:oak_trunk")
	local c_leaves = minetest.get_content_id("yappy:oak_leaves")
	for h = 0, 10 do
		local s = 0
		if h == 3 then
			s = h * 0.6
		elseif h > 3 then
			s = (12 - h) * 0.6
		end
		s = math.floor(s + 0.5)
		for i = -s, s do
			local vil = area:index(x - s, y + h, z + i)
			for k = -s, s do
				local sum = math.abs(i) + math.abs(k)
				if sum <= s and sum ~= 0 then
					if sum ~= s and sum == (h - 4) and math.random(4) > 1 then
						if data[vil] == c_air then
							data[vil] = c_tree
						end
					elseif math.random(6) > 1 then
						if data[vil] == c_air then
							data[vil] = c_leaves
						end
					end
				end
				vil = vil + 1
			end
		end
		local middle = c_tree
		if h >= 9 then
			middle = c_leaves
		end
		local vil = area:index(x, y + h, z)
		if data[vil] == c_air then
			data[vil] = middle
		end
	end
end

-- original source: https://raw.githubusercontent.com/HeroOfTheWinds/skylands-master/master/functions.lua
function yappy.gen_pine_tree(x, y, z, area, data)
	local c_air = minetest.get_content_id("air")
	local c_tree = minetest.get_content_id("yappy:pine_trunk")
	local c_needles = minetest.get_content_id("yappy:pine_needles")
	for h = 0, 11 do
		if h % 3 <= 1 and h > 2 then
			local s = 1
			if h % 3 == 0 then
				s = 2
			end
			for i = -s, s do
				local vil = area:index(x - s, y + h, z + i)
				for k = -s, s do
					if not (i == 0 and k == 0) and math.random(10) > 2 then
						if data[vil] == c_air then
							data[vil] = c_needles
						end
					end
					vil = vil + 1
				end
			end
		end
		local middle = c_tree
		if h >= 10 then
			middle = c_needles
		end
		local vil = area:index(x, y + h, z)
		if data[vil] == c_air then
			data[vil] = middle
		end
	end
end
