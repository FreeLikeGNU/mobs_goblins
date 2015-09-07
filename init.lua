local path = minetest.get_modpath("mobs_goblins")

if mobs.mod and mobs.mod == "redo" then
	mobs.debugging_goblins = false

	mobs.search_replace = function(pos, search_rate, replace_rate, replace_what, replace_with)

		if math.random(1, search_rate) == 1 then

			pos = vector.round(pos)
			pos.y = pos.y - 1

			local p1 = vector.subtract(pos, 1)
			local p2 = vector.add(pos, 1)

			if mobs.debugging_goblins then
				print ("Goblin at "
				.. minetest.pos_to_string(pos)
				.. " searching between "
				.. minetest.pos_to_string(p1)
				.. " and "
				.. minetest.pos_to_string(p2)
			)
			end

			--look for nodes
			local nodelist = minetest.find_nodes_in_area(
				p1, p2, replace_what)

			if #nodelist > 0 then
				for key,value in pairs(nodelist) do 
					-- ok we see some nodes around us,
					-- are we going to replace them?
					if math.random(1, replace_rate) == 1 then
						minetest.set_node(value, {name = replace_with})
					end
				end
			end
		end
	end

	mobs.goblin_drops = {
		"default:pick_steel",  "default:sword_steel",
		"default:shovel_steel", "farming:bread", "bucket:bucket_water"
	}

	dofile(path.."/goblin_digger.lua")
	dofile(path.."/goblin_cobbler.lua")
	dofile(path.."/goblin_coal.lua")
	dofile(path.."/goblin_iron.lua")
	dofile(path.."/goblin_gold.lua")
	dofile(path.."/goblin_diamond.lua")
	dofile(path.."/goblin_king.lua")

	minetest.log("action", "GOBLINS is lowdids!")
end
