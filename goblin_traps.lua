--[[some nasty things goblins can do]]



minetest.register_node("mobs_goblins:mossycobble_trap", {
	description = "Messy Gobblestone",
	tiles = {"default_mossycobble.png"},
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mobs_goblins:stone_with_coal_trap", {
	description = "Coal Trap",
	tiles = {"default_cobble.png^default_mineral_coal.png"},
	groups = {cracky = 3},
	drop = 'default:coal_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mobs_goblins:stone_with_iron_trap", {
	description = "Iron Gore",
	tiles = {"default_cobble.png^default_mineral_iron.png"},
	groups = {cracky = 3},
	drop = 'default:iron_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("mobs_goblins:stone_with_copper_trap", {
	description = "Copper Gore",
	tiles = {"default_cobble.png^default_mineral_copper.png"},
	groups = {cracky = 3},
	drop = 'default:copper_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("mobs_goblins:stone_with_gold_trap", {
	description = "Gold Gore",
	tiles = {"default_cobble.png^default_mineral_gold.png"},
	groups = {cracky = 3},
	drop = 'default:gold_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("mobs_goblins:stone_with_diamond_trap", {
	description = "Diamond Gore",
	tiles = {"default_cobble.png^default_mineral_diamond.png"},
	groups = {cracky = 3},
	drop = 'default:diamond',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})



--[[ too bad we can't keep track of what physics are set too by other mods...]]
minetest.register_abm({
	nodenames = {"mobs_goblins:mossycobble_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 0.95)) do -- IDKWTF this is but it works
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
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="fire:basic_flame"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
				end
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_iron_trap"},
	interval = 2,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

--[[ based on dwarves cactus]]
minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_copper_trap"},
	interval = 1,
	chance = 2,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_gold_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 2)) do
			if object:is_player() then
				minetest.set_node(pos, {name="default:lava_source"})
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-2)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

minetest.register_abm({
	nodenames = {"mobs_goblins:stone_with_diamond_trap"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 3)) do
			if object:is_player() then
				minetest.set_node(pos, {name="tnt:tnt_burning"})
				minetest.get_node_timer(pos):start(5)
				minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
			end
		end
	end})
