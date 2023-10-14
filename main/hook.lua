--- all hooks
--- @type table<string, table<string, function>>
local _hooks = {}

--- all temporary hooks, for hook.once
--- @type table<string, function[]>
local _tempHooks = {}

--- Cache of enabled hooks
--- @type table<string, function[]>
local _cache = {}

---@class FunctionData
---@field name string
---@field eventName string

--- keeps name of each function for debugging
--- @type table<function, FunctionData>
hook._functionData = {}

---@class HookRunInfo
---@field time number
---@field name string

--- @class HookInfo
---@field time number
---@field runs table<string, HookRunInfo>

---keeps track of last run info
--- @type table<string, table<HookInfo>>
hook._lastRunInfo = {}

local IS_DEBUG = true

local pairs = pairs
local ipairs = ipairs

local CONTINUE = 1
local OVERRIDE = 2

---@alias HookReturn 1 | 2 | nil
---@alias HookNoOverride 1 | nil

---@class ConsoleAutoCompleteData
---@field response string If data.response is changed, the console's current buffer will be changed to that string.

---@class SendConnectResponseData
---@field message string data.message can be changed to alter the message that is sent.

---Stops further hooks of this type from running.
hook.continue = CONTINUE
---Stops further hooks and overrides default game functionality.
hook.override = OVERRIDE

---The currently loaded plugins.
---@type table<string, Plugin>
hook.plugins = {}

---Regenerate the cache of enabled hooks.
function hook.resetCache()
	hook.clear()
	_cache = {}

	local enable = hook.enable

	for event, funcs in pairs(_hooks) do
		enable(event)
		_cache[event] = {}
		for _, func in pairs(funcs) do
			table.insert(_cache[event], func)
		end
	end

	local sortingHooks = {}

	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for event, func in pairs(plugin.hooks) do
				if _cache[event] == nil then
					enable(event)
					_cache[event] = {}
				end
				table.insert(_cache[event], func)
			end

			for event, infos in pairs(plugin.polyHooks) do
				if sortingHooks[event] == nil then
					sortingHooks[event] = {}
				end

				for _, info in ipairs(infos) do
					table.insert(sortingHooks[event], info)

					if IS_DEBUG then
						hook._functionData[info.func] = {
							name = info.name,
							eventName = event,
						}

						-- print('Added hook', info.name, 'for event', event)
					end
				end
			end
		end
	end

	for event, infos in pairs(sortingHooks) do
		if _cache[event] == nil then
			enable(event)
			_cache[event] = {}
		end

		table.sort(infos, function(a, b)
			return a.priority < b.priority
		end)

		for _, info in ipairs(infos) do
			table.insert(_cache[event], info.func)
		end
	end
end

