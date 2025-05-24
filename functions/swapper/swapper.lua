
---@type details
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale( "Details" )
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local _tempo = time()
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@diagnostic disable-next-line: undefined-field
local classCustom = Details.atributo_custom

local debugmode = false
local debugPrint = function(...)
    if (debugmode) then
        print("|cFFFFFF00Details Swapper (dev):|r", ...)
    end
end

---@class details : table
---@field GetDamageWindow fun(self:details):instance? return the window that is showing the current segment and damage done
---@field InitializeEncounterSwapper fun(self:details)
---@field SwapperGetEncounterData fun(self:details):table return a table with data stored by the current swapper
---@field SwapperGetWindow fun(self:details):instance? return the window that is being swapped
---@field SwapperFreezeDamage fun(self:details) get damage done by players and store in Details:SwapperGetEncounterData()
---@field SwapperFreezeDamageOnTarget fun(self:details, targetName:string) get damage done by players on a target and store in Details:SwapperGetEncounterData()
---@field SwapperRestoreWindow fun(self:details) restore the window that was swapped
---@field SwapperSetCustomDisplay fun(self:details, instanceObject:instance, customDisplayName:string, customDisplayIcon:string, customDisplaySearchCode:string) set the display of the window to a custom display

---@class swapper_data : table
---@field encounterData table<string, number> a table containing any data related to the current encounter
---@field bIsSwapped boolean a flag to indicate if the display has been swapped
---@field instance instance? the instance (window) that is being swapped
---@field displayId number? the display id that was set before the swap
---@field subDisplayId number? the sub display id that was set before the swap
---@field segmentId number? the segment id that was set before the swap
---@field customObject table? the custom object that was created for the swap

---@type swapper_data
local data = {
    encounterData = {},
    bIsSwapped = false,
    registeredEncounters = {},
}

local registerEncounter = function(encounterRegister)
    data.registeredEncounters[encounterRegister.id] = encounterRegister
end

local getEncounterSwapperInfo = function(encounterId)
    return data.registeredEncounters[encounterId]
end

----find a window showing current segment and damage done
---@return instance?
local getDamageWindow = function()
    --find a window showing current segment and damage done
    for instanceId, instance in ipairs(Details:GetAllInstances()) do
        if (instance:IsEnabled()) then
            local segmentId = instance:GetSegmentId()
            if (segmentId == DETAILS_SEGMENTID_CURRENT) then
                local displayId, subDisplayId = instance:GetDisplay()
                if (displayId == DETAILS_ATTRIBUTE_DAMAGE and subDisplayId == DETAILS_SUBATTRIBUTE_DAMAGEDONE) then
                    return instance
                end
            end
        end
    end
end

--called when the phase changes
--add into data.encounter the name of the player and their damage done
--used to calculate the damage difference through a phase of the encounter
local freezeDamage = function()
    local currentCombat = Details:GetCurrentCombat()
    local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    for index, actorObject in damageContainer:ListActors() do
        if (actorObject:IsPlayer()) then
            local playerDamage = actorObject.total
            data.encounterData[actorObject:Name()] = playerDamage
        end
    end
end

---return an instance object showing the current segment and damage done
---@param self details
---@return instance?
function Details:GetDamageWindow()
    return getDamageWindow()
end

--details version of the function freezeDamage
---@param self details
function Details:SwapperFreezeDamage()
    return freezeDamage()
end

function Details:SwapperFreezeDamageOnTarget(targetName)
    local currentCombat = Details:GetCurrentCombat()
    local damageContainer = currentCombat:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)
    for index, actorObject in damageContainer:ListActors() do
        ---@cast actorObject actordamage
        if (actorObject:IsPlayer()) then
            local targets = actorObject.targets
            local damageOnTarget = targets[targetName] or 0
            data.encounterData[actorObject:Name()] = damageOnTarget
        end
    end
end

---@param self details
---@return table
function Details:SwapperGetEncounterData()
    return data.encounterData
end

---call when the swapped display isn't needed anymore, encounter data is wiped
---@param self details
function Details:SwapperRestoreWindow()
    debugPrint("Restoring window")
    local swappedWindow = Details:SwapperGetWindow()
    if (swappedWindow) then
        swappedWindow:SetDisplay(data.segmentId, data.displayId, data.subDisplayId)
    end

    if (data.customObject) then
        Details:RemoveCustomObject(data.customObject.name)
        data.customObject = nil
    end

    data.bIsSwapped = false
    data.instance = nil
    table.wipe(data.encounterData)
end

