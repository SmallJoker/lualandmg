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

-- original source: https://raw.githubusercontent.com/HeroOfTheWinds/skylands-master/master/functions.lua
function yappy.gen_pine_tree(x, y, z, area, data)
	local c_tree = minetest.get_content_id("default:tree")
	local c_needles = minetest.get_content_id("yappy:pine_needles")
	for h = 1, 11 do
		if h % 3 <= 1 and h > 2 then
			local s = 1
			if h % 3 == 0 then
				s = 2
			end
			for i = -s, s do
			for k = -s, s do
				if not (i == 0 and k == 0) and math.random(20) > 4 then
					data[area:index(x + i, y + h, z + k)] = c_needles
				end
			end
			end
		end
		local middle = c_tree
		if h >= 10 then
			middle = c_needles
		end
		data[area:index(x, y + h, z)] = middle
	end
end

minetest.register_abm({
	nodenames = {"yappy:pine_sapling"},
	interval = 10,
	chance = 10,
	action = function(pos, node)
		local nu = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		if minetest.get_item_group(nu, "soil") == 0 then
			return
		end
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(
			{x=pos.x-4, y=pos.y-4, z=pos.z-4}, 
			{x=pos.x+4, y=pos.y+14, z=pos.z+4})
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local data = vm:get_data()
		yappy.gen_pine_tree(pos.x, pos.y, pos.z, area, data)
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})

minetest.register_abm({
	nodenames = {"yappy:pine_needles"},
	interval = 10,
	chance = 10,
	action = function(pos, node)
		if minetest.find_node_near(pos, 4, {"ignore", "default:tree"}) then return end
		
		local drops = minetest.get_node_drops(node.name)
		for _, dropitem in ipairs(drops) do
			if dropitem ~= node.name then
				minetest.add_item(pos, dropitem)
			end
		end
		minetest.remove_node(pos)
		nodeupdate(pos)
	end
})