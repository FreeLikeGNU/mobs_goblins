local path = minetest.get_modpath("mobs_goblins")

-- if mobs.mod and mobs.mod == "redo" then
	dofile(path.."/api.lua")
	dofile(path.."/goblin_digger.lua")

	minetest.log("action", "GOBLINS is lowdids!")
-- end
