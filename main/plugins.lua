---@diagnostic disable: lowercase-global
local json = require("main.json")

local PLUGIN_WATCHER = FileWatcher.new()

local POLL_EVERY = math.ceil(server.TPS / 4)
local pollCounter = 0

local doPrintsWithoutTime

local function getTimePrefix()
	if doPrintsWithoutTime then
		return ""
	end

	return "\27[30;1m[" .. os.date("%X") .. "]\27[0m "
end

local function printScoped(...)
	local prefix = "\27[34m[Plugins]\27[0m "
	print(getTimePrefix() .. prefix .. concatVarArgs("\t", ...))
end

local disabledPluginsFile = "disabledPlugins.json"

local disabledPluginsMap = {}
do
	local f = io.open(disabledPluginsFile, "r")
	if f then
		local array = json.decode(f:read("*all"))
		for _, name in ipairs(array) do
			disabledPluginsMap[name] = true
		end

		f:close()
	end
end

local function saveDisabledPlugins()
	local f = io.open(disabledPluginsFile, "w")
	if f then
		local array = {}
		for name, _ in pairs(disabledPluginsMap) do
			table.insert(array, name)
		end

		if #array == 0 then
			f:close()
			if os.remove(disabledPluginsFile) then
				printScoped("Removed " .. disabledPluginsFile)
			end
		else
			f:write(json.encode(array))
			f:close()
			printScoped("Exported to " .. disabledPluginsFile)
		end
	end
end

---@class Command
---@field info string What the command does.
---@field usage string? How to use the command.
---@field alias string[]? Aliases of the command.
---@field canCall (fun(player: Player): boolean)? Function which checks whether a player can call this command.
---@field autoComplete fun(args: string[])? Function which manipulates arguments when pressing tab in the terminal.
---@field call fun(player: Player, human?: Human, args: string[]) Calls the command.
---@field cooldownTime number? How many seconds a player has to wait before using the command again.

---@class PluginHookInfo
---@field func function The function to be called when the hook runs.
---@field priority number The priority of the hook, where lower priorities are executed first.
---@field name string The name of the plugin that owns the hook.

