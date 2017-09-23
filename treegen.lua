local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_oak_tree   = minetest.get_content_id("lualandmg:oak_trunk")
local c_oak_leaves = minetest.get_content_id("lualandmg:oak_leaves")

local c_pine_tree    = minetest.get_content_id("default:pine_tree")
local c_pine_needles = minetest.get_content_id("default:pine_needles")
	
local c_jungletree   = minetest.get_content_id("default:jungletree")
local c_jungleleaves = minetest.get_content_id("default:jungleleaves")

local c_tree   = minetest.get_content_id("default:tree")
local c_leaves = minetest.get_content_id("default:leaves")
local c_apple  = minetest.get_content_id("default:apple")

function lualandmg.gen_oak_tree(x, y, z, area, data)
	local node
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
					node = data[vil]
					if sum ~= s and sum == (h - 4) and math.random(4) > 1 then
						if node == c_air or node == c_ignore then
							data[vil] = c_oak_tree
						end
					elseif math.random(6) > 1 then
						if node == c_air or node == c_ignore then
							data[vil] = c_oak_leaves
						end
					end
				end
				vil = vil + 1
			end
		end
		local middle = c_oak_tree
		if h >= 9 then
			middle = c_oak_leaves
		end
		local vil = area:index(x, y + h, z)
		node = data[vil]
		if node == c_air or node == c_ignore then
			data[vil] = middle
		end
	end
end

-- original source: https://raw.githubusercontent.com/HeroOfTheWinds/skylands-master/master/functions.lua
function lualandmg.gen_pine_tree(x, y, z, area, data)
	local node
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
						node = data[vil]
						if node == c_air or node == c_ignore then
							data[vil] = c_pine_needles
						end
					end
					vil = vil + 1
				end
			end
		end
		local middle = c_pine_tree
		if h >= 10 then
			middle = c_pine_needles
		end
		local vil = area:index(x, y + h, z)
		node = data[vil]
		if node == c_air or node == c_ignore then
			data[vil] = middle
		end
	end
end

-- default tree generation code from minetest_game
function lualandmg.grow_tree(x, y, z, area, data, is_apple_tree, seed)
	local pr = PseudoRandom(seed)
	local th = pr:next(4, 6)
	for yy = y, y+th-1 do
		local vi = area:index(x, yy, z)
		if area:contains(x, yy, z) and (data[vi] == c_air or yy == y) then
			data[vi] = c_tree
		end
	end
	y = y+th-1 -- (x, y, z) is now last piece of trunk
	local leaves_a = VoxelArea:new{MinEdge={x=-2, y=-1, z=-2}, MaxEdge={x=2, y=2, z=2}}
	local leaves_buffer = {}
	
	-- Force leaves near the trunk
	local d = 1
	for xi = -d, d do
	for yi = -d, d do
	for zi = -d, d do
		leaves_buffer[leaves_a:index(xi, yi, zi)] = true
	end
	end
	end
	
	-- Add leaves randomly
	for iii = 1, 8 do
		local d = 1
		local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
		local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
		local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)
		
		for xi = 0, d do
		for yi = 0, d do
		for zi = 0, d do
			leaves_buffer[leaves_a:index(xx+xi, yy+yi, zz+zi)] = true
		end
		end
		end
	end
	
	-- Add the leaves
	for xi = leaves_a.MinEdge.x, leaves_a.MaxEdge.x do
	for yi = leaves_a.MinEdge.y, leaves_a.MaxEdge.y do
	for zi = leaves_a.MinEdge.z, leaves_a.MaxEdge.z do
		if area:contains(x+xi, y+yi, z+zi) then
			local vi = area:index(x+xi, y+yi, z+zi)
			if data[vi] == c_air or data[vi] == c_ignore then
				if leaves_buffer[leaves_a:index(xi, yi, zi)] then
					if is_apple_tree and pr:next(1, 100) <=  10 then
						data[vi] = c_apple
					else
						data[vi] = c_leaves
					end
				end
			end
		end
	end
	end
	end
end

-- default jungle tree generation code from minetest_game
function lualandmg.grow_jungletree(x, y, z, area, data, seed)
	local pr = PseudoRandom(seed)
	for xi = -1, 1 do
	for zi = -1, 1 do
		if pr:next(1, 3) >= 2 then
			local vi1 = area:index(x+xi, y, z+zi)
			local vi2 = area:index(x+xi, y-1, z+zi)
			if area:contains(x+xi, y-1, z+zi) and data[vi2] == c_air then
				data[vi2] = c_jungletree
			elseif area:contains(x+xi, y, z+zi) and data[vi1] == c_air then
				data[vi1] = c_jungletree
			end
		end
	end
	end
	
	local th = pr:next(6, 12)
	for yy = y, y+th-1 do
		local vi = area:index(x, yy, z)
		if area:contains(x, yy, z) and (data[vi] == c_air or yy == y) then
			data[vi] = c_jungletree
		end
	end
	y = y + th - 1 -- (x, y, z) is now last piece of trunk
	local leaves_a = VoxelArea:new{MinEdge={x=-3, y=-2, z=-3}, MaxEdge={x=3, y=2, z=3}}
	local leaves_buffer = {}
	
	-- Force leaves near the trunk
	local d = 1
	for xi = -d, d do
	for yi = -d, d do
	for zi = -d, d do
		leaves_buffer[leaves_a:index(xi, yi, zi)] = true
	end
	end
	end
	
	-- Add leaves randomly
	for iii = 1, 30 do
		local d = 1
		local xx = pr:next(leaves_a.MinEdge.x, leaves_a.MaxEdge.x - d)
		local yy = pr:next(leaves_a.MinEdge.y, leaves_a.MaxEdge.y - d)
		local zz = pr:next(leaves_a.MinEdge.z, leaves_a.MaxEdge.z - d)
		
		for xi = 0, d do
		for yi = 0, d do
		for zi = 0, d do
			leaves_buffer[leaves_a:index(xx+xi, yy+yi, zz+zi)] = true
		end
		end
		end
	end
	
	-- Add the leaves
	for xi = leaves_a.MinEdge.x, leaves_a.MaxEdge.x do
	for yi = leaves_a.MinEdge.y, leaves_a.MaxEdge.y do
	for zi = leaves_a.MinEdge.z, leaves_a.MaxEdge.z do
		if area:contains(x+xi, y+yi, z+zi) then
			local vi = area:index(x+xi, y+yi, z+zi)
			if data[vi] == c_air or data[vi] == c_ignore then
				if leaves_buffer[leaves_a:index(xi, yi, zi)] then
					data[vi] = c_jungleleaves
				end
			end
		end
	end
	end
	end
end
