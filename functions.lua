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