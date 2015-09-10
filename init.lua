local path = minetest.get_modpath("mobs_goblins")

if mobs.mod and mobs.mod == "redo" then
	mobs.debugging_goblins = false

	mobs.goblin_tunneling = function(self, type)
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

			if math.random() < 0.2 then
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

		if self.state == "stand" and math.random() < 0.2 then
			self.state = "tunnel"
		elseif self.state == "tunnel" and math.random() < 0.05 then
			self.state = "room"
		elseif self.state == "tunnel" and math.random() < 0.1 then
			self.state = "stand"
		end
	end

	mobs.search_replace = function(pos, search_rate, replace_rate, replace_what, replace_with)
		-- replace_rate is unnecessary, just replace one at a time.
		-- I only get to do one thing per step, so do they.
		if math.random(1, search_rate) == 1 then
			local p1 = vector.subtract(pos, 1)
			local p2 = vector.add(pos, 1)

			--look for nodes
			local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)

			if #nodelist > 0 then
				for key,value in pairs(nodelist) do 
					minetest.set_node(value, {name = replace_with})
					return  -- only one at a time
				end
			end
		end
	end

	mobs.goblin_drops = { "default:pick_steel",  "default:sword_steel", "default:shovel_steel", "farming:bread", "bucket:bucket_water", "default:pick_stone", "default:sword_stone" }

	dofile(path.."/goblin_cobbler.lua")
	dofile(path.."/goblin_copper.lua")
	dofile(path.."/goblin_coal.lua")
	dofile(path.."/goblin_diamond.lua")
	dofile(path.."/goblin_digger.lua")
	dofile(path.."/goblin_gold.lua")
	dofile(path.."/goblin_iron.lua")
	dofile(path.."/goblin_king.lua")
	dofile(path.."/goblin_traps.lua")

	minetest.register_node("mobs_goblins:mossycobble_trap", {
		description = "Messy Gobblestone",
		tiles = {"default_mossycobble.png"},
		is_ground_content = false,
		groups = {cracky = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		light_source =  4,
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

	minetest.log("action", "GOBLINS is lowdids!")
end
