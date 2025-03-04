

local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local CONST_DEFAULT_PROFILE_NAME = "default"

local UnitGUID = UnitGUID

---@alias profileid string the profile id is the name of the profile, by default it has the name "default"

--create namespace
detailsFramework.SavedVars = {}

function detailsFramework.SavedVars.GetCurrentProfileName(addonObject)
    assert(type(addonObject) == "table", "GetCurrentProfileName: addonObject must be a table.")

    local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
    local playerGUID = UnitGUID("player")
    local profileId = savedVariables.profile_ids[playerGUID] --get the profile name from the player guid

    return profileId
end

---get the saved variables table for the addon
---@param addonObject df_addon the addon object created by detailsFramework:CreateNewAddOn()
---@return table
function detailsFramework.SavedVars.GetSavedVariables(addonObject)
    assert(type(addonObject) == "table", "GetSavedVariables: addonObject must be a table.")

	if (addonObject.__savedGlobalVarsName) then
        local savedVariablesTable = _G[addonObject.__savedGlobalVarsName]

        --check if the saved variables table is created, if not create one
        if (not savedVariablesTable) then --first run
            if (addonObject.__savedVarsDefaultTemplate) then
                savedVariablesTable = {
                    --store profiles created from the 'savedVarsTemplate'
                    --[CONST_DEFAULT_PROFILE_NAME] = detailsFramework.table.deploy({}, addonObject.__savedVarsDefaultTemplate)
                    ---@type table<profileid, table>
                    profiles = {}, --store profiles between game sessions
                    ---@type table<guid, profileid>
                    profile_ids = {} --points which profileid the player is using by storing the player GUID as the key and the profileid as the value
                }
            else
                savedVariablesTable = {}
            end

            --set the table to be global savedVariables
            _G[addonObject.__savedGlobalVarsName] = savedVariablesTable
        end

		return savedVariablesTable
	end

    return {}
end


---@param addonObject df_addon the addon object created by detailsFramework:CreateNewAddOn()
---@param bCreateIfNotFound boolean? if true, create the profile if it doesn't exist
---@param profileToCopyFrom profile? if bCreateIfNotFound is true, copy the profile from this profile
function detailsFramework.SavedVars.GetProfile(addonObject, bCreateIfNotFound, profileToCopyFrom)
    assert(type(addonObject) == "table", "GetProfile: addonObject must be a table.")

    local playerGUID = UnitGUID("player")
    local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
    local profileId = savedVariables.profile_ids[playerGUID] --get the profile name from the player guid
    local profileTable = savedVariables.profiles[profileId]

    if (not profileTable and bCreateIfNotFound) then
        profileTable = {}

        if (profileToCopyFrom) then
            assert(type(profileToCopyFrom) == "table", "GetProfile: profileToCopyFrom must be a table (or nil).")
            --profileToCopyFrom has been cleaned at this point and only have values set by the user
            profileTable = detailsFramework.table.deploy(profileTable, profileToCopyFrom)
        end
    end

    if (profileTable and not profileTable.__loaded and addonObject.__savedVarsDefaultTemplate) then
        --as deploy does not overwrite existing values, it won't overwrite the values set by 'profileToCopyFrom'
        profileTable = detailsFramework.table.deploy(profileTable, addonObject.__savedVarsDefaultTemplate)
        --mark the profile as loaded
        profileTable.__loaded = true --loaded key is removed when the profile saves
    end

    return profileTable
end

---@param addonObject df_addon the addon object created by detailsFramework:CreateNewAddOn()
---@param profileName profilename the name of the profile to set
---@param bCopyFromCurrentProfile boolean? if true, copy the current profile to the new profile
function detailsFramework.SavedVars.SetProfile(addonObject, profileName, bCopyFromCurrentProfile)
    assert(type(addonObject) == "table", "SetProfile: addonObject must be a table.")
    assert(type(profileName) == "string", "SetProfile: profileName must be a string.")

    ---@type profile
    local currentProfile = detailsFramework.SavedVars.GetProfile(addonObject)
    --save the current profile
    if (addonObject.profile) then
        detailsFramework.SavedVars.SaveProfile(addonObject)
    end

    --set the new profile
    local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
    local playerGUID = UnitGUID("player")
    savedVariables.profile_ids[playerGUID] = profileName

    local bCreateIfNotFound = true

    --get the new profile creating if doesn't exist
    ---@type profile
    local profileTable = detailsFramework.SavedVars.GetProfile(addonObject, bCreateIfNotFound, bCopyFromCurrentProfile and currentProfile or nil)
    addonObject.profile = profileTable

    if (addonObject.OnProfileChanged) then
        detailsFramework:Dispatch(addonObject.OnProfileChanged, addonObject, profileTable)
    end