---@class Plugin
---@field name string The name of the plugin.
---@field author string The author of the plugin.
---@field description string The description of the plugin.
---@field hooks table<string, function>
---@field commands table<string, Command>
---@field defaultConfig table
---@field config table
---@field isEnabled boolean
---@field fileName string
---@field fullFileName string?
---@field doAutoReload boolean
---@field nameSpace string
---@field entryPath string
---@field polyHooks table<string, PluginHookInfo[]>
---For full hook documentation, see the docs at https://github.com/jpxs-intl/RosaServer/wiki/Hooks.
---@field addHook fun(self: Plugin, eventName: "AccountDeathTax", func: hooks.AccountDeathTaxHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "AccountTicketBegin", func: hooks.AccountTicketBeginHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "AccountTicketFound", func: hooks.AccountTicketFoundHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "AccountsSave", func: hooks.AccountsSaveHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "AreaCreateBlock", func: hooks.AreaCreateBlockHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "AreaDeleteBlock", func: hooks.AreaDeleteBlockHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "BulletCreate", func: hooks.BulletCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "BulletHitHuman", func: hooks.BulletHitHumanHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "BulletMayHit", func: hooks.BulletMayHitHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "BulletMayHitHuman", func: hooks.BulletMayHitHumanHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "CalculateEarShots", func: hooks.CalculateEarShotsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "CollideBodies", func: hooks.CollideBodiesHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ConsoleAutoComplete", func: hooks.ConsoleAutoCompleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ConsoleInput", func: hooks.ConsoleInputHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "CreateTraffic", func: hooks.CreateTrafficHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EconomyCarMarket", func: hooks.EconomyCarMarketHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventBullet", func: hooks.EventBulletHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventBulletHit", func: hooks.EventBulletHitHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventMessage", func: hooks.EventMessageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventSound", func: hooks.EventSoundHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventUpdateItemInfo", func: hooks.EventUpdateItemInfoHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventUpdatePlayerFinance", func: hooks.EventUpdatePlayerFinanceHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventUpdatePlayer", func: hooks.EventUpdatePlayerHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "EventUpdateVehicle", func: hooks.EventUpdateVehicleHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "GrenadeExplode", func: hooks.GrenadeExplodeHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "HumanCollisionVehicle", func: hooks.HumanCollisionVehicleHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "HumanCreate", func: hooks.HumanCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "HumanDamage", func: hooks.HumanDamageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "HumanDelete", func: hooks.HumanDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "HumanLimbInverseKinematics", func: hooks.HumanLimbInverseKinematicsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "InterruptSignal", func: hooks.InterruptSignalHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ItemComputerInput", func: hooks.ItemComputerInputHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ItemCreate", func: hooks.ItemCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ItemDelete", func: hooks.ItemDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ItemLink", func: hooks.ItemLinkHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LineIntersectHuman", func: hooks.LineIntersectHumanHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicCoop", func: hooks.LogicCoopHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicRace", func: hooks.LogicRaceHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicRound", func: hooks.LogicRoundHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicTerminator", func: hooks.LogicTerminatorHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicVersus", func: hooks.LogicVersusHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "LogicWorld", func: hooks.LogicWorldHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "Logic", func: hooks.LogicHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PacketBuilding", func: hooks.PacketBuildingHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PhysicsBullets", func: hooks.PhysicsBulletsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "Physics", func: hooks.PhysicsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PhysicsRigidBodies", func: hooks.PhysicsRigidBodiesHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerAI", func: hooks.PlayerAIHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerActions", func: hooks.PlayerActionsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerChat", func: hooks.PlayerChatHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerCreate", func: hooks.PlayerCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerDeathTax", func: hooks.PlayerDeathTaxHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerDelete", func: hooks.PlayerDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PlayerGiveWantedLevel", func: hooks.PlayerGiveWantedLevelHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostAccountDeathTax", func: hooks.PostAccountDeathTaxHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostAccountTicket", func: hooks.PostAccountTicketHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostAccountsSave", func: hooks.PostAccountsSaveHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostAreaCreateBlock", func: hooks.PostAreaCreateBlockHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostAreaDeleteBlock", func: hooks.PostAreaDeleteBlockHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostBulletCreate", func: hooks.PostBulletCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostCalculateEarShots", func: hooks.PostCalculateEarShotsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEconomyCarMarket", func: hooks.PostEconomyCarMarketHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventBullet", func: hooks.PostEventBulletHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventBulletHit", func: hooks.PostEventBulletHitHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventMessage", func: hooks.PostEventMessageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventSound", func: hooks.PostEventSoundHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventUpdateItemInfo", func: hooks.PostEventUpdateItemInfoHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventUpdatePlayerFinance", func: hooks.PostEventUpdatePlayerFinanceHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventUpdatePlayer", func: hooks.PostEventUpdatePlayerHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostEventUpdateVehicle", func: hooks.PostEventUpdateVehicleHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostGrenadeExplode", func: hooks.PostGrenadeExplodeHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostHumanCollisionVehicle", func: hooks.PostHumanCollisionVehicleHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostHumanCreate", func: hooks.PostHumanCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostHumanDamage", func: hooks.PostHumanDamageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostHumanDelete", func: hooks.PostHumanDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostHumanLimbInverseKinematics", func: hooks.PostHumanLimbInverseKinematicsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostInterruptSignal", func: hooks.PostInterruptSignalHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostItemComputerInput", func: hooks.PostItemComputerInputHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostItemCreate", func: hooks.PostItemCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostItemDelete", func: hooks.PostItemDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostItemLink", func: hooks.PostItemLinkHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLevelCreate", func: hooks.PostLevelCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLineIntersectHuman", func: hooks.PostLineIntersectHumanHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicCoop", func: hooks.PostLogicCoopHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicRace", func: hooks.PostLogicRaceHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicRound", func: hooks.PostLogicRoundHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicTerminator", func: hooks.PostLogicTerminatorHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicVersus", func: hooks.PostLogicVersusHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogicWorld", func: hooks.PostLogicWorldHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostLogic", func: hooks.PostLogicHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPacketBuilding", func: hooks.PostPacketBuildingHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPhysicsBullets", func: hooks.PostPhysicsBulletsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPhysics", func: hooks.PostPhysicsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPhysicsRigidBodies", func: hooks.PostPhysicsRigidBodiesHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerAI", func: hooks.PostPlayerAIHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerActions", func: hooks.PostPlayerActionsHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerChat", func: hooks.PostPlayerChatHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerCreate", func: hooks.PostPlayerCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerDeathTax", func: hooks.PostPlayerDeathTaxHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerDelete", func: hooks.PostPlayerDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostPlayerGiveWantedLevel", func: hooks.PostPlayerGiveWantedLevelHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostResetGame", func: hooks.PostResetGameHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostSendConnectResponse", func: hooks.PostSendConnectResponseHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostSendPacket", func: hooks.PostSendPacketHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostServerReceive", func: hooks.PostServerReceiveHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostServerSend", func: hooks.PostServerSendHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostTrafficCarAI", func: hooks.PostTrafficCarAIHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostTrafficCarDestination", func: hooks.PostTrafficCarDestinationHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostTrafficSimulation", func: hooks.PostTrafficSimulationHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostVehicleCreate", func: hooks.PostVehicleCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostVehicleDamage", func: hooks.PostVehicleDamageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "PostVehicleDelete", func: hooks.PostVehicleDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ResetGame", func: hooks.ResetGameHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "SendConnectResponse", func: hooks.SendConnectResponseHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "SendPacket", func: hooks.SendPacketHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ServerReceive", func: hooks.ServerReceiveHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "ServerSend", func: hooks.ServerSendHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "TrafficCarAI", func: hooks.TrafficCarAIHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "TrafficCarDestination", func: hooks.TrafficCarDestinationHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "TrafficSimulation", func: hooks.TrafficSimulationHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "VehicleCreate", func: hooks.VehicleCreateHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "VehicleDamage", func: hooks.VehicleDamageHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: "VehicleDelete", func: hooks.VehicleDeleteHook, options?: PluginHookOptions)
---@field addHook fun(self: Plugin, eventName: string, func: function, options?: PluginHookOptions)
local plugin = {}
plugin.__index = plugin

---Enable safely.
---@param shouldSave boolean? Whether to persist the plugin being enabled and save disabled plugins to disk.
function plugin:enable(shouldSave)
	if not self.isEnabled then
		self.isEnabled = true
		hook.resetCache()
		self:callEnableHandlers(false)

		if shouldSave then
			disabledPluginsMap[self.fileName] = nil
			saveDisabledPlugins()
		end
	end
end

---Disable safely.
---@param shouldSave boolean? Whether to persist the plugin being disabled and save disabled plugins to disk.
function plugin:disable(shouldSave)
	if self.isEnabled then
		self.isEnabled = false
		self:callDisableHandlers(false)
		hook.resetCache()

		if shouldSave then
			disabledPluginsMap[self.fileName] = true
			saveDisabledPlugins()
		end
	end
end

local acceptableColors = {}
do
	local i = 0
	for color = 17, 230 do
		if color % 6 < 4 then
			i = i + 1
			acceptableColors[i] = color
		end
	end
end

---@param name string
local function nameToColor(name)
	local sum = 0

	for i = 1, #name do
		sum = sum + name:byte(i) * 17
	end

	return acceptableColors[sum % #acceptableColors + 1]
end

---Print a message.
---@vararg any The values to print.
function plugin:print(...)
	if not self._printColor then
		self._printColor = nameToColor(self.name)
	end

	local color = self.nameSpace == "modes" and 248 or self._printColor
	local prefix = "\27[38;5;" .. color .. "m[" .. self.name .. "]\27[0m "
	print(getTimePrefix() .. prefix .. concatVarArgs("\t", ...))
end

---Print a warning message.
---@vararg any The values to print.
function plugin:warn(...)
	local prefix = "\27[33m[" .. self.name .. "]\27[0m "
	print(getTimePrefix() .. prefix .. concatVarArgs("\t", ...))
end

---Include another file.
---@param modName string The name of the module to include.
---@return any value The value returned by the file execution.
function plugin:require(modName)
	if not self.requireCache[modName] then
		local fileName = self.nameSpace .. "/" .. self.fileName .. "/" .. modName .. ".lua"
		local loadedFile = assert(loadfile(fileName))
		self.requireCache[modName] = loadedFile(self)
	end

	return self.requireCache[modName]
end

---@class PluginHookOptions
---@field priority number? The priority of the hook, where lower priorities are executed first. Default 0.

---Add a hook, where multiple hooks can be for the same event.
---@param eventName string The name of the event to be hooked.
---@param func function The function to be called when the hook runs.
---@param options? PluginHookOptions The options for the hook.
function plugin:addHook(eventName, func, options)
	if not self.polyHooks[eventName] then
		self.polyHooks[eventName] = {}
	end

	options = options or {}

	-- print(self.name .. ' is hooking ' .. eventName .. ' with priority ' .. (options.priority or 0))

	table.insert(self.polyHooks[eventName], {
		func = func,
		priority = options.priority or 0,
		name = self.name,
	})
end

---Add a callback for when the plugin is enabled.
---@param func fun(isReload: boolean) The function to be called when the plugin is enabled.
function plugin:addEnableHandler(func)
	table.insert(self.polyEnableHandlers, func)
end

function plugin:callEnableHandlers(isReload)
	for _, func in ipairs(self.polyEnableHandlers) do
		func(isReload)
	end
	self.onEnable(isReload)
end

---Add a callback for when the plugin is disabled.
---@param func fun(isReload: boolean) The function to be called when the plugin is disabled.
function plugin:addDisableHandler(func)
	table.insert(self.polyDisableHandlers, func)
end

function plugin:callDisableHandlers(isReload)
	self.onDisable(isReload)
	for _, func in ipairs(self.polyDisableHandlers) do
		func(isReload)
	end
end

function plugin:setConfig()
	self.config = {}

	-- Load default config
	for k, v in pairs(self.defaultConfig) do
		self.config[k] = v
	end

	-- Load config
	local conf = config[self.nameSpace][self.fileName]
	if conf then
		for k, v in pairs(conf) do
			self.config[k] = v
		end
	end
end

function plugin:load(isEnabled, isReload)
	local loadedFile = assert(loadfile(self.entryPath))

	loadedFile(self)
	self:setConfig()

	-- Mark as enabled
	self.isEnabled = isEnabled
	if self.isEnabled then
		hook.resetCache()
		self:callEnableHandlers(isReload)
	end
end

function plugin:reload()
	local isEnabled = self.isEnabled

	if isEnabled then
		self:callDisableHandlers(true)
	end

	self.hooks = {}
	self.polyHooks = {}
	self.polyEnableHandlers = {}
	self.polyDisableHandlers = {}
	self.commands = {}
	self.defaultConfig = {}
	self.requireCache = {}

	hook.resetCache()

	self:load(isEnabled, true)

	hook.resetCache()
end

---Indicate the plugin has been enabled.
---@param isReload boolean
---@private
function plugin.onEnable(isReload) end

---Indicate the plugin has been disabled.
---@param isReload boolean
---@private
function plugin.onDisable(isReload) end

local function newPlugin(nameSpace, stem)
	return setmetatable({
		name = "Unknown",
		author = "Unknown",
		description = "n/a",
		---@deprecated
		hooks = {},
		polyHooks = {},
		polyEnableHandlers = {},
		polyDisableHandlers = {},
		commands = {},
		defaultConfig = {},
		config = {},
		isEnabled = true,
		requireCache = {},
		nameSpace = nameSpace,
		fileName = stem,
		doAutoReload = false,
	}, plugin)
end

local function discoverInNameSpace(nameSpace, isEnabledFunc)
	local numLoaded = 0

	local entries = os.listDirectory(nameSpace)
	for _, entry in ipairs(entries) do
		if (entry.isDirectory or entry.extension == ".lua") and not hook.plugins[entry.stem] then
			local plug = newPlugin(nameSpace, entry.stem)

			if entry.isDirectory then
				plug.entryPath = nameSpace .. "/" .. entry.stem .. "/init.lua"
				PLUGIN_WATCHER:addWatch(nameSpace .. "/" .. entry.stem, FILE_WATCH_MODIFY)
			else
				plug.entryPath = nameSpace .. "/" .. entry.name
				plug.fullFileName = entry.name
			end

			hook.plugins[entry.stem] = plug

			local isEnabled = isEnabledFunc(plug)

			printScoped(string.format("Loading \27[30;1m%s.\27[0m%s", nameSpace, entry.stem))
			plug:load(isEnabled, false)

			numLoaded = numLoaded + 1
		end
	end

	return numLoaded
end

local function loadPluginNameSpace(nameSpace, isEnabledFunc)
	printScoped("Loading " .. nameSpace .. "...")

	local numLoaded = discoverInNameSpace(nameSpace, isEnabledFunc)
	printScoped("Loaded " .. numLoaded .. " " .. nameSpace)

	PLUGIN_WATCHER:addWatch(nameSpace, FILE_WATCH_MODIFY)
end

local function shouldStartPluginEnabled(plug)
	return not disabledPluginsMap[plug.fileName]
end

local function shouldStartModeEnabled(plug)
	return plug.fileName == hook.persistentMode
end

local function loadPlugins()
	if hook.persistentMode == "" then
		hook.persistentMode = config.defaultGameMode
	end

	loadPluginNameSpace("plugins", shouldStartPluginEnabled)
	loadPluginNameSpace("modes", shouldStartModeEnabled)

	hook.resetCache()
end

---Discover and load any plugins that weren't present at startup.
---@return integer numLoaded
function discoverNewPlugins()
	return discoverInNameSpace("plugins", shouldStartPluginEnabled)
		+ discoverInNameSpace("modes", shouldStartModeEnabled)
end

local function reloadConfigOfPlugins()
	for _, plug in pairs(hook.plugins) do
		plug:setConfig()
	end
end

hook.add(
	"ConfigLoaded",
	"main.plugins",
	---@param isReload boolean
	function(isReload)
		doPrintsWithoutTime = config.doPrintsWithoutTime

		if not isReload then
			loadPlugins()
		else
			reloadConfigOfPlugins()
		end
	end
)

---@param descriptor string
---@param fullFileName string
---@return Plugin?
local function findModifiedPlugin(descriptor, fullFileName)
	for _, plug in pairs(hook.plugins) do
		if plug.nameSpace == descriptor and plug.fullFileName == fullFileName then
			return plug
		end

		if plug.nameSpace .. "/" .. plug.fileName == descriptor then
			return plug
		end
	end
	return nil
end

local function pollEvents()
	while true do
		local event = PLUGIN_WATCHER:receiveEvent()
		if not event then
			return
		end

		local plug = findModifiedPlugin(event.descriptor, event.name)
		if plug and plug.doAutoReload then
			printScoped(("Watched plugin %s has changed! Reloading..."):format(plug.name))
			plug:reload()
		end
	end
end

hook.add("Logic", "main.plugins", function()
	pollCounter = pollCounter + 1
	if pollCounter > POLL_EVERY then
		pollCounter = 0
		pollEvents()
	end
end)
