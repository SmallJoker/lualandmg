yappy.c_air		=	minetest.get_content_id("air")
yappy.c_grass	=	minetest.get_content_id("default:dirt_with_grass")
yappy.c_dirt	=	minetest.get_content_id("default:dirt")
yappy.c_gravel	=	minetest.get_content_id("default:gravel")
yappy.c_stone	=	minetest.get_content_id("default:stone")
yappy.c_water	=	minetest.get_content_id("default:water_source")
yappy.c_lava	=	minetest.get_content_id("default:lava_source")
yappy.c_clay	=	minetest.get_content_id("default:clay")
yappy.c_jgrass	=	minetest.get_content_id("default:junglegrass")

yappy.c_sdiamond	=	minetest.get_content_id("default:stone_with_diamond")
yappy.c_smese		=	minetest.get_content_id("default:stone_with_mese")
yappy.c_sgold		=	minetest.get_content_id("default:stone_with_gold")
yappy.c_scopper		=	minetest.get_content_id("default:stone_with_copper")
yappy.c_siron		=	minetest.get_content_id("default:stone_with_iron")
yappy.c_scoal		=	minetest.get_content_id("default:stone_with_coal")

yappy.c_snow		=	minetest.get_content_id("default:snow")
yappy.c_snowblock	=	minetest.get_content_id("default:snowblock")
yappy.c_ice			=	minetest.get_content_id("default:ice")
yappy.c_dirt_snow	=	minetest.get_content_id("default:dirt_with_snow")

yappy.c_sand		=	minetest.get_content_id("default:sand")
yappy.c_sandstone	=	minetest.get_content_id("default:sandstone")

yappy.c_desert_sand		=	minetest.get_content_id("default:desert_sand")
yappy.c_desert_stone	=	minetest.get_content_id("default:desert_stone")
yappy.c_cactus			=	minetest.get_content_id("default:cactus")
yappy.c_dry_shrub		=	minetest.get_content_id("default:dry_shrub")

local trees = {
	pine = {"Pine sapling", "skylands_pine_sapling.png", "Pine needles", "skylands_needles.png", "pine_needles", "pine_sapling", 3},
	oak = {"Oak sapling", "yappy_oak_sapling.png", "Oak leaves", "yappy_oak_leaves.png", "oak_leaves", "oak_sapling", 4}
}

for k, v in pairs(trees) do
local grp = {snappy=3, flammable=2, leaves=1, leafdecay=0}
grp.leafdecay = v[7]

minetest.register_node("yappy:"..v[5], {
	description = v[3],
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {v[4]},
	paramtype = "light",
	waving = 1,
	groups = grp,
	drop = {
		max_items = 1,
		items = {
			{items = {"yappy:"..v[6]}, rarity = 40},
			{items = {"yappy:"..v[5]}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("yappy:"..v[6], {
	description = v[1],
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {v[2]},
	inventory_image = v[2],
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2, dig_immediate=3, flammable=2, attached_node=1, sapling=1},
	sounds = default.node_sound_leaves_defaults(),
})
end