end

---@param addonObject df_addon the addon frame created by detailsFramework:CreateNewAddOn()
function detailsFramework.SavedVars.SaveProfile(addonObject)
    assert(type(addonObject) == "table", "SaveProfile: addonObject must be a table.")

    --the current profile in use
    local profileTable = rawget(addonObject, "profile")
    if (profileTable) then
        if (profileTable.__loaded) then
            --profile template (default profile)
            local profileTemplate = addonObject.__savedVarsDefaultTemplate

            --if the addon has a default template, remove the keys which are the same as the default template
            --these keys haven't been changed by the user, hence doesn't need to save them
            if (profileTemplate) then
                detailsFramework.table.removeduplicate(profileTable, addonObject.__savedVarsDefaultTemplate)
            end

            profileTable.__loaded = nil --remove the __loaded key

            local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
            local playerGUID = UnitGUID("player")
            local playerProfileId = savedVariables.profile_ids[playerGUID] --"default" by default
            savedVariables.profiles[playerProfileId] = profileTable
        end
    end
end

---@class df_profilepanel : frame
---@field AddonObject df_addon
---@field ProfileNameValueLabel fontstring
---@field ProfileSelectionDropdown df_dropdown
---@field ProfileNameTextEntry df_textentry
---@field OnClickCreateNewProfile function
---@field RefreshSelectProfileDropdown function

---@param profilePanel df_profilepanel
function detailsFramework.SavedVars.RefreshProfilePanel(profilePanel)
    local addonObject = profilePanel.AddonObject

    --update the current profile name
    ---@type string
    local profileName = detailsFramework.SavedVars.GetCurrentProfileName(addonObject)
    profilePanel.ProfileNameValueLabel:SetText(profileName)

    --update the options of the dropdown to select a profile
    profilePanel:RefreshSelectProfileDropdown()

    --clear the text entry for the new profile name
    profilePanel.ProfileNameTextEntry:SetText("")
end

local profilePanelMixin = {
    ---@param self df_profilepanel
    RefreshSelectProfileDropdown = function(self)
        local addonObject = self.AddonObject
        local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
        local profiles = savedVariables.profiles

        local callback = function(self, fixedValue, profileSelected)
            detailsFramework.SavedVars.SetProfile(addonObject, profileSelected)
            detailsFramework.SavedVars.RefreshProfilePanel(self:GetParent())
        end

        local dropdownOptions = {}
        for profileId in pairs(profiles) do
            table.insert(dropdownOptions, {value = profileId, label = profileId, onclick = callback, icon = [[Interface\CHATFRAME\UI-ChatIcon-BlizzardArcadeCollection]], iconsize = {16, 16}})
        end

        self.ProfileSelectionDropdown.Options = dropdownOptions
        self.ProfileSelectionDropdown:Refresh()
        self.ProfileSelectionDropdown:Select(detailsFramework.SavedVars.GetCurrentProfileName(addonObject))
    end,

    ---@param self df_profilepanel
    OnClickCreateNewProfile = function(self)
        local addonObject = self.AddonObject
        local profileName = self.ProfileNameTextEntry:GetText()
        detailsFramework.SavedVars.SetProfile(addonObject, profileName)
        detailsFramework.SavedVars.RefreshProfilePanel(self)
    end

}

local defaultProfilePanelOptions = {
    width = 600,
    height = 400,
    title = "Profile Management"
}

