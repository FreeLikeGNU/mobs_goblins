

mobs:register_mob("mobs_goblins:goblin_copper", {
	description = "Copper Goblin",
	type = "monster",
	passive = false,
	damage = 2,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_copper1.png"},
			{"goblins_goblin_copper2.png"},
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
		{name = "default:copper_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:pick_steel",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = "default:diamond",
	view_range = 15,
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
		mobs.search_replace(self.object:getpos(), 10, 1, {"group:stone", "default:stone_with_copper"}, "default:mossycobble")
		mobs.search_replace(self.object:getpos(), 2, 1, {"default:torch", "group:plant"}, "air")
		mobs.search_replace(self.object:getpos(), 50, 5, {"default:stone_with_copper", "group:stone"}, "mobs_goblins:stone_with_copper_trap")
	end,
})
mobs:register_egg("mobs_goblins:goblin_copper", "Goblin Egg (copper)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_copper", {"default:stone_with_copper"}, 100, 0, 1, 3, 0)

minetest.register_node("mobs_goblins:stone_with_copper_trap", {
	description = "Copper Trap",
	tiles = {"default_cobble.png^default_mineral_copper.png"},
	groups = {cracky = 3},
	drop = 'default:copper_lump',
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

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
		for _,object in ipairs(minetest.env:get_objects_inside_radius(pos, 3)) do
			if object:is_player() then
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp()-1)
					-- sprite
					lightning_effects(pos, 3)
					minetest.sound_play("default_dig_crumbly", {pos = pos, gain = 0.5, max_hear_distance = 10})
				 end
			end
		end
	end})

