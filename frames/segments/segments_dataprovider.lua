
---@type details
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
---@type detailsframework
local detailsFramework = DetailsFramework
local _, Details222 = ...

---@class detailssegmentselectionmidnight : table
---@field GenerateGameSegmentData fun():table
---@field GenerateDetailsData fun():table

---@type detailssegmentselectionmidnight
local segmentSelectionMidnight = Details222.SegmentSelectionMidnight
local defaultStatusBarColor = segmentSelectionMidnight.settings.defaultStatusBarColor
local overallAndCurrentStatusBarColor = segmentSelectionMidnight.settings.overallAndCurrentStatusBarColor

---@param durationSeconds number?
---@return string
local formatElapsedTime = function(durationSeconds)
    if not durationSeconds or issecretvalue(durationSeconds) then
        return ""
    end

    local totalSeconds = math.floor(durationSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

---@return table
function segmentSelectionMidnight.GenerateGameSegmentData() --~data
    ---@type damagemeter_availablecombat_session[]
    local segments = Details222.B.GetAllSegments()
    local data = {}
    local maxDurationByName = {}

    for i = 1, #segments do
        local segment = segments[i]
        local segmentName = segment.name
        local duration = segment.durationSeconds or 0
        local currentMaxDuration = maxDurationByName[segmentName] or 0
        if duration > currentMaxDuration then
            maxDurationByName[segmentName] = duration
        end
    end

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }

    data[#data + 1] = {
        separator = true,
    }

    for i = #segments, 1, -1 do
        local segment = segments[i]
        local sessionName = segment.name
        local segmentName = segment.name
        if not sessionName or sessionName == "" then
            sessionName = DAMAGE_METER_COMBAT_NUMBER:format(segment.sessionID or 0)
        end

        local icon = Details:GetTextureAtlas("segment-icon-current")
        local maxDurationForThisName = maxDurationByName[segmentName] or 0
        local combatObject = Details:GetTwinCombat(segment.sessionID)
        if combatObject then
            local segmentIcon, zoneIcon = combatObject:GetCombatIcon()
            if segmentIcon then
                icon = segmentIcon
            end
        end
        data[#data + 1] = {
            icon = icon,
            statusbarColor = defaultStatusBarColor,
            leftText = sessionName,
            rightText = formatElapsedTime(segment.durationSeconds),
            durationPercent = maxDurationForThisName > 0 and (segment.durationSeconds or 0) / maxDurationForThisName or 0,
            segmentId = segment.sessionID,
        }
    end

    return data
end

---@return table
function segmentSelectionMidnight.GenerateDetailsData() --~data
    local data = {}
    local segmentsTable = Details:GetCombatSegments()
    local maxDuration = 1
    local segmentAmount = #segmentsTable

    for i = segmentAmount, 1, -1 do
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local duration = thisCombat:GetCombatTime() or 0
            if duration > maxDuration then
                maxDuration = duration
            end
        end
    end

    --[=[
    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }
    --]=]

    ---@type savedsegment[]
    local savedSegments = Details:GetSavedSegments()
    local totalAdded = 0
    for i = 1, #savedSegments do
        local savedSegment = savedSegments[i]
        local combatData = savedSegment.combatData
        local combatName = savedSegment.header.name

        local combatObject = segmentSelectionMidnight.DecompressSegment(combatData)
        local duration = combatObject:GetCombatTime()
        local combatIcon, categoryIcon = combatObject:GetCombatIcon()
        --print("duration", duration, detailsFramework:IntegerToTimer(duration))
        data[#data + 1] = {
            icon = combatIcon or categoryIcon or segmentSelectionMidnight.settings.defaultIcon,
            statusbarColor = defaultStatusBarColor,
            leftText = "(*) " .. combatName .. " (" .. date("%Y-%m-%d %H:%M:%S", savedSegment.header.date) .. ")",
            rightText = detailsFramework:IntegerToTimer(duration),
            durationPercent = maxDuration > 0 and duration / maxDuration or 0,
            combatObject = combatObject,
            segmentId = -i, -- negative segmentId to differentiate from non-saved segments
        }

        totalAdded = totalAdded + 1
    end

    for i = 1, segmentAmount do
        ---@type combat
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local combatName = thisCombat:GetCombatName()
            combatName = detailsFramework:RemoveColorCodes(combatName)
            combatName = detailsFramework:RemoveTextureCodes(combatName)

            local duration = thisCombat:GetCombatTime()
            local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

            data[#data + 1] = {
                icon = combatIcon or categoryIcon or segmentSelectionMidnight.settings.defaultIcon,
                statusbarColor = defaultStatusBarColor,
                leftText = combatName or "--x--x--",
                rightText = detailsFramework:IntegerToTimer(duration),
                durationPercent = maxDuration > 0 and duration / maxDuration or 0,
                combatObject = thisCombat,
                segmentId = i,
            }
        end
    end

    return data
end