function detailsFramework.SavedVars.CreateProfilePanel(addonObject, frameName, parentFrame, options)
    options = options or detailsFramework.table.copy({}, defaultProfilePanelOptions)
    detailsFramework.table.deploy(options, defaultProfilePanelOptions)

    local textentryTemplate, labelTemplate = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"), detailsFramework:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
    local buttonTemplate = detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
    local dropdownTemplate = detailsFramework:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")

    --create a simple frame
    local panelOptions = {}
    ---@type df_profilepanel
    local frame = CreateFrame("frame", frameName, parentFrame)
    frame:SetSize(options.width, options.height)
    frame.AddonObject = addonObject

    detailsFramework:Mixin(frame, profilePanelMixin)
    detailsFramework:AddRoundedCornersToFrame(frame, Details.PlayerBreakdown.RoundedCornerPreset)

    --create a label with the name of the profile (two labels, one for the name "Profile Name" and one for the value)
    ---@type fontstring
    local profileNameLabel = frame:CreateFontString(nil, "overlay", "GameFontNormal")
    profileNameLabel:SetPoint("topleft", frame, "topleft", 10, -10)
    profileNameLabel:SetText("Current Profile:")

    ---@type fontstring
    local profileNameValueLabel = frame:CreateFontString(nil, "overlay", "GameFontNormal")
    profileNameValueLabel:SetPoint("left", profileNameLabel, "right", 5, 0)
    profileNameValueLabel:SetText("")
    frame.ProfileNameValueLabel = profileNameValueLabel

    ---@type fontstring
    local selectProfileLabel = frame:CreateFontString(nil, "overlay", "GameFontNormal")
    selectProfileLabel:SetPoint("topleft", profileNameLabel, "bottomleft", 0, -15)
    selectProfileLabel:SetText("Select:")

    --create a dropdown to select the profile
    local onSelectProfileCallback = function()
        return frame.ProfileSelectionDropdown.Options or {}
    end

    local defaultValue = 1 -- set default to 1, latter when refreshing the entire panel, set the default to the current profile
    ---@type df_dropdown
    local profileSelectionDropdown = detailsFramework:CreateDropDown(frame, onSelectProfileCallback, defaultValue, 180, 32, "ProfileSelectionDropdown", "$parentProfileSelectionDropdown", dropdownTemplate)
    profileSelectionDropdown:SetPoint("topleft", selectProfileLabel, "bottomleft", 0, -5)
    profileSelectionDropdown:SetBackdrop(nil)
    detailsFramework:AddRoundedCornersToFrame(profileSelectionDropdown, Details.PlayerBreakdown.RoundedCornerPreset)
    frame.ProfileSelectionDropdown = profileSelectionDropdown

    ---@type fontstring
    local createNewProfileLabel = frame:CreateFontString(nil, "overlay", "GameFontNormal")
    createNewProfileLabel:SetPoint("topleft", profileSelectionDropdown.widget, "bottomleft", 0, -10)
    createNewProfileLabel:SetText("Create New:")

    --create a textentry to enter the name of the profile to be created and create a button to create the new profile
    local onPressEnterCallback = function()

    end

    ---@type df_textentry
    local profileNameTextEntry = detailsFramework:CreateTextEntry(frame, onPressEnterCallback, 180, 32, "ProfileNameEntry", "$parentProfileNameTextEntry", "Profile Name")
    profileNameTextEntry:SetPoint("topleft", createNewProfileLabel, "bottomleft", 0, -5)
    profileNameTextEntry:SetBackdrop(nil)
    profileNameTextEntry:SetJustifyH("left")
    profileNameTextEntry.fontsize = 12
    detailsFramework:AddRoundedCornersToFrame(profileNameTextEntry, Details.PlayerBreakdown.RoundedCornerPreset)
    frame.ProfileNameTextEntry = profileNameTextEntry

    ---@type df_button
    local createProfileButton = detailsFramework:CreateButton(frame, function() frame.OnClickCreateNewProfile(frame) end, 100, 32, "Create", false, false, false, "ProfileCreateButton", "$parentCreateProfileButton", buttonTemplate, labelTemplate)
    createProfileButton:SetPoint("left", profileNameTextEntry, "right", 5, 0)
    detailsFramework:AddRoundedCornersToFrame(createProfileButton, Details.PlayerBreakdown.RoundedCornerPreset)

    frame:SetScript("OnShow", function()
        detailsFramework.SavedVars.RefreshProfilePanel(frame)
    end)

    frame:Hide()

    return frame
end
