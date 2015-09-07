mobs.goblin_drops = {
	"default:pick_steel",  "default:sword_steel",
	"default:shovel_steel", "farming:bread", "bucket:bucket_water"
}

local debugging_goblins = false

local search_replace = function(pos, search_rate, replace_rate, replace_what, replace_with)

	if math.random(1, search_rate) == 1 then

		pos = vector.round(pos)
		pos.y = pos.y - 1

		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		if debugging_goblins then
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

mobs:register_mob("mobs_goblins:goblin_cobble", {
	description = "Cobble Goblin",
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
			{"goblins_goblin_cobble1.png"},
			{"goblins_goblin_cobble2.png"},
			
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
		{name = "default:mossycobble",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:torch",
		chance = 3, min = 1, max = 10},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	lifetimer = 360,
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
		search_replace(self.object:getpos(), 10, 5,
		{"default:stone","default:desert_stone","default:torch"},
		"default:mossycobble")
	end,
})
mobs:register_egg("mobs_goblins:goblin_cobble", "Goblin Egg (cobble)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_cobble", {"group:stone"}, 100, 0, 20, 3, 0)