function Details:SwapperSetCustomDisplay(instanceObject, customDisplayName, customDisplayIcon, customDisplaySearchCode)
    debugPrint("1 Swapping window to custom display:", customDisplayName)
    --check if the custom display already exists
    local customDisplayIndex = Details:DoesCustomDisplayExists(customDisplayName)

    --store what the window is currently showing
    local displayId, subDisplayId = instanceObject:GetDisplay()
    data.displayId = displayId
    data.subDisplayId = subDisplayId
    data.segmentId = instanceObject:GetSegmentId()

    if (customDisplayIndex) then
        --if it exists, set the display
        debugPrint("2 Custom display found, setting display to:", customDisplayName)
        instanceObject:SetDisplay(DETAILS_SEGMENTID_CURRENT, DETAILS_ATTRIBUTE_CUSTOM, customDisplayIndex)
    else
        --if it doesn't exist, create it and set the display
        debugPrint("3 Custom display not found, creating and setting display to:", customDisplayName)
        local customObject = Details:CreateCustomDisplayObject(customDisplayName, customDisplayIcon, customDisplaySearchCode, [[return true]])
        Details:InstallCustomObject(customObject)
        local customDisplayAmount = Details:GetNumCustomDisplays()
        instanceObject:SetDisplay(DETAILS_SEGMENTID_CURRENT, DETAILS_ATTRIBUTE_CUSTOM, customDisplayAmount)
        data.customObject = customObject
    end

    data.bIsSwapped = true
    data.instance = instanceObject
end


---return the instance object that is being swapped
---@param self details
---@return instance?
function Details:SwapperGetWindow()
    return data.instance
end

function Details:InitializeEncounterSwapper()
    local eventListener = Details:CreateEventListener()
    eventListener:RegisterEvent("COMBAT_ENCOUNTER_END")
    eventListener:RegisterEvent("COMBAT_ENCOUNTER_PHASE_CHANGED")

    function eventListener:OnDetailsEvent(event, param1, param2, param3)
        --debugPrint("eventListener:OnEvent", event, param1, param2, param3)

        do return end

        if (event == "COMBAT_ENCOUNTER_PHASE_CHANGED") then
            local encounterTable = Details:GetCurrentEncounterInfo()
            local encounterSwapperInfo = getEncounterSwapperInfo(encounterTable.id)
            if (not encounterSwapperInfo) then
                --debugPrint("No encounter swapper info found for encounter id:", encounterTable.id)
                return
            end

            local phaseString = "phase" .. encounterTable.phase
            local phaseFunction = encounterSwapperInfo[phaseString]

            if (phaseFunction) then
                debugPrint("Running function for phase:", encounterTable.phase, phaseString)
                phaseFunction()
            else
                debugPrint("No function found for phase:", encounterTable.phase, phaseString)
            end

        elseif (event == "COMBAT_ENCOUNTER_END") then
            --debugPrint("Encounter ended")
            local swappedWindow = Details:SwapperGetWindow()
            if (swappedWindow) then
                Details:SwapperRestoreWindow()
            else
                --debugPrint("No swapped window found at the end of the encounter")
            end
        end
    end


end

----------------------------------------------------------
-----encounter data

do --Vexie and the Geargrinders
    local encounterSwapperInfo = {
        id = 3009,

        ["phase1"] = function()
            debugPrint("encounterSwapperInfo -> Phase 1 running")
            Details:SwapperRestoreWindow()
        end,

        ["phase2"] = function()
            local damageWindow = Details:GetDamageWindow()
            debugPrint("encounterSwapperInfo -> Phase 2 running", damageWindow and "window found" or "no window found")
            if (damageWindow) then
                --Details:SwapperFreezeDamage()
                local npcName = Details:GetSourceFromNpcId(225821)
                if (npcName) then
                    debugPrint("Freezing damage on target:", npcName)
                    Details:SwapperFreezeDamageOnTarget(npcName)
                else
                    debugPrint("No npc name found for npc id 225821.")
                    return
                end

                local swapperEncounterData = Details:SwapperGetEncounterData()
                swapperEncounterData.targetName = npcName

                local customDisplaySearchCode = [[
                    ---@type combat, table, instance
                    local combatObject, instanceContainer, instanceObject = ...
            
                    --declade the values to return
                    local totalDamage, topDamage, amount = 0, 0, 0
            
                    ---@type actorcontainer
                    local damageContainer = combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE)

                    local swapperEncounterData = Details:SwapperGetEncounterData()

                    for index, actorObject in damageContainer:ListActors() do
                        if (actorObject:IsPlayer()) then
                            local freezedDamageOnTarget = swapperEncounterData[actorObject:Name()] or 0
                            local targets = actorObject.targets
                            local damageOnTarget = (targets[swapperEncounterData.targetName] or 0) - freezedDamageOnTarget

                            if (damageOnTarget > 0) then
                                instanceContainer:SetValue(actorObject, damageOnTarget) --actorObject, amountDamage
                                totalDamage = totalDamage + damageOnTarget --amountDamage
                                if (damageOnTarget > topDamage) then
                                    topDamage = damageOnTarget --top damage
                                end
                                amount = amount + 1 --amount of actors found
                            end
                        end
                    end
            
                    return totalDamage, topDamage, amount
                ]]

                local customDisplayName = "Damage On Geargrinder"
                local customDisplayIcon = "Interface\\Icons\\spell_nature_earthbind"
                Details:SwapperSetCustomDisplay(damageWindow, customDisplayName, customDisplayIcon, customDisplaySearchCode)
            end
        end,
    }

    registerEncounter(encounterSwapperInfo)
end