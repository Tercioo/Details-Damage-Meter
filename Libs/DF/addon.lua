
local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local CONST_DEFAULT_PROFILE_NAME = "default"

---@class df_addon : table
---@field __name string the addon toc name
---@field __savedGlobalVarsName string the name of the global saved variables
---@field __savedVarsDefaultTemplate table the default template for the saved variables
---@field __frame frame a frame to use for events
---@field OnLoaded fun(addon:df_addon, profileTable:table) runs when the addon is loaded at event "ADDON_LOADED"
---@field OnInit fun(addon:df_addon, profileTable:table) runs when the addon is initialized at event "PLAYER_LOGIN"
---@field OnProfileChanged fun(addon:df_addon, profileTable:table) runs when the profile is changed

--runs when the addon received addon_loaded
local addonLoaded = function(addonFrame, event, addonName)
	if (addonName ~= addonFrame.__name) then
		return
	end

	local addonObject = addonFrame.__addonObject

	if (not addonObject.__savedGlobalVarsName) then
		if (addonObject.OnLoad) then
			detailsFramework:Dispatch(addonObject.OnLoad, addonObject)
		end
		return
	end

	local playerGUID = UnitGUID("player") --the guid points to a profile name

	---@type table
	local tSavedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)

	--check if the player has a profileId saved
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
		detailsFramework:Dispatch(addonObject.OnLoad, addonObject, addonObject.profile)
	end
end

--runs when the addon received PLAYER_LOGIN
local addonInit = function(addonFrame)
	local addonObject = addonFrame.__addonObject

	if (addonObject.OnInit) then
		detailsFramework:Dispatch(addonObject.OnInit, addonObject, addonObject.profile)
	end
end

--when the player logout or reloadUI
local addonUnload = function(addonFrame)
	local addonObject = addonFrame.__addonObject
	detailsFramework.SavedVars.SaveProfile(addonObject)
end

local addonEvents = {
	["ADDON_LOADED"] = addonLoaded,
	["PLAYER_LOGIN"] = addonInit,
	["PLAYER_LOGOUT"] = addonUnload,
}

local addonOnEvent = function(addonFrame, event, ...)
	local func = addonEvents[event]
	if (func) then
		func(addonFrame, event, ...)
	else
		--might be a registered event from the user
		if (addonFrame[event]) then
			detailsFramework:CoreDispatch(addonFrame.__name, addonFrame[event], addonFrame, event, ...)
		end
	end
end

detailsFramework.AddonMixin = {

}

---create an addon object
---@param addonName addonname
---@param globalSavedVariablesName string
---@param savedVarsTemplate table
---@return frame
function detailsFramework:CreateNewAddOn(addonName, globalSavedVariablesName, savedVarsTemplate)
	local newAddonObject = {}

	---@type frame
	local addonFrame = CreateFrame("frame")
	newAddonObject.__name = addonName
	newAddonObject.__savedGlobalVarsName = globalSavedVariablesName
	newAddonObject.__savedVarsDefaultTemplate = savedVarsTemplate or {}
	newAddonObject.__frame = addonFrame

	addonFrame.__name = addonName
	addonFrame.__savedGlobalVarsName = globalSavedVariablesName
	addonFrame.__savedVarsDefaultTemplate = newAddonObject.__savedVarsDefaultTemplate
	addonFrame.__addonObject = newAddonObject

	addonFrame:RegisterEvent("ADDON_LOADED")
	addonFrame:RegisterEvent("PLAYER_LOGIN")
	addonFrame:RegisterEvent("PLAYER_LOGOUT")
	addonFrame:SetScript("OnEvent", addonOnEvent)

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
