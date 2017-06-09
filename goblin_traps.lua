--[[some nasty things goblins can do]]
--Super thanks to duane-r for his work: https://github.com/duane-r/mobs_goblins/blob/work/goblin_traps.lua


minetest.register_node("mobs_goblins:mossycobble_trap", {
	description = "Messy Gobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	light_source = 4,
})

minetest.register_node("mobs_goblins:stone_with_coal_trap", {
	description = "Coal Trap",
	tiles = {"default_cobble.png^default_mineral_coal.png"},
	groups = {cracky = 1, level = 2},
	drop = 'default:coal_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:is_player() then
				if math.random(0,100) < 10 then -- chance player will get hurt mining this
					if puncher:get_hp() > 0 then
						puncher:set_hp(puncher:get_hp()-1)
						minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
					 end
				end
		end
	end,

})

minetest.register_node("mobs_goblins:stone_with_iron_trap", {
	description = "Iron Gore",
	tiles = {"default_cobble.png^default_mineral_iron.png"},
	groups = {cracky = 1, level = 2},
	drop = 'default:iron_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:is_player() then
				if math.random(0,100) < 25 then -- chance player will get hurt mining this
					if puncher:get_hp() > 0 then
						puncher:set_hp(puncher:get_hp()-1)
						minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
					 end
				end
			
		end
	end,
})
minetest.register_node("mobs_goblins:stone_with_copper_trap", {
	description = "Copper Gore",
	tiles = {"default_cobble.png^default_mineral_copper.png"},
	groups = {cracky = 1, level = 2},
	drop = 'default:copper_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:is_player() then
				if math.random(0,100) < 50 then -- chance player will get hurt mining this
					if puncher:get_hp() > 0 then
						puncher:set_hp(puncher:get_hp()-1)
						minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
					 end
				end
		end
	end,
})
minetest.register_node("mobs_goblins:stone_with_gold_trap", {
	description = "Gold Gore",
	tiles = {"default_cobble.png^default_mineral_gold.png"},
	groups = {cracky = 1,level = 2},
	drop = 'default:gold_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:is_player() then
				if math.random(0,100) < 50 then -- chance player will get hurt mining this
					if puncher:get_hp() > 0 then
						puncher:set_hp(puncher:get_hp()-1)
						minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
					 end
				end
		end
	end,
})
minetest.register_node("mobs_goblins:stone_with_diamond_trap", {
	description = "Diamond Gore",
	tiles = {"default_cobble.png^default_mineral_diamond.png"},
	groups = {cracky = 1, level = 3},
	drop = 'default:diamond',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
		on_punch = function(pos, node, puncher)
		if puncher:is_player() then
				if math.random(0,100) < 75 then -- chance player will get hurt mining this
					if puncher:get_hp() > 0 then
						puncher:set_hp(puncher:get_hp()-1)
						minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
					 end
				end
		end
	end,
})

minetest.register_node("mobs_goblins:molten_gold_source", {
	description = "Molten Gold Source",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "goblins_molten_gold_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
		},
	},
	special_tiles = {
		-- New-style lava source material (mostly unused)
		{
			name = "goblins_molten_gold_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0,
			},
			backface_culling = false,
		},
	},
	paramtype = "light",
	light_source = default.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "mobs_goblins:molten_gold_flowing",
	liquid_alternative_source = "mobs_goblins:molten_gold_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	groups = {lava=3, liquid=2, hot=3, igniter=1},
})

minetest.register_node("mobs_goblins:molten_gold_flowing", {
	description = "Flowing Molten Gold",
	inventory_image = minetest.inventorycube("default_lava.png"),
	drawtype = "flowingliquid",
	tiles = {"default_lava.png"},
	special_tiles = {
		{
			name = "goblins_molten_gold_flowing_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
		{
			name = "goblins_molten_gold_flowing_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
	},
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = default.LIGHT_MAX - 1,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "mobs_goblins:molten_gold_flowing",
	liquid_alternative_source = "mobs_goblins:molten_gold_source",
	liquid_viscosity = 7,
	liquid_renewable = false,
	liquid_range = 3,
	damage_per_second = 4 * 2,
	post_effect_color = {a=192, r=255, g=64, b=0},
	groups = {lava=3, liquid=2, hot=3, igniter=1, not_in_creative_inventory=1},
})



--[[ too bad we can't keep track of what physics are set too by other mods...]]
minetest.register_abm({
	nodenames = {"mobs_goblins:mossycobble_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 0.95)) do -- IDKWTF this is but it works
				if object:is_player() then
					object:set_physics_override({speed = 0.1})
					minetest.after(1, function() -- this effect is temporary
						object:set_physics_override({speed = 1})  -- we'll just set it to 1 and be done.
					end)
				end
		end
	end})

minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_coal_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
			if object:is_player() then
				minetest.set_node(pos, {name="fire:basic_flame"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
					minetest.after(6, function() --this hell ends after a few seconds
						minetest.set_node(pos, {name = "air"})
					end)	
				end
			end
		end
	end})


-- summon a metallic goblin?
-- pit of iron razors?
minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_iron_trap"},
	interval = 2,
	chance = 2, --this may be a dud
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

local function lightning_effects(pos, radius)
	minetest.add_particlespawner({
		amount = 30,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-10, y=-10, z=-10},
		maxvel = {x=10,  y=10,  z=10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 16,
		maxsize = 32,
		texture = "goblins_lightning.png",
	})
end

--[[ based on dwarves cactus]]
minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_copper_trap"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					-- sprite
					lightning_effects(pos, 3)
					minetest.sound_play("goblins_goblin_pick", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_gold_trap"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="mobs_goblins:molten_gold_source"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
					minetest.after(6, function() --this hell ends after a few seconds
						minetest.set_node(pos, {name = "air"})
					end)	
				 end
			end
		end
	end})

local setting = minetest.settings:get_bool("enable_tnt")
if setting == true then
	print("enable_tnt = true")
else
	print("enable_tnt ~= true")
end

local singleplayer = minetest.is_singleplayer()
if (not singleplayer and setting ~= true) or (singleplayer and setting == false) then
	-- wimpier trap for non-tnt settings
	minetest.register_abm({
		nodenames = {"mobs_goblins:stone_with_diamond_trap"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
				if object:is_player() then
					minetest.set_node(pos, {name="default:lava_source"})
					if object:get_hp() > 0 then
						object:set_hp(object:get_hp()-2)
						minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
						minetest.after(6, function() --this hell ends after a few seconds
							minetest.set_node(pos, {name = "air"})
						end)	
					end
				end
			end
		end})
else
	-- 5... 4... 3... 2... 1...
	minetest.register_abm({
		nodenames = {"mobs_goblins:stone_with_diamond_trap"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
				if object:is_player() then
					minetest.set_node(pos, {name="tnt:tnt_burning"})
					minetest.get_node_timer(pos):start(5)
					minetest.sound_play("tnt_ignite", {pos = pos, gain = 0.5, max_hear_distance = 10})
				end
			end
		end})
end
