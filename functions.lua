yappy.stones = {}
yappy.stones[yappy.c_stone] = true

for _,v in ipairs(yappy.biomes) do
	if v[2] ~= 0 then
		yappy.stones[v[2]] = true
	end
end

function yappy.gen_ores(data, area, pos, node)
	local lim = math.random(3, 16)
	if math.random(3) == 2 then
		lim = math.floor(lim * 1.6)
	end
	
	for z = -2, 2 do
	for y = 0, 4 do
		local vil = area:index(pos.x - 2, pos.y - y, pos.z + z)
		for x = -2, 2 do
			if x == 0 and y == 0 and z == 0 then
				data[vil] = node
			else
				local found = false
				for k,v in pairs(yappy.stones) do
					if k == data[vil] then
						found = true
						break
					end
				end
				if found then
					if (math.abs(x) + 1) * (math.abs(y - 2) + 1) * (math.abs(z) + 1) <= lim and math.random(3) == 2 then
						data[vil] = node
					end
				end
			end
			vil = vil + 1
		end
	end
	end
end

function yappy.gen_sheet(data, area, pos, node, replace)
	local len1 = math.random(1, 3)
	local len2 = math.random(1, 3)
	local depth = math.random(1, 3)
	
	for z = -len2, len2 do
	for y = 0, depth do
		local vil = area:index(pos.x - len1, pos.y - y, pos.z + z)
		for x = -len1, len1 do
			local valid = true
			if replace then
				if data[vil] ~= replace then
					valid = false
				end
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
	local c_tree = minetest.get_content_id("default:tree")
	local c_leaves = minetest.get_content_id("yappy:oak_leaves")
	for h = 1, 10 do
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
	local c_tree = minetest.get_content_id("default:tree")
	local c_needles = minetest.get_content_id("yappy:pine_needles")
	for h = 1, 11 do
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

minetest.register_abm({
	nodenames = {"yappy:pine_sapling"},
	interval = 40,
	chance = 40,
	action = function(pos, node)
		local nu = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		if minetest.get_item_group(nu, "soil") == 0 then
			return
		end
		minetest.remove_node(pos)
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(
			{x=pos.x-4, y=pos.y-1, z=pos.z-4}, 
			{x=pos.x+4, y=pos.y+14, z=pos.z+4})
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		yappy.gen_pine_tree(pos.x, pos.y - 1, pos.z, area, data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})

minetest.register_abm({
	nodenames = {"yappy:oak_sapling"},
	interval = 40,
	chance = 40,
	action = function(pos, node)
		local nu = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		if minetest.get_item_group(nu, "soil") == 0 then
			return
		end
		minetest.remove_node(pos)
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(
			{x=pos.x-6, y=pos.y-1, z=pos.z-6}, 
			{x=pos.x+6, y=pos.y+14, z=pos.z+6})
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		yappy.gen_oak_tree(pos.x, pos.y - 1, pos.z, area, data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})