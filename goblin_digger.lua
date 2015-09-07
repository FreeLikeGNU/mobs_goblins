-- goblins_digger.lua
--

mobs.goblin_drops = {
	"default:pick_steel",  "default:sword_steel",
	"default:shovel_steel", "farming:bread", "bucket:bucket_water"
}

local debugging_goblins = false
 
local diggers_walk = function(self)
	local pos = self.object:getpos()
	-- local ai_radius = 3

	local cardinals = {{0,1}, {-1,0}, {0,-1}, {1,0} }
	local yaw = (math.floor(self.object:getyaw() * 2 / math.pi + 0.5) % 4)
	local preferred_turn = {0,-1,1,2}
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
		-- if water nearby then turn away
		if lp then
			local vec = {x = lp.x - pos.x, y = lp.y - pos.y, z = lp.z - pos.z}
			yaw = math.atan(vec.z / vec.x) + 3 * math.pi / 2 - self.rotate
			if lp.x > pos.x then
				yaw = yaw + math.pi
			end
			self.object:setyaw(yaw)

		-- otherwise randomly turn
		elseif math.random() <= 0.3 then
			self.object:setyaw(self.object:getyaw() + (math.random() * math.pi * 2 - math.pi))
		end

		if self.jump and self.get_velocity(self) <= 0.5
			and self.object:getvelocity().y == 0 then
			self.direction = {
				x = math.sin(yaw) * -1,
				y = -20,
				z = math.cos(yaw)
			}
			do_jump(self)
		end

		self:set_animation("walk")
		self.set_velocity(self, self.walk_velocity)

		if math.random() < 0.2 then
			self.digging_state = "tunnel"
		end
	elseif self.digging_state == "tunnel" then
		local p = self.object:getpos()
		self.object:setpos({x=math.floor(p.x+0.5), y=p.y, z=math.floor(p.z+0.5)})
		yaw = self.digging_dir
		-- minetest.chat_send_player('singleplayer',"yaw: "..yaw)
		self.object:setyaw(yaw * math.pi * 0.5)
		self:set_animation("stand")

		local np = {x=math.floor(pos.x+cardinals[yaw+1][1]), y=math.floor(pos.y), z=math.floor(pos.z+cardinals[yaw+1][2])}
		local node = minetest.get_node(np)

		if minetest.get_item_group(node.name, "stone") > 0 or minetest.get_item_group(node.name, "soil") > 0 then
			-- dig it
			minetest.set_node(np, {name="air"})
			self:set_animation("walk")
			self.set_velocity(self, self.walk_velocity)
		elseif node.name == "air" then
			self:set_animation("walk")
			self.set_velocity(self, self.walk_velocity)
		else
			minetest.chat_send_player('singleplayer',"stopped by "..node.name)
			self.object:setyaw((math.floor(yaw + math.random(1,3)) % 4) * math.pi * 0.5)

			self.set_velocity(self, self.walk_velocity)
		end

		local r = math.random()
		if r <= 0.05 then
			-- self.digging_state = "coffee_break"
		elseif r <= 0.06 then
			self.digging_state = "room"
		elseif r < 0.2 then
			local nd = math.random(0,3)
			self.digging_dir = nd
		end
	elseif self.digging_state == "room" then
		self:set_animation("stand")
		local go_on = true
		for r = 0,self.room_radius do
			for x = -r,r do
				for y = 0,r do
					for z = -r,r do
						if go_on and r >= self.room_radius and x >= r and y >= r and z >= r then
							self.room_radius = math.random(3)
							self.digging_state = "coffee_break"
						end

						if go_on then
							local np = {x=math.floor(pos.x+x), y=math.floor(pos.y+y), z=math.floor(pos.z+z)}
							local node = minetest.get_node(np)
							if minetest.get_item_group(node.name, "stone") > 0 or minetest.get_item_group(node.name, "soil") > 0 then
								-- dig it
								minetest.set_node(np, {name="air"})
								go_on = false
							end
						end
					end
				end
			end
		end
	elseif false then
		for _, dt in pairs(preferred_turn) do
			local new_yaw = (dt + yaw) % 4
			local np = {x=math.floor(pos.x+cardinals[new_yaw+1][1]), y=math.floor(pos.y), z=math.floor(pos.z+cardinals[new_yaw+1][2])}
			local node = minetest.get_node(np)
		end
	end

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
})
mobs:register_egg("mobs_goblins:goblin_digger", "Goblin Egg (digger)", "default_mossycobble.png", 1)
mobs:register_spawn("mobs_goblins:goblin_digger", {"group:stone"}, 100, 0, 20, 3, 0)

