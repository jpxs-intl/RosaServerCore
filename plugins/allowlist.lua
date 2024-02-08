---@diagnostic disable: lowercase-global
---@type Plugin
local plugin = ...
plugin.name = "Allowlist"
plugin.author = "jdb"
plugin.description = "Only let in certain players."

plugin.defaultConfig = {
	-- How many people can be let in regardless of if they're allowlisted
	maxPublicSlots = 0,
}

local json = require("main.json")

local allowlistPath = "allowlist.json"
local legacyPath = "whitelist.json"

---@type integer[]?
local allowlistedPhoneNumbers

local function getAllowlistIndex(phoneNumber)
	assert(allowlistedPhoneNumbers)
	for i, p in ipairs(allowlistedPhoneNumbers) do
		if p == phoneNumber then
			return i
		end
	end
	return nil
end

---Check if a phone number is in the allowlist.
---@param phoneNumber integer The phone number to check.
---@return boolean isAllowlisted
function isNumberAllowlisted(phoneNumber)
	if not plugin.isEnabled then
		return false
	end

	local data = {
		allowlisted = getAllowlistIndex(phoneNumber) ~= nil,
	}

	if hook.run("AllowlistCheck", phoneNumber, data) then
		return false
	end

	return not not data.allowlisted
end

local isNumberAllowlisted = isNumberAllowlisted

local function saveAllowlist()
	assert(allowlistedPhoneNumbers)
	local f, errorMessage = io.open(allowlistPath, "w")
	if f then
		f:write(json.encode(allowlistedPhoneNumbers))
		f:close()
		plugin:print("Saved phone numbers")
	else
		plugin:warn("Could not save phone numbers: " .. errorMessage)
	end
end

plugin:addEnableHandler(function()
	local f, errorMessage = io.open(allowlistPath, "r")
	if f then
		allowlistedPhoneNumbers = json.decode(f:read("*a"))
		f:close()
		plugin:print("Loaded " .. #allowlistedPhoneNumbers .. " phone numbers")
	else
		allowlistedPhoneNumbers = {}
		plugin:warn("Could not load phone numbers: " .. errorMessage)
	end

	local legF = io.open(legacyPath, "r")
	if legF then
		for _, v in pairs(json.decode(legF:read("*a"))) do
			table.insert(allowlistedPhoneNumbers, v)
		end
		legF:close()
		plugin:print("Imported legacy allowlist data. Total numbers: " .. #allowlistedPhoneNumbers)

		os.remove(legacyPath)
	end
end)

plugin:addDisableHandler(function()
	allowlistedPhoneNumbers = nil
end)

plugin:addHook("AccountTicketFound", function(acc)
	local maxPublicSlots = plugin.config.maxPublicSlots
	local playerCount = #players.getNonBots()

	if playerCount >= maxPublicSlots then
		if acc then
			if isNumberAllowlisted(acc.phoneNumber) then
				-- Let it through
				return
			end

			hook.once("SendConnectResponse", function(_, _, data)
				if maxPublicSlots == 0 then
					data.message = "Allowlisted accounts only"
				else
					data.message = string.format("All public slots are taken (%i // %i)", playerCount, maxPublicSlots)
				end
			end)
		end

		return hook.override
	end
end)

plugin.commands["listallowlist"] = {
	info = "List all allowlisted players.",
	call = function()
		assert(allowlistedPhoneNumbers)
		print(table.concat(allowlistedPhoneNumbers, ", "))
	end,
}

plugin.commands["/allowlist"] = {
	info = "Add a player to the allowlist.",
	usage = "<phoneNumber>",
	alias = { "al" },
	canCall = function(ply)
		return ply.isConsole or ply.isAdmin
	end,
	call = function(ply, _, args)
		assert(#args >= 1, "usage")

		local phoneNumber = undashPhoneNumber(args[1])
		assert(phoneNumber, "Invalid phone number")

		if getAllowlistIndex(phoneNumber) then
			error("Phone number already allowlisted")
		end

		assert(allowlistedPhoneNumbers)
		table.insert(allowlistedPhoneNumbers, phoneNumber)
		saveAllowlist()

		if adminLog then
			adminLog("%s allowlisted %s", ply.name, dashPhoneNumber(phoneNumber))
		end
	end,
}

plugin.commands["/unallowlist"] = {
	info = "Remove a player from the allowlist.",
	usage = "<phoneNumber>",
	canCall = function(ply)
		return ply.isConsole or ply.isAdmin
	end,
	call = function(ply, _, args)
		assert(#args >= 1, "usage")

		local phoneNumber = undashPhoneNumber(args[1])
		assert(phoneNumber, "Invalid phone number")

		local index = getAllowlistIndex(phoneNumber)
		if not index then
			error("Phone number not allowlisted")
		end

		assert(allowlistedPhoneNumbers)
		table.remove(allowlistedPhoneNumbers, index)
		saveAllowlist()

		if adminLog then
			adminLog("%s unallowlisted %s", ply.name, dashPhoneNumber(phoneNumber))
		end
	end,
}
