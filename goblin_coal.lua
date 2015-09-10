

mobs:register_mob("mobs_goblins:goblin_coal", {
	description = "Coal Goblin",
	type = "animal",
	passive = false,
	damage = 1,
	attack_type = "dogfight",
	attacks_monsters = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_coal1.png"},
			{"goblins_goblin_coal2.png"},
		},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		distance = 15,
	},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:coal_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:torch",
		chance = 3, min = 1, max = 10},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"default:diamond"},
	view_range = 10,
	owner = "",
	order = "follow",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- feed to heal goblin
		if item:get_name() == "default:apple"
		or item:get_name() == "farming:bread" then

			local hp = self.object:get_hp()
			-- return if full health
			if hp >= self.hp_max then
				minetest.chat_send_player(name, "goblin at full health.")
				return
			end
			hp = hp + 4
			if hp > self.hp_max then hp = self.hp_max end
			self.object:set_hp(hp)
			-- take item
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs.goblin_drops[math.random(1, #mobs.goblin_drops)]})

		else
			-- if owner switch between follow and stand
			if self.owner and self.owner == clicker:get_player_name() then
				if self.order == "follow" then
					self.order = "stand"
				else
					self.order = "follow"
				end
--			else
--				self.owner = clicker:get_player_name()
			end
		end

		mobs:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,

	do_custom = function(self)
		mobs.search_replace(self.object:getpos(), 10, 1, {"group:stone", "default:stone_with_coal"}, "default:mossycobble")
		mobs.search_replace(self.object:getpos(), 2, 1, {"default:torch", "group:plant"}, "air")
		mobs.search_replace(self.object:getpos(), 50, 5, {"default:stone_with_coal", "group:stone"}, "mobs_goblins:stone_with_coal_trap")
	end,

})
mobs:register_egg("mobs_goblins:goblin_coal", "Goblin Egg (coal)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_coal", {"default:stone_with_coal"}, 100, 0, 1, 3, 0)
mobs:register_spawn("mobs_goblins:goblin_coal", {"default:mossycobble"}, 100, 0, 20, 3, 0)

minetest.register_node("mobs_goblins:stone_with_coal_trap", {
	description = "Coal Trap",
	tiles = {"default_cobble.png^default_mineral_coal.png"},
	groups = {cracky = 3},
	drop = 'default:coal_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

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

