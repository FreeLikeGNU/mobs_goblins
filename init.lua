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
		local pos = self.object:getpos()
		-- This translates yaw into vectors.
		local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}
		-- Yaw is stored as one of the four cardinal directions.
		local yaw = (math.floor(self.object:getyaw() * 2 / math.pi + 0.5) % 4)

		-- Initialize the properties.
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
			-- Returning true uses the basic mobs movement.
			return true
		elseif self.digging_state == "tunnel" then
			yaw = self.digging_dir
			-- Turn him roughly in the right direction.
			self.object:setyaw(yaw * math.pi * 0.5 + math.random() * 0.5 - 0.25)

			-- Get a pair of coordinates that should cover what's in front of him.
			local p = vector.add(pos, cardinals[yaw+1])
			p.y = p.y -0.5
			local p1 = vector.add(p, -0.3)
			local p2 = vector.add(p, 0.3)
			-- Get any diggable nodes in that area.
			local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

			if #np_list > 0 then
				-- Dig it.
				for _, np in pairs(np_list) do
					minetest.remove_node(np)
				end
			else
				-- If we can't dig, turn right or left.
				if math.random(2) == 1 then
					self.object:setyaw(((yaw + 1) % 4) * math.pi * 0.5 + math.random() * 0.5 - 0.25)
				else
					self.object:setyaw(((yaw - 1) % 4) * math.pi * 0.5 + math.random() * 0.5 - 0.25)
				end
			end
			-- Walk, regardless.
			self:set_animation("walk")
			self.set_velocity(self, self.walk_velocity)

			-- What to do next...?
			--  The other probabilities have to be low, because tunneling is
			--   too inefficient.
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
		elseif self.digging_state == "room" then  -- Dig a room.
			self:set_animation("stand")
			local go_on = true
			-- Work from the inside, out.
			for r = 1,self.room_radius do
				-- Get a pair of coordinates that form a room.
				local p1 = vector.add(pos, -r)
				p1.y = pos.y
				local p2 = vector.add(pos, r)
				local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

				if #np_list > 0 then
					-- Dig it.
					minetest.remove_node(np_list[math.random(#np_list)])
				end

				-- Leave the outer cube less finished. They're goblins.
				--  (The surface of a sphere is proportional to r^2.)
				if r >= self.room_radius and #np_list < (r * r * 0.2) then
					self.room_radius = math.random(1,2) + math.random(0,1)
					self.digging_state = "coffee_break"
					return true
				end
			end
		end

		-- Do not use the standard movement.
		return false
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

	dofile(path.."/goblin_digger.lua")
	dofile(path.."/goblin_cobbler.lua")
	dofile(path.."/goblin_coal.lua")
	dofile(path.."/goblin_iron.lua")
	dofile(path.."/goblin_gold.lua")
	dofile(path.."/goblin_diamond.lua")
	dofile(path.."/goblin_king.lua")
	dofile(path.."/goblin_traps.lua")

	minetest.log("action", "GOBLINS is lowdids!")
end
