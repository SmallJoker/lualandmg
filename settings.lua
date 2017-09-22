-- Apply defaults
local setting_defaults = {
	noise_spread  = 1,
	terrain_scale = 1,
	tree_chance     = 14*14
}

for k, v in pairs(setting_defaults) do
	lualandmg[k] = tonumber(minetest.setting_get("lualandmg."..k)) or v
end

assert(lualandmg.noise_spread > 0, "LuaLandMG: Setting noise_spread must be > 0")
assert(lualandmg.terrain_scale > 0, "LuaLandMG: Setting terrain_scale must be > 0")
