
lualandmg.registered_trees = {}
lualandmg.registered_biomes = {}
lualandmg.registered_decorations = {}

minetest.after(1, function()
	table.sort(lualandmg.registered_biomes, function(a, b)
		return a.temperature_min > b.temperature_min
	end)

	minetest.log("action", "LuaLandMG loaded with "..
		#minetest.registered_ores.." ores, "..
		#lualandmg.registered_trees.." trees, "..
		#lualandmg.registered_biomes.." biomes and "..
		#lualandmg.registered_decorations.." decorations")
end)

function vector.floor(v)
	return {
		x = math.floor(v.x),
		y = math.floor(v.y),
		z = math.floor(v.z)
	}
end

function lualandmg.get_content_id(t)
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

function lualandmg.register_tree(def)
	def.node_under = lualandmg.get_content_id(def.node_under)
	table.insert(lualandmg.registered_trees, def)
end

function lualandmg.register_biome(def)
	def.stone  = def.stone  or "default:stone"
	def.middle = def.middle or "default:dirt"
	def.top    = def.top    or "default:dirt_with_grass"

	def.stone  = minetest.get_content_id(def.stone)
	def.middle = minetest.get_content_id(def.middle)
	def.top    = minetest.get_content_id(def.top)
	def.cover  = def.cover and minetest.get_content_id(def.cover)
	table.insert(lualandmg.registered_biomes, def)
end

function lualandmg.register_decoration(def)
	def.name       = minetest.get_content_id(def.name)
	def.node_under = lualandmg.get_content_id(def.node_under)
	table.insert(lualandmg.registered_decorations, def)
end

function lualandmg.is_valid_ground(t, c)
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

-- Perhaps for latter use
function lualandmg.adapt_biomes()
	lualandmg.registered_biomes = table.copy(minetest.registered_biomes)

	for i, v in pairs(lualandmg.registered_biomes) do
		v.node_dust = minetest.get_content_id(v.node_dust)
		v.node_top = minetest.get_content_id(v.node_top)
		v.node_filler = minetest.get_content_id(v.node_filler)
		v.node_stone = minetest.get_content_id(v.node_stone)
	end
end