yappy.c_air		=	minetest.get_content_id("air")
yappy.c_grass	=	minetest.get_content_id("default:dirt_with_grass")
yappy.c_dirt	=	minetest.get_content_id("default:dirt")
yappy.c_stone	=	minetest.get_content_id("default:stone")
yappy.c_water	=	minetest.get_content_id("default:water_source")
yappy.c_lava	=	minetest.get_content_id("default:lava_source")

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

minetest.register_node("yappy:pine_needles", {
	description = "Pine needles",
	drawtype = "allfaces_optional",
	tiles = {"skylands_needles.png"},
	inventory_image = "skylands_needles.png",
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	drop = {
		max_items = 1,
		items = {
			{items = {"yappy:pine_sapling"}, rarity = 40},
			{items = {"yappy:pine_needles"}}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("yappy:pine_sapling", {
	description = "Pine sapling",
	drawtype = "plantlike",
	tiles = {"skylands_pine_sapling.png"},
	inventory_image = "skylands_pine_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2, dig_immediate=3, flammable=2, attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})