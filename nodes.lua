local trees = {
	oak = {
		sapling = "lualandmg_oak_sapling.png",
		leaves = {"lualandmg_oak_leaves.png", "leaves", 4, 40},
		wood = "moretrees_oak_wood.png",
		trunk = {"moretrees_oak_trunk.png", "moretrees_oak_trunk_top.png"}
	}
}

for k, v in pairs(trees) do
	local name = k:gsub("^%l", string.upper).." "
	local leaves = "lualandmg:"..k.."_"..v.leaves[2]

	minetest.register_node(leaves, {
		description = name..v.leaves[2],
		drawtype = "allfaces_optional",
		visual_scale = 1.3,
		tiles = { v.leaves[1] },
		paramtype = "light",
		waving = 1,
		groups = {snappy=3, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{items = {"lualandmg:"..k.."_sapling"}, rarity = v.leaves[4]},
				{items = { leaves }}
			}
		},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("lualandmg:"..k.."_sapling", {
		description = name.."sapling",
		drawtype = "plantlike",
		visual_scale = 1.0,
		tiles = { v.sapling },
		inventory_image = v.sapling,
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
		},
		groups = {snappy=2, dig_immediate=3, flammable=2, attached_node=1, sapling=1},
		sounds = default.node_sound_leaves_defaults(),
	})

	minetest.register_node("lualandmg:"..k.."_trunk", {
		description = name.."trunk",
		tiles = { v.trunk[2], v.trunk[2], v.trunk[1] },
		paramtype2 = "facedir",
		groups = {tree=1, choppy=2, oddly_breakable_by_hand=1, flammable=2},
		sounds = default.node_sound_wood_defaults(),
		on_place = minetest.rotate_node
	})
	
	minetest.register_node("lualandmg:"..k.."_wood", {
		description = name.."planks",
		tiles = { v.wood },
		groups = {wood=1, choppy=2, oddly_breakable_by_hand=2, flammable=3},
		sounds = default.node_sound_wood_defaults(),
	})
	
	minetest.register_craft({
		output = "lualandmg:"..k.."_wood 4",
		recipe = {
			{"lualandmg:"..k.."_trunk"},
		}
	})

	minetest.register_craft({
		output = "default:stick 4",
		recipe = {
			{"lualandmg:"..k.."_wood"},
		}
	})
	
	minetest.register_abm({
		nodenames = { leaves },
		interval = 5,
		chance = 5,
		action = function(pos, node)
			if minetest.find_node_near(pos, v.leaves[3], 
					{"ignore", "default:tree", "lualandmg:"..k.."_trunk"}) then
				return
			end
			
			local drops = minetest.get_node_drops(node.name)
			for _, dropitem in ipairs(drops) do
				if dropitem ~= node.name then
					minetest.add_item(pos, dropitem)
				end
			end
			minetest.remove_node(pos)
		end
	})
end

minetest.register_abm({
	nodenames = {"lualandmg:pine_sapling", "lualandmg:oak_sapling"},
	interval = 50,
	chance = 50,
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
		if node.name == "lualandmg:pine_sapling" then
			lualandmg.gen_pine_tree(pos.x, pos.y, pos.z, area, data)
		else
			lualandmg.gen_oak_tree(pos.x, pos.y, pos.z, area, data)
		end
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
})