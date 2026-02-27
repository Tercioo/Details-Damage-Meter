
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end
local _

--saved variables are a table that is saved between game sessions and saves user settings

--the addon object has support for multiple profiles, they can be created, deleted and switched by the user, this variable tells which is the name of the first profile to be created
local CONST_DEFAULT_PROFILE_NAME = "default"

--runs when the addon received the event addon_loaded
local addonLoaded = function(addonFrame, event, addonName)
	--as this event is fired for each addon, we need to check if the addon name is the same as our addon name, if not, just ignore
	if (addonName ~= addonFrame.__name) then
		return
	end

	local addonObject = addonFrame.__addonObject

	--if the addon doesn't have a global saved variables name, it means that the addon doesn't want to use saved variables, so we can call the OnLoad function and return
	if (not addonObject.__savedGlobalVarsName) then
		if (addonObject.OnLoad) then
			xpcall(addonObject.OnLoad, geterrorhandler(), addonObject)
		end
		return
	end

	--the player character guid is used as the key of a table to know which profile the character uses
	local playerGUID = UnitGUID("player")

	--get the global saved variables table
	---@type table
	local tSavedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)

	--check if the player character has a profileId saved
	local profileId = tSavedVariables.profile_ids[playerGUID]
	if (not profileId) then
		--if it doesn't, set it to use the default profile
		profileId = CONST_DEFAULT_PROFILE_NAME
		tSavedVariables.profile_ids[playerGUID] = profileId
	end

	local bCreateIfNotFound = true
	local profileTable = detailsFramework.SavedVars.GetProfile(addonObject, bCreateIfNotFound)
	addonObject.profile = profileTable

	if (addonObject.OnLoad) then
		xpcall(addonObject.OnLoad, geterrorhandler(), addonObject, addonObject.profile, true)
	end
end

--runs when the addon received PLAYER_LOGIN
local addonInit = function(addonFrame)
	local addonObject = addonFrame.__addonObject

	if (addonObject.OnInit) then
		xpcall(addonObject.OnInit, geterrorhandler(), addonObject, addonObject.profile)
	end
end

--when the player logout or reloadUI
local addonUnload = function(addonFrame)
	local addonObject = addonFrame.__addonObject
	local bOkay, errortext = pcall(detailsFramework.SavedVars.SaveProfile, addonObject)
	if (not bOkay) then
		if (addonFrame.logoutLogs) then
			table.insert(addonFrame.logoutLogs, 1, date("%a %b %d %H:%M:%S %Y") .. "|LOGOUT error:" .. errortext)
			table.remove(addonFrame.logoutLogs, 3)
		end
	end
end

--which function to call for each event
local addonEvents = {
	["ADDON_LOADED"] = addonLoaded,
	["PLAYER_LOGIN"] = addonInit,
	["PLAYER_LOGOUT"] = addonUnload,
}

--handles the events and dispatch to the correct function
local addonOnEvent = function(addonFrame, event, ...)
	local func = addonEvents[event]
	if (func) then
		xpcall(func, geterrorhandler(), addonFrame, event, ...)
	else
		--might be a registered event from the user
		if (addonFrame[event]) then
			detailsFramework:CoreDispatch(addonFrame.__name, addonFrame[event], addonFrame, event, ...)
		end
	end
end

detailsFramework.AddonMixin = {

}

--log erros during the save data
local setLogoutLogTable = function(addonObject, logTable)
	addonObject.__frame.logoutLogs = logTable
end

---@class df_addon : table
---@field __name string the addon toc name
---@field __savedGlobalVarsName string the name of the global saved variables
---@field __savedVarsDefaultTemplate table the default template for the saved variables
---@field __frame frame a frame to use for events
---@field OnLoad fun(addon:df_addon, profileTable:table) runs when the addon is loaded at event "ADDON_LOADED"
---@field OnInit fun(addon:df_addon, profileTable:table) runs when the addon is initialized at event "PLAYER_LOGIN"
---@field OnProfileChanged fun(addon:df_addon, profileTable:table) runs when the profile is changed
---@field SetLogoutLogTable fun(addon:df_addon, logTable:table) sets the logout log table
---an addon object is the base object of an addon, it handle events, saved variables, profiles and provide a base for the addon to work on.
---@param addonName addonname toc file name
---@param globalSavedVariablesName string
---@param savedVarsTemplate table
---@return df_addon
function detailsFramework:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)
	local newAddonObject = {}

	---@type frame
	local addonFrame = CreateFrame("frame")
	--store the name of the addon
	newAddonObject.__name = addonName
	--store the name of the global saved variables
	newAddonObject.__savedGlobalVarsName = globalSavedVariablesName
	--store the default template for the saved variables, used when creating a new profile
	newAddonObject.__savedVarsDefaultTemplate = savedVarsTemplate or {}
	--the frame is used for events
	newAddonObject.__frame = addonFrame

	--store the same values in the frame for easy access in the event functions
	addonFrame.__name = addonName
	addonFrame.__savedGlobalVarsName = globalSavedVariablesName
	addonFrame.__savedVarsDefaultTemplate = newAddonObject.__savedVarsDefaultTemplate
	addonFrame.__addonObject = newAddonObject

	--register events and set the event handler
	addonFrame:RegisterEvent("ADDON_LOADED")
	addonFrame:RegisterEvent("PLAYER_LOGIN")
	addonFrame:RegisterEvent("PLAYER_LOGOUT")
	addonFrame:SetScript("OnEvent", addonOnEvent)

	--provide a function to set the logout log table, which will be used to log errors during the save data process
	newAddonObject.SetLogoutLogTable = setLogoutLogTable

	return newAddonObject
end


--old create addon using ace3
function detailsFramework:CreateAddOn(name, global_saved, global_table, options_table, broker)

	local addon = LibStub("AceAddon-3.0"):NewAddon (name, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "DetailsFramework-1.0", "AceComm-3.0")
	_G [name] = addon
	addon.__name = name

	function addon:OnInitialize()

		if (global_saved) then
			if (broker and broker.Minimap and not global_table.Minimap) then
				detailsFramework:Msg(name, "broker.Minimap is true but no global.Minimap declared.")
			end
			self.db = LibStub("AceDB-3.0"):New (global_saved, global_table or {}, true)
		end

		if (options_table) then
			LibStub("AceConfig-3.0"):RegisterOptionsTable (name, options_table)
			addon.OptionsFrame1 = LibStub("AceConfigDialog-3.0"):AddToBlizOptions (name, name)

			LibStub("AceConfig-3.0"):RegisterOptionsTable (name .. "-Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable (self.db))
			addon.OptionsFrame2 = LibStub("AceConfigDialog-3.0"):AddToBlizOptions (name .. "-Profiles", "Profiles", name)
		end

		if (broker) then
			local broker_click_function = broker.OnClick
			if (not broker_click_function and options_table) then
				broker_click_function = function()
					InterfaceOptionsFrame_OpenToCategory (name)
					InterfaceOptionsFrame_OpenToCategory (name)
				end
			end

			local databroker = LibStub("LibDataBroker-1.1"):NewDataObject (name, {
				type = broker.type or "launcher",
				icon = broker.icon or [[Interface\PvPRankBadges\PvPRank15]],
				text = broker.text or "",
				OnTooltipShow = broker.OnTooltipShow,
				OnClick = broker_click_function
			})

			if (databroker and broker.Minimap and global_table.Minimap) then
				LibStub("LibDBIcon-1.0"):Register (name, databroker, addon.db.profile.Minimap)
			end
		end

		if (addon.OnInit) then
			xpcall(addon.OnInit, geterrorhandler(), addon)
		end

	end

	return addon

end
