---@type Plugin
local plugin = ...

---@param item Item
---@param difference Vector
local function moveItem(item, difference)
	item.pos:add(difference)
	item.rigidBody.pos:add(difference)
end

---@param man Human
---@param pos Vector
---@diagnostic disable-next-line: lowercase-global
function teleportHumanWithItems(man, pos)
	local oldPos = man.pos:clone()
	oldPos:mult(-1.0)
	local difference = pos:clone()
	difference:add(oldPos)

	man:teleport(pos)
	for i = 0, 1 do
		local item = man:getInventorySlot(i).primaryItem
		if item then
			moveItem(item, difference)
		end
	end
end

plugin.commands["/find"] = {
	info = "Teleport to a player.",
	usage = "<phoneNumber/name>",
	canCall = function(ply)
		return isModeratorOrAdmin(ply)
	end,
	call = function(ply, man, args)
		assert(#args >= 1, "usage")
		assert(man, "Not spawned in")

		local victim = findOnePlayer(table.remove(args, 1))
		local victimMan = victim.human
		assert(victimMan, "Victim not spawned in")

		-- Forward yaw plus 180 degrees
		local yaw = victimMan.viewYaw + math.pi / 2
		local distance = 3

		local pos = victimMan.pos:clone()
		pos.x = pos.x + (distance * math.cos(yaw))
		pos.z = pos.z + (distance * math.sin(yaw))

		if man.vehicle ~= nil then
			man.vehicle = nil
		end
		teleportHumanWithItems(man, pos)

		if victimMan.vehicle ~= nil then
			man.vehicle = victimMan.vehicle
			man.vehicleSeat = 3
		end

		adminLog("%s found %s (%s)", ply.name, victim.name, dashPhoneNumber(victim.phoneNumber))
	end,
}

plugin.commands["/fetch"] = {
	info = "Teleport a player to you.",
	usage = "<phoneNumber/name>",
	canCall = function(ply)
		return isModeratorOrAdmin(ply)
	end,
	---@param ply Player
	---@param man Human?
	---@param args string[]
	call = function(ply, man, args)
		assert(#args >= 1, "usage")
		assert(man, "Not spawned in")

		local victim = findOnePlayer(table.remove(args, 1))

		local victimMan = victim.human
		assert(victimMan, "Victim not spawned in")

		-- Forward yaw
		local yaw = man.viewYaw - math.pi / 2
		local distance = 3

		local pos = man.pos:clone()
		pos.x = pos.x + (distance * math.cos(yaw))
		pos.z = pos.z + (distance * math.sin(yaw))

		teleportHumanWithItems(victimMan, pos)

		if man.vehicle ~= nil then
			victimMan.vehicle = man.vehicle
			victimMan.vehicleSeat = 3
		end

		adminLog("%s fetched %s (%s)", ply.name, victim.name, dashPhoneNumber(victim.phoneNumber))
	end,
}

plugin.commands["/hide"] = {
	info = "Teleport to an inaccessible room.",
	canCall = function(ply)
		return ply.isAdmin
	end,
	---@param ply Player
	---@param man Human?
	call = function(ply, man)
		assert(man, "Not spawned in")

		local level = server.loadedLevel
		local pos

		if level == "test2" then
			pos = Vector(1505, 33.1, 1315)
		else
			error("Unsupported map")
		end

		teleportHumanWithItems(man, pos)

		adminLog("%s hid", ply.name)
	end,
}