---@class HookGlobal
---@field add fun(eventName: "AccountDeathTax", name: string, func: hooks.AccountDeathTaxHook)
---@field add fun(eventName: "AccountTicketBegin", name: string, func: hooks.AccountTicketBeginHook)
---@field add fun(eventName: "AccountTicketFound", name: string, func: hooks.AccountTicketFoundHook)
---@field add fun(eventName: "AccountsSave", name: string, func: hooks.AccountsSaveHook)
---@field add fun(eventName: "AreaCreateBlock", name: string, func: hooks.AreaCreateBlockHook)
---@field add fun(eventName: "AreaDeleteBlock", name: string, func: hooks.AreaDeleteBlockHook)
---@field add fun(eventName: "BulletCreate", name: string, func: hooks.BulletCreateHook)
---@field add fun(eventName: "BulletHitHuman", name: string, func: hooks.BulletHitHumanHook)
---@field add fun(eventName: "BulletMayHit", name: string, func: hooks.BulletMayHitHook)
---@field add fun(eventName: "BulletMayHitHuman", name: string, func: hooks.BulletMayHitHumanHook)
---@field add fun(eventName: "CalculateEarShots", name: string, func: hooks.CalculateEarShotsHook)
---@field add fun(eventName: "CollideBodies", name: string, func: hooks.CollideBodiesHook)
---@field add fun(eventName: "ConsoleAutoComplete", name: string, func: hooks.ConsoleAutoCompleteHook)
---@field add fun(eventName: "ConsoleInput", name: string, func: hooks.ConsoleInputHook)
---@field add fun(eventName: "CreateTraffic", name: string, func: hooks.CreateTrafficHook)
---@field add fun(eventName: "EconomyCarMarket", name: string, func: hooks.EconomyCarMarketHook)
---@field add fun(eventName: "EventBullet", name: string, func: hooks.EventBulletHook)
---@field add fun(eventName: "EventBulletHit", name: string, func: hooks.EventBulletHitHook)
---@field add fun(eventName: "EventMessage", name: string, func: hooks.EventMessageHook)
---@field add fun(eventName: "EventSound", name: string, func: hooks.EventSoundHook)
---@field add fun(eventName: "EventUpdateItemInfo", name: string, func: hooks.EventUpdateItemInfoHook)
---@field add fun(eventName: "EventUpdatePlayerFinance", name: string, func: hooks.EventUpdatePlayerFinanceHook)
---@field add fun(eventName: "EventUpdatePlayer", name: string, func: hooks.EventUpdatePlayerHook)
---@field add fun(eventName: "EventUpdateVehicle", name: string, func: hooks.EventUpdateVehicleHook)
---@field add fun(eventName: "GrenadeExplode", name: string, func: hooks.GrenadeExplodeHook)
---@field add fun(eventName: "HumanCollisionVehicle", name: string, func: hooks.HumanCollisionVehicleHook)
---@field add fun(eventName: "HumanCreate", name: string, func: hooks.HumanCreateHook)
---@field add fun(eventName: "HumanDamage", name: string, func: hooks.HumanDamageHook)
---@field add fun(eventName: "HumanDelete", name: string, func: hooks.HumanDeleteHook)
---@field add fun(eventName: "HumanLimbInverseKinematics", name: string, func: hooks.HumanLimbInverseKinematicsHook)
---@field add fun(eventName: "InterruptSignal", name: string, func: hooks.InterruptSignalHook)
---@field add fun(eventName: "ItemComputerInput", name: string, func: hooks.ItemComputerInputHook)
---@field add fun(eventName: "ItemCreate", name: string, func: hooks.ItemCreateHook)
---@field add fun(eventName: "ItemDelete", name: string, func: hooks.ItemDeleteHook)
---@field add fun(eventName: "ItemLink", name: string, func: hooks.ItemLinkHook)
---@field add fun(eventName: "LineIntersectHuman", name: string, func: hooks.LineIntersectHumanHook)
---@field add fun(eventName: "LogicCoop", name: string, func: hooks.LogicCoopHook)
---@field add fun(eventName: "LogicRace", name: string, func: hooks.LogicRaceHook)
---@field add fun(eventName: "LogicRound", name: string, func: hooks.LogicRoundHook)
---@field add fun(eventName: "LogicTerminator", name: string, func: hooks.LogicTerminatorHook)
---@field add fun(eventName: "LogicVersus", name: string, func: hooks.LogicVersusHook)
---@field add fun(eventName: "LogicWorld", name: string, func: hooks.LogicWorldHook)
---@field add fun(eventName: "Logic", name: string, func: hooks.LogicHook)
---@field add fun(eventName: "PacketBuilding", name: string, func: hooks.PacketBuildingHook)
---@field add fun(eventName: "PhysicsBullets", name: string, func: hooks.PhysicsBulletsHook)
---@field add fun(eventName: "Physics", name: string, func: hooks.PhysicsHook)
---@field add fun(eventName: "PhysicsRigidBodies", name: string, func: hooks.PhysicsRigidBodiesHook)
---@field add fun(eventName: "PlayerAI", name: string, func: hooks.PlayerAIHook)
---@field add fun(eventName: "PlayerActions", name: string, func: hooks.PlayerActionsHook)
---@field add fun(eventName: "PlayerChat", name: string, func: hooks.PlayerChatHook)
---@field add fun(eventName: "PlayerCreate", name: string, func: hooks.PlayerCreateHook)
---@field add fun(eventName: "PlayerDeathTax", name: string, func: hooks.PlayerDeathTaxHook)
---@field add fun(eventName: "PlayerDelete", name: string, func: hooks.PlayerDeleteHook)
---@field add fun(eventName: "PlayerGiveWantedLevel", name: string, func: hooks.PlayerGiveWantedLevelHook)
---@field add fun(eventName: "PostAccountDeathTax", name: string, func: hooks.PostAccountDeathTaxHook)
---@field add fun(eventName: "PostAccountTicket", name: string, func: hooks.PostAccountTicketHook)
---@field add fun(eventName: "PostAccountsSave", name: string, func: hooks.PostAccountsSaveHook)
---@field add fun(eventName: "PostAreaCreateBlock", name: string, func: hooks.PostAreaCreateBlockHook)
---@field add fun(eventName: "PostAreaDeleteBlock", name: string, func: hooks.PostAreaDeleteBlockHook)
---@field add fun(eventName: "PostBulletCreate", name: string, func: hooks.PostBulletCreateHook)
---@field add fun(eventName: "PostCalculateEarShots", name: string, func: hooks.PostCalculateEarShotsHook)
---@field add fun(eventName: "PostEconomyCarMarket", name: string, func: hooks.PostEconomyCarMarketHook)
---@field add fun(eventName: "PostEventBullet", name: string, func: hooks.PostEventBulletHook)
---@field add fun(eventName: "PostEventBulletHit", name: string, func: hooks.PostEventBulletHitHook)
---@field add fun(eventName: "PostEventMessage", name: string, func: hooks.PostEventMessageHook)
---@field add fun(eventName: "PostEventSound", name: string, func: hooks.PostEventSoundHook)
---@field add fun(eventName: "PostEventUpdateItemInfo", name: string, func: hooks.PostEventUpdateItemInfoHook)
---@field add fun(eventName: "PostEventUpdatePlayerFinance", name: string, func: hooks.PostEventUpdatePlayerFinanceHook)
---@field add fun(eventName: "PostEventUpdatePlayer", name: string, func: hooks.PostEventUpdatePlayerHook)
---@field add fun(eventName: "PostEventUpdateVehicle", name: string, func: hooks.PostEventUpdateVehicleHook)
---@field add fun(eventName: "PostGrenadeExplode", name: string, func: hooks.PostGrenadeExplodeHook)
---@field add fun(eventName: "PostHumanCollisionVehicle", name: string, func: hooks.PostHumanCollisionVehicleHook)
---@field add fun(eventName: "PostHumanCreate", name: string, func: hooks.PostHumanCreateHook)
---@field add fun(eventName: "PostHumanDamage", name: string, func: hooks.PostHumanDamageHook)
---@field add fun(eventName: "PostHumanDelete", name: string, func: hooks.PostHumanDeleteHook)
---@field add fun(eventName: "PostHumanLimbInverseKinematics", name: string, func: hooks.PostHumanLimbInverseKinematicsHook)
---@field add fun(eventName: "PostInterruptSignal", name: string, func: hooks.PostInterruptSignalHook)
---@field add fun(eventName: "PostItemComputerInput", name: string, func: hooks.PostItemComputerInputHook)
---@field add fun(eventName: "PostItemCreate", name: string, func: hooks.PostItemCreateHook)
---@field add fun(eventName: "PostItemDelete", name: string, func: hooks.PostItemDeleteHook)
---@field add fun(eventName: "PostItemLink", name: string, func: hooks.PostItemLinkHook)
---@field add fun(eventName: "PostLevelCreate", name: string, func: hooks.PostLevelCreateHook)
---@field add fun(eventName: "PostLineIntersectHuman", name: string, func: hooks.PostLineIntersectHumanHook)
---@field add fun(eventName: "PostLogicCoop", name: string, func: hooks.PostLogicCoopHook)
---@field add fun(eventName: "PostLogicRace", name: string, func: hooks.PostLogicRaceHook)
---@field add fun(eventName: "PostLogicRound", name: string, func: hooks.PostLogicRoundHook)
---@field add fun(eventName: "PostLogicTerminator", name: string, func: hooks.PostLogicTerminatorHook)
---@field add fun(eventName: "PostLogicVersus", name: string, func: hooks.PostLogicVersusHook)
---@field add fun(eventName: "PostLogicWorld", name: string, func: hooks.PostLogicWorldHook)
---@field add fun(eventName: "PostLogic", name: string, func: hooks.PostLogicHook)
---@field add fun(eventName: "PostPacketBuilding", name: string, func: hooks.PostPacketBuildingHook)
---@field add fun(eventName: "PostPhysicsBullets", name: string, func: hooks.PostPhysicsBulletsHook)
---@field add fun(eventName: "PostPhysics", name: string, func: hooks.PostPhysicsHook)
---@field add fun(eventName: "PostPhysicsRigidBodies", name: string, func: hooks.PostPhysicsRigidBodiesHook)
---@field add fun(eventName: "PostPlayerAI", name: string, func: hooks.PostPlayerAIHook)
---@field add fun(eventName: "PostPlayerActions", name: string, func: hooks.PostPlayerActionsHook)
---@field add fun(eventName: "PostPlayerChat", name: string, func: hooks.PostPlayerChatHook)
---@field add fun(eventName: "PostPlayerCreate", name: string, func: hooks.PostPlayerCreateHook)
---@field add fun(eventName: "PostPlayerDeathTax", name: string, func: hooks.PostPlayerDeathTaxHook)
---@field add fun(eventName: "PostPlayerDelete", name: string, func: hooks.PostPlayerDeleteHook)
---@field add fun(eventName: "PostPlayerGiveWantedLevel", name: string, func: hooks.PostPlayerGiveWantedLevelHook)
---@field add fun(eventName: "PostResetGame", name: string, func: hooks.PostResetGameHook)
---@field add fun(eventName: "PostSendConnectResponse", name: string, func: hooks.PostSendConnectResponseHook)
---@field add fun(eventName: "PostSendPacket", name: string, func: hooks.PostSendPacketHook)
---@field add fun(eventName: "PostServerReceive", name: string, func: hooks.PostServerReceiveHook)
---@field add fun(eventName: "PostServerSend", name: string, func: hooks.PostServerSendHook)
---@field add fun(eventName: "PostTrafficCarAI", name: string, func: hooks.PostTrafficCarAIHook)
---@field add fun(eventName: "PostTrafficCarDestination", name: string, func: hooks.PostTrafficCarDestinationHook)
---@field add fun(eventName: "PostTrafficSimulation", name: string, func: hooks.PostTrafficSimulationHook)
---@field add fun(eventName: "PostVehicleCreate", name: string, func: hooks.PostVehicleCreateHook)
---@field add fun(eventName: "PostVehicleDamage", name: string, func: hooks.PostVehicleDamageHook)
---@field add fun(eventName: "PostVehicleDelete", name: string, func: hooks.PostVehicleDeleteHook)
---@field add fun(eventName: "ResetGame", name: string, func: hooks.ResetGameHook)
---@field add fun(eventName: "SendConnectResponse", name: string, func: hooks.SendConnectResponseHook)
---@field add fun(eventName: "SendPacket", name: string, func: hooks.SendPacketHook)
---@field add fun(eventName: "ServerReceive", name: string, func: hooks.ServerReceiveHook)
---@field add fun(eventName: "ServerSend", name: string, func: hooks.ServerSendHook)
---@field add fun(eventName: "TrafficCarAI", name: string, func: hooks.TrafficCarAIHook)
---@field add fun(eventName: "TrafficCarDestination", name: string, func: hooks.TrafficCarDestinationHook)
---@field add fun(eventName: "TrafficSimulation", name: string, func: hooks.TrafficSimulationHook)
---@field add fun(eventName: "VehicleCreate", name: string, func: hooks.VehicleCreateHook)
---@field add fun(eventName: "VehicleDamage", name: string, func: hooks.VehicleDamageHook)
---@field add fun(eventName: "VehicleDelete", name: string, func: hooks.VehicleDeleteHook)
---@field add fun(eventName: string, name: string, func: function)

