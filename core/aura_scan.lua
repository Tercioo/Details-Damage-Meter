
local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = DetailsFramework
local _

local AuraUtil, wipe, C_UnitAuras, GetSpellInfo, GetTime, UnitGUID, UnitExists = AuraUtil, table.wipe, C_UnitAuras, GetSpellInfo, GetTime, UnitGUID, UnitExists

local AuraScan = Details222.AuraScan
AuraScan.Enabled = false
AuraScan.Callbacks = {}
AuraScan.AurasToScan = {}
---store the auras applied to the unit, format: [unitGUID] = {auraInstanceId = aurainfo}
---@type table<guid, table<number, aurainfo>>
AuraScan.UnitAurasStorage = {}
AuraScan.AurasToTimeline = {} --which spells should be added to the timeline
AuraScan.AuraTimelineStorage = {} --store the timeline here

function AuraScan.RegisterCallback(callback)
    AuraScan.Callbacks[callback] = true
end

function AuraScan.UnregisterCallback(callback)
    AuraScan.Callbacks[callback] = nil
end

---return a table with all auras applied to the unit, format: [unitGUID] = {auraInstanceId = aurainfo}
function AuraScan.GetOrCreateUnitAuraTable(unitGUID)
    local auras = AuraScan.UnitAurasStorage[unitGUID]
    if (not auras) then
        auras = {}
        AuraScan.UnitAurasStorage[unitGUID] = auras
    end
    return auras
end

function AuraScan.WipeAllUnitAuraTables()
    wipe(AuraScan.UnitAurasStorage)
end

function AuraScan.WipeUnitAuraTable(unitGUID)
    local auras = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
    wipe(auras)
end

function AuraScan.GetAura(unitGUID, spellId)
    if (not unitGUID or not spellId) then
        return false
    end

    local auraTbl = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
    if (not auraTbl) then
        --happens if the guid is invalid
        return false
    end

    return auraTbl[spellId]
end

function AuraScan.AddAura(spellId, bAddToTimeLine)
    if (not spellId or type(spellId) ~= "number") then
        Details:Msg("AuraScan.AddAura() called, but spellId is not a number.")
        return
    end

    local spellName = GetSpellInfo(spellId)

    if (spellName) then
        AuraScan.AurasToScan[spellId] = true
        if (bAddToTimeLine) then
            AuraScan.AurasToTimeline[spellId] = true
        end
    else
        Details:Msg("AuraScan.AddAura() called, but spellId is not a valid spell.")
    end
end

--is the aura added?
function AuraScan.IsAuraAdded(spellId)
    if (not spellId or type(spellId) ~= "number") then
        Details:Msg("AuraScan.IsAuraAdded() called, but spellId is not a number.")
        return
    end
    return AuraScan.AurasToScan[spellId]
end

function AuraScan.RemoveAura(spellId)
    if (not spellId or type(spellId) ~= "number") then
        Details:Msg("AuraScan.RemoveAura() called, but spellId is not a number.")
        return
    end
    AuraScan.AurasToScan[spellId] = nil
    AuraScan.AurasToTimeline[spellId] = nil
end

function AuraScan.RemoveAllAuras()
    wipe(AuraScan.AurasToScan)
end

------------------------------------------------------------------------------------------------------------------------------
--aura parser

---@class details_auratimeline : table
---@field time number time when this aura had its status changed
---@field appliedTime number time when this aura was applied
---@field removedTime number time when this aura was removed
---@field expireTime number
---@field event string
---@field sourceName string
---@field targetName string
---@field targetGUID string
---@field spellId number
---@field closed boolean when true this received received aura In and Out
---@field duration number
---@field elapsedTime number
---@field auraInstanceID number
---@field addTimeLineTable details_auratimeline

---@type table<number, aurainfo>
local unitAuraTable
local targetUnitGUID
local targetName
local bIsInitialScan = false
local timeLastAuraRemovedFromTimeLine = 0
local sourceNameLastAuraRemovedFromTimeLine = 0
local auraInstanceIdLastAuraRemovedFromTimeLine = 0

