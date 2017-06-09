
-- Npc by TenPlus1 converted for FLG Goblins :D

mobs_goblins.goblin_tunneling = function(self, type)
	-- Types are available for fine-tuning.
	if type == nil then
		type = "digger"
	end

	-- He destroys everything diggable in his path. It's too much trouble
	--  to fudge around with particulars. Besides, I don't want them to
	--  mine for me.
	local diggable_nodes = {"group:stone", "group:sand", "group:soil", "group:cracky", "group:crumbly", "group:choppy", "group:plant"}
	-- This translates yaw into vectors.
	local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}
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

		if math.random() < 0.5 then
			local d = {-1,1}
			self.digging_dir = (self.digging_dir + d[math.random(2)]) % 4
		end

		self:set_animation("walk")
		self.set_velocity(self, self.walk_velocity)
	elseif self.state == "room" then  -- Dig a room.
		if not self.room_radius then
			self.room_radius = 1
		end

		self:set_animation("stand")
		self.set_velocity(self, 0)

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

	if self.state == "stand" and math.random() < 0.1 then
		self.state = "tunnel"
	elseif self.state == "tunnel" and math.random() < 0.05 then
		self.state = "room"
	elseif self.state == "tunnel" and math.random() < 0.05 then
		self.state = "stand"
	end
end

