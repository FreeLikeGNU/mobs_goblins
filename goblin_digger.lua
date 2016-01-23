-- goblins_digger.lua
--

-- He destroys everything diggable in his path. It's too much trouble
--  to fudge around with particulars. Besides, I don't want them to
--  mine for me.
local diggable_nodes = {"group:stone", "group:sand", "group:soil", "group:plant"}
-- This translates yaw into vectors.
local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}

mobs.goblin_tunneling = function(self, type)
	-- Types are available for fine-tuning.
	if type == nil then
		type = "digger"
	end

	local pos = self.object:getpos()

	if self.state == "tunnel" then
		-- Yaw is stored as one of the four cardinal directions.
		if not self.digging_dir then
			self.digging_dir = math.random(0,3)
		end

		-- Turn him roughly in the right direction.
		-- self.object:setyaw(self.digging_dir * math.pi * 0.5 + math.random() * 0.5 - 0.25)
		self.object:setyaw(self.digging_dir * math.pi * 0.5)

		-- Get a pair of coordinates that should cover what's in front of him.
		local p = vector.add(pos, cardinals[self.digging_dir+1])
		p.y = p.y - 0.5  -- What's this about?
		local p1 = vector.add(p, -0.3)
		local p2 = vector.add(p, 0.3)

		-- Get any diggable nodes in that area.
		local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

		if #np_list > 0 then
			-- Dig it.
			for _, np in pairs(np_list) do
				minetest.remove_node(np)
			end
		end

		if math.random() < 0.2 then
			local d = {-1,1}
			self.digging_dir = (self.digging_dir + d[math.random(2)]) % 4
		end

		set_animation(self, "walk")
		set_velocity(self, self.walk_velocity)
	elseif self.state == "room" then  -- Dig a room.
		if not self.room_radius then
			self.room_radius = 1
		end

		set_animation(self, "stand")
		set_velocity(self, 0)

		-- Work from the inside, out.
		for r = 1,self.room_radius do
			-- Get a pair of coordinates that form a room.
			local p1 = vector.add(pos, -r)
			local p2 = vector.add(pos, r)
			-- But not below him.
			p1.y = pos.y

			local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

			-- I wanted to leave the outer layer incomplete, but this
			--  actually tends to make it look worse.
			if r >= self.room_radius and #np_list == 0 then
				self.room_radius = math.random(1,2) + math.random(0,1)
				self.state = "stand"
				break
			end

			if #np_list > 0 then
				-- Dig it.
				minetest.remove_node(np_list[math.random(#np_list)])
				break
			end
		end
	end

	if self.state == "stand" and math.random() < 0.05 then
		self.state = "tunnel"
	elseif self.state == "tunnel" and math.random() < 0.05 then
		self.state = "room"
	elseif self.state == "tunnel" and math.random() < 0.1 then
		self.state = "stand"
	end
end

mobs:register_mob("mobs_goblins:goblin_digger", {
	description = "Digger Goblin",
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
			{"goblins_goblin_digger.png"},
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
		{name = "valleys_c:mushroom_steak",
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
		mobs.goblin_tunneling(self, "digger")

		mobs_goblins.search_replace(self.object:getpos(), 5, {"default:torch"}, "air")
		mobs_goblins.search_replace(self.object:getpos(), 10, {"group:stone"}, "default:mossycobble")
		mobs_goblins.search_replace(self.object:getpos(), 50, {"group:stone"}, "mobs_goblins:mossycobble_trap")
	end,
})

mobs:register_egg("mobs_goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_digger", {"group:stone"}, 100, 0, 20 * mobs_goblins.spawn_frequency, 3, 0)
mobs:register_spawn("mobs_goblins:goblin_digger", {"default:mossycobble"}, 100, 0, 1 * mobs_goblins.spawn_frequency, 3, 0)

