-- goblins_digger.lua
--

local diggers_walk = function(self)
	local pos = self.object:getpos()
	local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}
	local yaw = (math.floor(self.object:getyaw() * 2 / math.pi + 0.5) % 4)
	local lp = minetest.find_node_near(pos, 1, {"group:water"})

	if not self.digging_state then
		self.digging_state = "coffee_break"
	end

	if not self.room_radius then
		self.room_radius = 1
	end

	if not self.digging_dir then
		self.digging_dir = math.random(0,3)
	end

	if self.digging_state == "coffee_break" then
		if math.random() < 0.2 then
			self.digging_state = "tunnel"
		end

		self:set_animation("walk")
		self.set_velocity(self, self.walk_velocity)
		return true
	elseif self.digging_state == "tunnel" then
		-- self.object:setpos(vector.flat_round(pos))
		yaw = self.digging_dir
		self.object:setyaw(yaw * math.pi * 0.5 + math.random() * 0.5 - 0.25)

		local np = vector.floor(vector.add(pos, cardinals[yaw+1]))
		local node = minetest.get_node(np)

		if node.name == "air" or minetest.get_item_group(node.name, "stone") > 0 or minetest.get_item_group(node.name, "soil") > 0 or minetest.get_item_group(node.name, "plant") > 0 then
			-- dig it
			minetest.remove_node(np)
			self:set_animation("walk")
			self.set_velocity(self, self.walk_velocity)
		else
			self:set_animation("stand")
			self.set_velocity(self, 0)
			-- minetest.chat_send_player('singleplayer',"stopped by "..node.name)
			print("stopped by "..node.name)
			if math.random(2) == 1 then
				self.object:setyaw(((yaw + 1) % 4) * math.pi * 0.5 + math.random() * 0.5 - 0.25)
			else
				self.object:setyaw(((yaw - 1) % 4) * math.pi * 0.5 + math.random() * 0.5 - 0.25)
			end

			self.set_velocity(self, self.walk_velocity)
		end

		local r = math.random()
		if r <= 0.05 then  -- normal mobs movement
			self.digging_state = "coffee_break"
		elseif r <= 0.07 then  -- build a room
			self.digging_state = "room"
		elseif r < 0.2 then  -- turn randomly
			if math.random(2) == 1 then
				self.digging_dir = (self.digging_dir + 1) % 4
			else
				self.digging_dir = (self.digging_dir - 1) % 4
			end
		end
	elseif self.digging_state == "room" then
		self:set_animation("stand")
		local go_on = true
		for r = 0,self.room_radius do
			for x = -r,r do
				for y = 0,r do
					for z = -r,r do
						if go_on and r >= self.room_radius and x >= r and y >= r and z >= r then
							self.room_radius = math.random(1,2) + math.random(0,1)
							self.digging_state = "coffee_break"
						end

						if go_on then
							local np = vector.floor(vector.add(pos, {x=x, y=y, z=z}))
							local node = minetest.get_node(np)
							if minetest.get_item_group(node.name, "stone") > 0 or minetest.get_item_group(node.name, "soil") > 0 or minetest.get_item_group(node.name, "plant") > 0 then
								-- dig it
								minetest.remove_node(np)
								go_on = false
							end
						end
					end
				end
			end
		end
	end

	return false
	-- minetest.chat_send_player('singleplayer',"diggin_state: "..self.digging_state)
	-- print(self.digging_state)
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

	custom_walk = function(self)
		diggers_walk(self)
	end,

	do_custom = function(self)
		mobs.search_replace(self.object:getpos(), 10, 5, {"group:stone", "default:torch", "group:plant"}, "air")
		mobs.search_replace(self.object:getpos(), 50, 5, {"group:stone", "default:torch"}, "mobs_goblins:mossycobble_trap")
	end,
})

mobs:register_egg("mobs_goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_digger", {"group:stone"}, 100, 0, 20, 3, 0)

