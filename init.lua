local path = minetest.get_modpath("mobs_goblins")

mobs_goblins = {}
mobs_goblins.spawn_frequency = 10

if mobs.mod and mobs.mod == "redo" then
	mobs.debugging_goblins = false

	mobs_goblins.search_replace = function(pos, search_rate, replace_what, replace_with)
		-- replace_rate is unnecessary, just replace one at a time.
		-- I only get to do one thing per step, so do they.
		if math.random(1, search_rate) == 1 then
			local p1 = vector.subtract(pos, 1)
			local p2 = vector.add(pos, 1)

			--look for nodes
			local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)

			if #nodelist > 0 then
				for key,value in pairs(nodelist) do 
					minetest.set_node(value, {name = replace_with})
					return  -- only one at a time
				end
			end
		end
	end

	mobs.goblin_drops = { "default:pick_steel",  "default:sword_steel", "default:shovel_steel", "farming:bread", "bucket:bucket_water", "default:pick_stone", "default:sword_stone" }
	--{"group:stone"} = { "default:stone", "default:mossycobble", "default:sandstone", "default:desert_stone", "default:stone_with_coal", "default:stone_with_iron", "default:stone_with_copper", "default:stone_with_gold", "default:stone_with_diamond" }

	dofile(path.."/goblin_cobbler.lua")
	dofile(path.."/goblin_copper.lua")
	dofile(path.."/goblin_coal.lua")
	dofile(path.."/goblin_diamond.lua")
	dofile(path.."/goblin_digger.lua")
	dofile(path.."/goblin_gold.lua")
	dofile(path.."/goblin_iron.lua")
	dofile(path.."/goblin_king.lua")

	minetest.log("action", "GOBLINS is lowdids!")
end