---Add a generic named hook.
---@param eventName string The name of the event to be hooked.
---@param name string The unique name of the new hook.
---@param func function The function to be called when the hook runs.
function hook.add(eventName, name, func)
	assert(type(eventName) == 'string')
	assert(type(func) == 'function')

	if _hooks[eventName] == nil then
		_hooks[eventName] = {}
	end

	_hooks[eventName][name] = func
	if IS_DEBUG then
		hook._functionData[func] = {
			name = name,
			eventName = eventName,
		}
	end

	hook.resetCache()
end

---Add a generic hook to be run once.
---@param eventName string The name of the event to be hooked.
---@param func function The function to be called once when the hook runs.
function hook.once(eventName, func)
	assert(type(eventName) == 'string')
	assert(type(func) == 'function')

	if _tempHooks[eventName] == nil then
		_tempHooks[eventName] = {}
	end

	table.insert(_tempHooks[eventName], func)
	hook.enable(eventName)
end

---Remove a generic named hook.
---@param eventName string The name of the event to be hooked.
---@param name string The unique name of the hook to remove.
function hook.remove(eventName, name)
	assert(type(eventName) == 'string')
	if _hooks[eventName] == nil then return end

	_hooks[eventName][name] = nil
	hook.resetCache()
end

---Run a hook.
---@param eventName string The name of the event.
---@vararg any The arguments to pass to the hook functions.
---@return boolean override Whether default behaviour should be overridden, if applicable.
function hook.run(eventName, ...)
	local hadTemp = false

	local hookInfo = {
		eventName = eventName,
		arguments = { ... },
		runs = {}
	}

	local hookTotalStart = os.clock()
	if _tempHooks[eventName] ~= nil then
		local _tempOverride = false
		for _, tempHookFunc in ipairs(_tempHooks[eventName]) do
			local hookStart = os.clock()

			local isOverride = tempHookFunc(...)

			local diff = os.clock() - hookStart

			local funcInfo = hook._functionData[tempHookFunc]

			table.insert(hookInfo.runs, {
				time = diff,
				name = funcInfo and funcInfo.name or 'unknown',
			})

			if isOverride then
				_tempOverride = true
				break
			end
		end
		_tempHooks[eventName] = nil
		if _tempOverride then
			return true
		end
		hadTemp = true
	end

	local cache = _cache[eventName]
	if cache ~= nil then
		for _, hookFunc in pairs(cache) do
			local hookStart = os.clock()

			local res = hookFunc(...)

			local diff = os.clock() - hookStart

			local funcInfo = hook._functionData[hookFunc]

			table.insert(hookInfo.runs, {
				time = diff,
				name = funcInfo and funcInfo.name or 'unknown',
			})

			if res == CONTINUE then
				return false
			end
			if res == OVERRIDE then
				return true
			end
		end

		local diff = os.clock() - hookTotalStart

		hook._lastRunInfo[eventName] = {
			time = diff,
			runs = hookInfo.runs,
		}
	elseif hadTemp then
		hook.disable(eventName)
	end

	return false
