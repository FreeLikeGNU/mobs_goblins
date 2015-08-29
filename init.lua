local path = minetest.get_modpath("mobs_goblins")

-- Mob Api

dofile(path.."/api.lua")
dofile(path.."/goblins.lua") -- TenPlus1 and FreeLikeGNU


--if minetest.setting_get("log_mods") then
	minetest.log("action", "GOBLINS is lowdids!")
--end