local fAddAura = function(auraInfo)
    ---@cast auraInfo aurainfo
    local spellId = auraInfo.spellId

    if (auraInfo and auraInfo.auraInstanceID and spellId) then
        if (AuraScan.IsAuraAdded(spellId)) then
            unitAuraTable[auraInfo.auraInstanceID] = auraInfo
            auraInfo.targetName = targetName
            auraInfo.targetGUID = targetUnitGUID

            if (bIsInitialScan) then
                if (auraInfo.name == "Prescience") then
                    Details222.DebugMsg("|cFFFFFF00INIT! Prescience Added.")
                end
            end

            --callback
            for callback in pairs(AuraScan.Callbacks) do
                callback("AURA_UPDATE", targetUnitGUID, auraInfo, "BUFF_UPTIME_IN")
            end

            if (AuraScan.AurasToTimeline[spellId]) then
                local sourceName = Details:GetFullName(auraInfo.sourceUnit)
                local lastestEventAdded = AuraScan.AuraTimelineStorage[#AuraScan.AuraTimelineStorage]

                if (not lastestEventAdded or lastestEventAdded.time ~= GetTime() or lastestEventAdded.targetName ~= targetName) then
                    ---@type details_auratimeline
                    ---@diagnostic disable-next-line: missing-fields
                    local auraTimelineTable = {
                        appliedTime = GetTime(),
                        time = GetTime(),
                        removedTime = 0,
                        expireTime = auraInfo.expirationTime, --the format is GetTime()
                        event = "BUFF_UPTIME_IN",
                        sourceName = sourceName,
                        targetName = targetName,
                        targetGUID = targetUnitGUID,
                        spellId = spellId,
                        closed = false,
                        duration = auraInfo.duration,
                        elapsedTime = 0,
                        auraInstanceID = auraInfo.auraInstanceID,
                        name = auraInfo.name,
                        combatTime = Details:GetCurrentCombat():GetCombatTime(),
                    }
                    AuraScan.AuraTimelineStorage[#AuraScan.AuraTimelineStorage+1] = auraTimelineTable
                end
            end
        end
    end
end

local fUpdateAura = function(auraInfo)
    if (AuraScan.AurasToTimeline[auraInfo.spellId]) then
        --find the aura in the timeline and update the expiration time
        for i = #AuraScan.AuraTimelineStorage, 1, -1 do
            local auraTimelineTable = AuraScan.AuraTimelineStorage[i]
            if (auraTimelineTable.auraInstanceID == auraInfo.auraInstanceID) then
                local elapsedTime = GetTime() - auraTimelineTable.time
                auraTimelineTable.elapsedTime = auraTimelineTable.elapsedTime + elapsedTime

                auraTimelineTable.time = GetTime()
                auraTimelineTable.expireTime = auraInfo.expirationTime
                auraTimelineTable.duration = auraInfo.duration
                auraTimelineTable.closed = false
                Details222.DebugMsg("|cFFFFFF00REFRESH! Prescience Updated. Duration:", auraTimelineTable.duration)
                break
            end
        end
    end
end

local fRemoveAura = function(auraInstanceId)
    local auraInfo = unitAuraTable[auraInstanceId]
    if (auraInfo) then
        unitAuraTable[auraInstanceId] = nil

        --callback
        for callback in pairs(AuraScan.Callbacks) do
            callback("AURA_UPDATE", targetUnitGUID, auraInfo, "BUFF_UPTIME_OUT")
        end

        if (AuraScan.AurasToTimeline[auraInfo.spellId]) then
            local sourceName = Details:GetFullName(auraInfo.sourceUnit)
            if (timeLastAuraRemovedFromTimeLine ~= GetTime() or auraInstanceIdLastAuraRemovedFromTimeLine ~= auraInstanceId) then
                --find the aura in the timeline and update the elapsedTime
                local auraTimelineTableWhenAdded
                for i = #AuraScan.AuraTimelineStorage, 1, -1 do
                    local auraTimelineTable = AuraScan.AuraTimelineStorage[i]
                    if (auraTimelineTable.auraInstanceID == auraInstanceId) then
                        local elapsedTime = GetTime() - auraTimelineTable.time
                        auraTimelineTable.elapsedTime = auraTimelineTable.elapsedTime + elapsedTime
                        auraTimelineTableWhenAdded = auraTimelineTable
                        break
                    end
                end

                if (not auraTimelineTableWhenAdded) then
                    Details:Msg("|cFFFF9900AuraScan: fRemoveAura() addedAura was not found in the timeline.")
                    return
                end

                --create a new table with the information when the aura was removed
                ---@type details_auratimeline
                local auraClosure = {
                    time = GetTime(),
                    appliedTime = auraTimelineTableWhenAdded.appliedTime,
                    removedTime = GetTime(),
                    elapsedTime = auraTimelineTableWhenAdded.elapsedTime,
                    expireTime = 0,
                    event = "BUFF_UPTIME_OUT",
                    sourceName = sourceName,
                    targetName = targetName,
                    targetGUID = targetUnitGUID,
                    spellId = auraInfo.spellId,
                    closed = true,
                    duration = auraInfo.expirationTime,
                    auraInstanceID = auraInstanceId,
                    addTimeLineTable = auraTimelineTableWhenAdded,
                    name = auraInfo.name,
                    combatTime = Details:GetCurrentCombat():GetCombatTime(),
                }

                AuraScan.AuraTimelineStorage[#AuraScan.AuraTimelineStorage+1] = auraClosure

                timeLastAuraRemovedFromTimeLine = GetTime()
                sourceNameLastAuraRemovedFromTimeLine = sourceName
                auraInstanceIdLastAuraRemovedFromTimeLine = auraInstanceId
            end
        end
    end
end

local fFullAuraScan = function(unitId, unitGUID)
    local maxCount = nil
    local bUsePackedAura = true
    unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
    AuraUtil.ForEachAura(unitId, "HELPFUL", maxCount, fAddAura, bUsePackedAura)
end

function AuraScan.OnEvent(frame, eventName, unitId, updateInfo)
    --get the unit guid
    local unitGUID = UnitGUID(unitId)
    if (not unitGUID) then
        return
    end

    if (not updateInfo or updateInfo.isFullUpdate) then
        AuraScan.WipeUnitAuraTable(unitGUID)
        unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
        fFullAuraScan(unitId, unitGUID)
        return
    end

    targetUnitGUID = unitGUID
    targetName = Details:GetFullName(unitId)

    --auras added
    if (updateInfo.addedAuras) then
        unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
        for auraIndex = 1, #updateInfo.addedAuras do
            ---@type aurainfo
            local auraInfo = updateInfo.addedAuras[auraIndex]
            --print(unitId, targetName, auraInfo.name)
            fAddAura(auraInfo)
        end
    end

    --auras updated
    if (updateInfo.updatedAuraInstanceIDs) then
        unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
        for auraIndex = 1, #updateInfo.updatedAuraInstanceIDs do
            local auraInstanceId = updateInfo.updatedAuraInstanceIDs[auraIndex]
            ---@type aurainfo
            local auraInfo = C_UnitAuras.GetAuraDataByAuraInstanceID(unitId, auraInstanceId)
            if (auraInfo and auraInfo.auraInstanceID) then
                if (auraInfo.name == "Prescience") then
                    local thisAuraInfo = unitAuraTable[auraInfo.auraInstanceID]
                    if (not thisAuraInfo) then
                        Details222.DebugMsg("|cFFFFAA00Prescience Updated, but not found in the table.")
                    end
                end
                fUpdateAura(auraInfo)
            end
        end
    end

    --auras removed
    if (updateInfo.removedAuraInstanceIDs) then
        unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(unitGUID)
        for auraIndex = 1, #updateInfo.removedAuraInstanceIDs do
            local auraInstanceId = updateInfo.removedAuraInstanceIDs[auraIndex]
            fRemoveAura(auraInstanceId)
        end
    end
end


------------------------------------------------------------------------------------------------------------------------------

local scanFrame = CreateFrame("frame", "DetailsAuraScanFrame", UIParent)

function AuraScan.Start()
    AuraScan.Enabled = true

    --clear the up table holding the current player being scanned
    wipe(unitAuraTable or {})
    --clear the cache of auras
    AuraScan.WipeAllUnitAuraTables()

    bIsInitialScan = true

    --do the initial aura scan
    for i = 1, 4 do --need to change this on raid groups, atm it's only for party
        local unitId = "party" .. i
        if (UnitExists(unitId)) then
            local unitGUID = UnitGUID(unitId)
            fFullAuraScan(unitId, unitGUID)
        end
    end

    local unitId = "player"
    local unitGUID = UnitGUID(unitId)
    fFullAuraScan(unitId, unitGUID)

    bIsInitialScan = false

    DetailsAuraScanFrame:RegisterEvent("UNIT_AURA")
    DetailsAuraScanFrame:SetScript("OnEvent", AuraScan.OnEvent)
end

function AuraScan.Stop()
    if (AuraScan.Enabled) then
        AuraScan.Enabled = false
        DetailsAuraScanFrame:UnregisterEvent("UNIT_AURA")
        DetailsAuraScanFrame:SetScript("OnEvent", nil)

        --close all opened auras (by running the remove function)
        for targetGUID, auras in pairs(AuraScan.UnitAurasStorage) do
            unitAuraTable = AuraScan.GetOrCreateUnitAuraTable(targetGUID)
            for auraInstanceID, auraInfo in pairs(auras) do
                targetUnitGUID = targetGUID
                targetName = auraInfo["targetName"]
                fRemoveAura(auraInstanceID)
            end
        end

        --callback
        for callback in pairs(AuraScan.Callbacks) do
            callback("TIMELINE_READY", AuraScan.AuraTimelineStorage)
        end
    else
        Details:Msg("AuraScan.Stop() called, but AuraScan is not enabled.")
    end
end