end

---Check whether someone is allowed to run a command.
---@param name string The name of the command.
---@param command table The command table.
---@param plyOrArgs Player|table The calling player, or a table of arguments if it is a console command.
---@return boolean canCall Whether the command can be called given the conditions.
function hook.canCallCommand(name, command, plyOrArgs)
	if not name:startsWith('/') then
		-- This is a console-only command
		return type(plyOrArgs) == 'table'
	else
		if command.canCall then
			return not not command.canCall(plyOrArgs)
		else
			return true
		end
	end
end

local function callCommand(name, command, plyOrArgs, ...)
	if not hook.canCallCommand(name, command, plyOrArgs) then
		error('Access denied')
	end

	command.call(plyOrArgs, ...)
end

---Get all enabled commands.
---@return table commands The name of each command mapped to their command table.
function hook.getCommands()
	local commands = {}

	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, command in pairs(plugin.commands) do
				commands[name] = command
			end
		end
	end

	return commands
end

---Find a command by its name or alias.
---@param name string The name or alias of the command to find.
---@return table? command The found command, if any.
function hook.findCommand(name)
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			local command = plugin.commands[name]
			if command then
				return command
			end

			for _, c in pairs(plugin.commands) do
				if c.alias and table.contains(c.alias, name) then
					return c
				end
			end
		end
	end

	return nil
