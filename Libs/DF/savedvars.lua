
--stopped doing the duplicate savedTable

local detailsFramework = _G ["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local CONST_DEFAULT_PROFILE_NAME = "default"

local UnitGUID = UnitGUID

--create namespace
detailsFramework.SavedVars = {}

---get the saved variables table for the addon
---@param addonObject df_addon the addon frame created by detailsFramework:CreateNewAddOn()
---@return table
function detailsFramework.SavedVars.GetSavedVariables(addonObject)
    assert(type(addonObject) == "table", "SetProfile: addonObject must be a table.")

	if (addonObject.__savedGlobalVarsName) then
        local savedVariables = _G[addonObject.__savedGlobalVarsName]

        --check if the saved variables table is created, if not create one
        if (not savedVariables) then
            if (addonObject.__savedVarsDefaultTemplate) then
                savedVariables = {
                    profiles = {
                        --store profiles created from the 'savedVarsTemplate'
                        [CONST_DEFAULT_PROFILE_NAME] = detailsFramework.table.deploy({}, addonObject.__savedVarsDefaultTemplate)
                    },
                    profile_ids = {} --store the profile id for each character using its GUID
                }
            else
                savedVariables = {}
            end

            --set the table to be global savedVariables
            _G[addonObject.__savedGlobalVarsName] = savedVariables
        end

        if (not savedVariables.profiles) then
            savedVariables.profiles = {
                profiles = {
                    --store profiles created from the 'savedVarsTemplate'
                    [CONST_DEFAULT_PROFILE_NAME] = detailsFramework.table.deploy({}, addonObject.__savedVarsDefaultTemplate)
                }
            }
        end

        if (not savedVariables.profile_ids) then
            savedVariables.profile_ids = {}
        end

		return savedVariables
	end

    return {}
end


---@param addonObject df_addon the addon frame created by detailsFramework:CreateNewAddOn()
---@param bCreateIfNotFound boolean|nil if true, create the profile if it doesn't exist
---@param profileToCopyFrom profile|nil if bCreateIfNotFound is true, copy the profile from this profile
function detailsFramework.SavedVars.GetProfile(addonObject, bCreateIfNotFound, profileToCopyFrom)
    assert(type(addonObject) == "table", "GetProfile: addonObject must be a table.")

    local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
    local playerProfileName = savedVariables.profile_ids[UnitGUID("player")] --get the profile name from the player guid
    local profileTable = savedVariables.profiles[playerProfileName]

    if (not profileTable and bCreateIfNotFound) then
        profileTable = {}

        if (profileToCopyFrom) then
            --profileToCopyFrom has been cleaned at this point and only have values set by the user
            profileTable = detailsFramework.table.deploy(profileTable, profileToCopyFrom)
        end

        --as deploy does not overwrite existing values, it won't overwrite the values set by 'profileToCopyFrom'
        profileTable = detailsFramework.table.deploy(profileTable, addonObject.__savedVarsDefaultTemplate)
        savedVariables.profiles[playerProfileName] = profileTable
    end

    return profileTable
end

---@param addonObject df_addon the addon frame created by detailsFramework:CreateNewAddOn()
---@param profileName profilename the name of the profile to set
---@param bCopyFromCurrentProfile boolean if true, copy the current profile to the new profile
function detailsFramework.SavedVars.SetProfile(addonObject, profileName, bCopyFromCurrentProfile)
    assert(type(addonObject) == "table", "SetProfile: addonObject must be a table.")
    assert(type(profileName) == "string", "SetProfile: profileName must be a string.")

    ---@type profile
    local currentProfile = detailsFramework.SavedVars.GetProfile(addonObject)
    --save the current profile
    detailsFramework.SavedVars.SaveProfile(addonObject)

    --set the new profile
    local savedVariables = detailsFramework.SavedVars.GetSavedVariables(addonObject)
    local playerGUID = UnitGUID("player")
    savedVariables.profile_ids[playerGUID] = profileName

    local bCreateIfNotFound = true

    --get the new profile creating if doesn't exist
    ---@type profile
    local profileTable = detailsFramework.SavedVars.GetProfile(addonObject, bCreateIfNotFound, bCopyFromCurrentProfile and currentProfile or nil)

    if (addonObject.OnProfileChanged) then
        detailsFramework:Dispatch(addonObject.OnProfileChanged, addonObject, profileTable)
    end
end

---@param addonObject df_addon the addon frame created by detailsFramework:CreateNewAddOn()
function detailsFramework.SavedVars.SaveProfile(addonObject)
    assert(type(addonObject) == "table", "SetProfile: addonObject must be a table.")

    --the current profile in use
    local profileTable = detailsFramework.SavedVars.GetProfile(addonObject)
    --profile template or "default profile"
    local profileTemplate = addonObject.__savedVarsDefaultTemplate

    --if the addon has a default template, remove the keys which are the same as the default template
    --these keys haven't been changed by the user, hence doesn't need to save them
    if (profileTemplate) then
        detailsFramework.table.removeduplicate(profileTable, addonObject.__savedVarsDefaultTemplate)
    end
end