mobs_goblins.goblin_drops = {
	"default:pick_steel",  "default:sword_steel",
	"default:shovel_steel", "farming:bread", "bucket:bucket_water"
}
mobs_goblins:register_mob("mobs_goblins:goblin_cobble", {
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
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2.5,
	jump = true,
	drops = {
		{name = "default:pick_stone",
		chance = 2, min = 1, max = 1},
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
-- updated node searching!
	search_rate = 30,
	search_rate_above = 1,
	search_rate_below = 1,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 10,
	replace_what = {"default:stone","default:desert_stone","default:torch"},
	replace_with = "default:mossycobble",
	replace_rate_secondary = 10,
	replace_with_secondary = "mobs_goblins:mossycobble_trap",

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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_digger", {
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
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2.5,
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
-- updated node searching!
	search_rate = 5,
	search_rate_above = 20,
	search_rate_below = 40,
	search_offset = 1,
	search_offset_below = 1.1,
	search_offset_above = 1,
	replace_rate = 4,
	replace_what = {"default:torch"},
	replace_with = "air",

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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
	do_custom = function(self)
		mobs_goblins.goblin_tunneling(self, "digger")

		-- mobs_goblins.search_replace(self.object:getpos(), 5, {"default:torch"}, "air")
		-- mobs_goblins.search_replace(self.object:getpos(), 10, {"group:stone"}, "default:mossycobble")
		-- mobs_goblins.search_replace(self.object:getpos(), 50, {"group:stone"}, "mobs_goblins:mossycobble_trap")
	end,
})

mobs_goblins:register_mob("mobs_goblins:goblin_coal", {
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
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2,
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
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 5,
	replace_what = {"default:torch","default:stone_with_coal"},
	replace_with = "air",
	replace_rate_secondary = 3,  --or maybe just set a nasty trap
	replace_with_secondary = "mobs_goblins:stone_with_coal_trap", 
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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_iron", {
	description = "Iron Goblin",
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
			{"goblins_goblin_iron1.png"},
			{"goblins_goblin_iron2.png"},
		},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2,
	jump = true,
	drops = {
		{name = "default:iron_lump",
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
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 5,
	replace_what = {"default:torch","default:stone_with_iron", },
	replace_with = "air",  --steal outright
	replace_rate_secondary = 3,  --or maybe just set a nasty trap
	replace_with_secondary = "mobs_goblins:stone_with_iron_trap", 

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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_copper", {
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
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2,
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
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 5,
	replace_what = {"default:torch","default:stone_with_copper", },
	replace_with = "air",  --steal outright
	replace_rate_secondary = 3,  --or maybe just set a nasty trap
	replace_with_secondary = "mobs_goblins:stone_with_copper_trap", 

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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_gold", {
	description = "Gold Goblin",
	type = "monster",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 10,
	hp_max = 30,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_gold1.png"},
			{"goblins_goblin_gold2.png"},		
		},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1.5,
	run_velocity = 2,
	jump = true,
	drops = {
		{name = "default:gold_lump",
		chance = 1, min = 1, max = 3},
		{name = "default:apple",
		chance = 2, min = 1, max = 2},
		{name = "default:gold_ingot",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = "default:diamond",
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 5,
	replace_what = {"default:torch","default:stone_with_gold", },
	replace_with = "air",
	replace_rate_secondary = 4,  --or maybe just set a nasty trap
	replace_with_secondary = "mobs_goblins:stone_with_gold_trap", 
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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_diamond", {
	description = "Diamond Goblin",
	type = "monster",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 20,
	hp_max = 30,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_diamond1.png"},
			{"goblins_goblin_diamond2.png"},
		},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	drops = {
		{name = "default:pick_diamond",
		chance = 1, min = 1, max = 1},
		{name = "default:apple",
		chance = 2, min = 1, max = 10},
		{name = "default:diamond",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = "default:diamond",
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	walk_velocity = 1.5,
	run_velocity = 2,
	replace_rate = 5,
	replace_what = {"default:torch","default:stone_with_diamond", },
	replace_with = "air",
	replace_rate_secondary = 3,  --or maybe just set a nasty trap
	replace_with_secondary = "mobs_goblins:stone_with_diamond_trap", 
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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
mobs_goblins:register_mob("mobs_goblins:goblin_king", {
	description = "Goblin King",
	type = "monster",
	passive = false,
	damage = 4,
	attack_type = "dogfight",
	attacks_monsters = false,
	hp_min = 20,
	hp_max = 40,
	armor = 100,
	collisionbox = {-0.35,-1,-0.35, 0.35,-.1,0.35},
	visual = "mesh",
	mesh = "goblins_goblin.b3d",
	drawtype = "front",
		textures = {
			{"goblins_goblin_king.png"},
		},
	makes_footstep_sound = true,
	sounds = {
		random = "goblins_goblin_ambient",
		warcry = "goblins_goblin_attack",
		attack = "goblins_goblin_attack",
		damage = "goblins_goblin_damage",
		death = "goblins_goblin_death",
		replace = "goblins_goblin_pick",
		distance = 15,
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	drops = {
		{name = "default:pick_mese",
		chance = 1, min = 1, max = 1},
		{name = "default:apple",
		chance = 2, min = 1, max = 10},
		{name = "default:mese_crystal",
		chance = 5, min = 1, max = 1},
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = "default:diamond",
-- updated node searching!
	search_rate = 10,
	search_rate_above = 1,
	search_rate_below = 20,
	search_offset = 1,
	search_offset_below = 1,
	search_offset_above = 2,
	replace_rate = 5,
	replace_what = {"default:torch", "group:stone"},
	replace_with = "default:mossycobble_trap",

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
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end

		-- right clicking with gold lump drops random item from mobs_goblins.goblin_drops
		elseif item:get_name() == "default:gold_lump" then
			if not minetest.settings:get_bool("creative_mode") then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			local pos = self.object:getpos()
			pos.y = pos.y + 0.5
			minetest.add_item(pos, {name = mobs_goblins.goblin_drops[math.random(1, #mobs_goblins.goblin_drops)]})

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

		mobs_goblins:capture_mob(self, clicker, 0, 5, 80, false, nil)
	end,
		
})
-- spawn at or below 0 near ore and dungeons and goblin lairs (areas of mossy cobble), except diggers that will dig out caves from stone and cobble goblins who create goblin lairs near stone.
--function mobs_goblins:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height)
--[[
mobs_goblins:register_spawn("mobs_goblins:goblin_cobble", {"group:stone"}, 100, 0, 20, 4, 0)
mobs_goblins:register_spawn("mobs_goblins:goblin_digger", {"group:stone"}, 100, 0, 20, 4, 0)
mobs_goblins:register_spawn("mobs_goblins:goblin_coal", {"default:stone_with_coal"}, 100, 0, 1, 3, 0)
mobs_goblins:register_spawn("mobs_goblins:goblin_iron", {"default:stone_with_iron"}, 100, 0, 1, 3, -20)
mobs_goblins:register_spawn("mobs_goblins:goblin_copper", {"default:stone_with_copper","default:mossycobble"}, 100, 0, 1, 3, -30)
mobs_goblins:register_spawn("mobs_goblins:goblin_gold", {"default:stone_with_gold" }, 100, 0, 1, 2, -40)
mobs_goblins:register_spawn("mobs_goblins:goblin_diamond", {"default:stone_with_diamond"}, 100, 0, 1, 2, -60)
mobs_goblins:register_spawn("mobs_goblins:goblin_king", {"default:stone_with_mese","default:mossycobble", }, 100, 0, 2, 1, -100)
mobs_goblins:register_egg("mobs_goblins:goblin_cobble", "goblin egg", "default:mossycobble", 1)
]]
--[[ function mobs_goblins:spawn_specific(
name,
nodes, 
neighbors,  
min_light, 
max_light, 
interval, 
chance, 
active_object_count, 
min_height, 
max_height)
]]
mobs_goblins:spawn_specific("mobs_goblins:goblin_cobble", {"group:stone"}, "air", 0, 50, 1, 10, 3, -30000 , 0)
mobs_goblins:spawn_specific("mobs_goblins:goblin_digger", {"group:stone"},  "air", 0, 50, 1, 10, 3, -30000 , 0)
mobs_goblins:spawn_specific("mobs_goblins:goblin_coal", {"default:stone_with_coal", "default:mossycobble"}, "air",0, 50, 1, 2, 3, -30000, 0)
mobs_goblins:spawn_specific("mobs_goblins:goblin_iron", {"default:stone_with_iron", "default:mossycobble"}, "air", 0, 50, 1, 2, 3, -30000, -20)
mobs_goblins:spawn_specific("mobs_goblins:goblin_copper", {"default:stone_with_copper", "default:mossycobble"}, "air", 0, 50, 1, 2, 3, -30000, -20)
mobs_goblins:spawn_specific("mobs_goblins:goblin_gold", {"default:stone_with_gold", "default:mossycobble"}, "air",0, 50, 1, 2, 3, -30000, -40)
mobs_goblins:spawn_specific("mobs_goblins:goblin_diamond", {"default:stone_with_diamond", "default:mossycobble" }, "air", 0, 50, 1,2, 3, -30000, -80)
mobs_goblins:spawn_specific("mobs_goblins:goblin_king", {"default:mossycobble",},"air", 0, 50, 1, 10, 3, -30000, -100)
mobs_goblins:register_egg("mobs_goblins:goblin_cobble", "goblin egg", "default:mossycobble", 1) 