end

local function commandNameStartsWith(name, beginning)
	if name:startsWith(beginning) then
		return true
	end

	if name:startsWith('/') then
		return name:sub(2):startsWith(beginning)
	end

	return false
end

---Auto complete a command by its name or alias.
---@param beginning string The name to auto complete.
---@return string? name The full name of the found command, if any.
---@return table? command The found command, if any.
function hook.autoCompleteCommand(beginning)
	--- Check raw names first
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, c in pairs(plugin.commands) do
				if commandNameStartsWith(name, beginning) then
					return name, c
				end
			end
		end
	end

	--- Check aliases, auto complete with raw name anyway
	for _, plugin in pairs(hook.plugins) do
		if plugin.isEnabled then
			for name, c in pairs(plugin.commands) do
				if c.alias then
					for _, alias in ipairs(c.alias) do
						if commandNameStartsWith(alias, beginning) then
							return name, c
						end
					end
				end
			end
		end
	end

	return nil, nil
end

---Auto complete a plugin by its file name or alias.
---@param beginning string The name to auto complete.
---@param nameSpace string? The plugin name space to limit the search to.
---@return string? name The full file name of the found plugin, if any.
---@return Plugin? plugin The found plugin, if any.
function hook.autoCompletePlugin(beginning, nameSpace)
	beginning = beginning:lower()

	for _, plugin in pairs(hook.plugins) do
		if (not nameSpace or plugin.nameSpace == nameSpace) and plugin.fileName:lower():startsWith(beginning) then
			return plugin.fileName, plugin
		end
	end

	return nil, nil
end

---Find a plugin by its file name.
---@param name string The name of the desired plugin.
---@param nameSpace string? The plugin name space to limit the search to.
---@return Plugin? plugin The found plugin, if any.
function hook.getPluginByName(name, nameSpace)
	name = name:lower()

	for _, plugin in pairs(hook.plugins) do
		if (not nameSpace or plugin.nameSpace == nameSpace) and plugin.fileName:lower() == name then
			return plugin
		end
	end

	return nil
end

---Run a command.
---@param name string The name of the command being passed.
---@param command table? The command to run, usually the result of hook.findCommand.
---@vararg any The rest of the parameters the command expects.
---@see hook.findCommand
function hook.runCommand(name, command, ...)
	if command ~= nil then
		callCommand(name, command, ...)
		return true
	end

	return false
end
