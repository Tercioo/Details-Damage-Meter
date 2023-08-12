
--stopped doing the duplicate savedTable

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
        profileTable.__loaded = true
    end

    return profileTable
end

---@param addonObject df_addon the addon object created by detailsFramework:CreateNewAddOn()
---@param profileName profilename the name of the profile to set
---@param bCopyFromCurrentProfile boolean if true, copy the current profile to the new profile
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