
	--[[global]] DETAILS_HOOK_COOLDOWN = "HOOK_COOLDOWN"
	--[[global]] DETAILS_HOOK_DEATH = "HOOK_DEATH"
	--[[global]] DETAILS_HOOK_BATTLERESS = "HOOK_BATTLERESS"
	--[[global]] DETAILS_HOOK_INTERRUPT = "HOOK_INTERRUPT"

	local Details = _G.Details
	local addonName, Details222 = ...
	local _

	---@alias detailshook
	---| '"HOOK_COOLDOWN"' # Hook for cooldowns
	---| '"HOOK_DEATH"' # Hook for deaths
	---| '"HOOK_BATTLERESS"' # Hook for battle ress
	---| '"HOOK_INTERRUPT"' # Hook for interrupts

	Details.hooks["HOOK_COOLDOWN"] = {}
	Details.hooks["HOOK_DEATH"] = {}
	Details.hooks["HOOK_BATTLERESS"] = {}
	Details.hooks["HOOK_INTERRUPT"] = {}

	function Details:InstallHook(hookType, func)
		if (not Details.hooks[hookType]) then
			return false, "Invalid hook type."
		end

		for _, thisFunc in ipairs(Details.hooks[hookType]) do
			if (thisFunc == func) then
				--already installed
				return
			end
		end

		Details.hooks[hookType][#Details.hooks[hookType] + 1] = func
		Details.hooks[hookType].enabled = true

		Details:UpdateParserGears()
		return true
	end

	function Details:UnInstallHook(hookType, func)
		if (not Details.hooks[hookType]) then
			return false, "Invalid hook type."
		end

		for index, thisFunc in ipairs(Details.hooks[hookType]) do
			if (thisFunc == func) then
				table.remove(Details.hooks[hookType], index)

				if (#Details.hooks[hookType] == 0) then
					Details.hooks[hookType].enabled = false
				end

				Details:UpdateParserGears()
				return true
			end
		end
	end