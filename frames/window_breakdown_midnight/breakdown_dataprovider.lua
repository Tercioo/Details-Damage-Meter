
local Details = _G.Details
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local addonName, Details222 = ...
local _

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

--in the current version of Details! Damage meter, a data table for player is called 'actor' or 'combat_source', these are two different types of data
--the function isActor tells if the data is 'actor' or 'combat_source', an actor will always have on of the two fields: '__is_adapter' or 'serial'

---@param actorObject actor|damagemeter_combat_source
---@return boolean isActor
local isActor = function(actorObject)
    ---@diagnostic disable-next-line: undefined-field
    return (actorObject.__is_adapter or actorObject.serial) and true or false
end

---@param actorObject actor|damagemeter_combat_source
---@return string name, string class, number spec, string serial
local getPlayerInfo = function(actorObject)
    if (isActor(actorObject)) then
        return actorObject.nome, actorObject.classe, actorObject.spec, actorObject.serial
    else
        ---@type damagemeter_combat_source
        local source = actorObject
        return source.name, source.classFilename, detailsFramework:GetSpecIdFromSpecIcon(source.specIconID) or 62, source.sourceGUID
    end
end

---@class detailsbreakdownmidnight_spells
---@field name string spell name
---@field icon number spell icon id
---@field texts string[] array of strings to be shown in the tooltip, the information maybe different based on mob type, in combat, etc.
---@field amount number the amount of damage or healing done by this spell

--spells return a indexed table

---@param spellId number
---@return {name: string, iconID: number} spellInfo
local getSpellInfo = function(spellId)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo then
        ---@diagnostic disable-next-line: missing-fields
        spellInfo = {
            name = "Unknown Spell",
            iconID = 136243, --question mark
        }
    end
    return spellInfo
end

local getActorSpells = function(actorObject)
    ---@type detailsbreakdownmidnight_spells[]
    local spellData = {}

    local spellContainer = actorObject.spells._ActorTable
    local couldGetPercent = false

    for spellId, spellTable in pairs(spellContainer) do
        ---@cast spellTable spelltable
        local spellInfo = getSpellInfo(spellId)
        local spellAmount = spellTable.total
        local spellAmountStr = AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage)
        local dps = spellTable.dps --need review
        local dpsStr = AbbreviateNumbers(dps, Details.abbreviateOptionsDPS)
        local percent = spellAmount / actorObject.total * 100
        local percentStr = format("%.1f%%", percent)

        local data = {
            name = spellInfo.name, --missing pet name
            icon = spellInfo.iconID,
            texts = {spellAmountStr, dpsStr, percentStr},
            amount = spellAmount,
        }

        --[[ there is no targets data atm
            for targetName, total in pairs(spellTable.targets) do
                local targetData = {
                    unitName = targetName,
                    unitClassFilename = "",
                    classification = "",
                    isPet = false,
                    isMob = false,
                    amount = total,
                    specIconID = 0,
                }
                spellData.targets[#spellData.targets + 1] = targetData
            end
        --]]
        spellData[#spellData + 1] = data
    end

    local header
    if not couldGetPercent then
        header = {"Spell Name", "Amount", "DPS"}
    else
        header = {"Spell Name", "Amount", "DPS", "%"}
    end

    return spellData, header
end

--[=[
["combatSpells"] =  {
   [1] =  {
      ["overkillAmount"] = 0,
      ["combatSpellDetails"] =  {
         ["isPet"] = false,
         ["unitClassFilename"] = "HUNTER",
         ["amount"] = 0,
         ["unitName"] = "Hvi-Azralon",
         ["specIconID"] = 461112,
         ["isMob"] = false,
         ["classification"] = "",
      },
      ["isDeadly"] = false,
      ["creatureName"] = "",
      ["amountPerSecond"] = 1230.6256103516,
      ["totalAmount"] = 15165,
      ["isAvoidable"] = false,
      ["spellID"] = 0,
   },
},
--]=]

local getSourceTargets = function(sourceSpells, classFileName)
    local targetData = {}
    local totalAmount = sourceSpells.totalAmount
    local maxAmount = sourceSpells.maxAmount

    for i = 1, #sourceSpells.combatSpells do
        local spellDetails = sourceSpells.combatSpells[i]
        local percent
        if not issecretvalue(maxAmount) then
            percent = spellDetails.totalAmount / maxAmount * 100
        end

        local data = {
            name = spellDetails.combatSpellDetails.unitName,
            icon = spellDetails.combatSpellDetails.specIconID,
            texts = {AbbreviateNumbers(spellDetails.totalAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(spellDetails.amountPerSecond, Details.abbreviateOptionsDPS), percent and format("%.1f%%", percent)},
            amount = spellDetails.totalAmount,
            data = spellDetails,
            maxAmount = maxAmount,
        }
        targetData[#targetData + 1] = data
    end

    local header = {"Target Name", "Amount"}
    return targetData, header
end

---@param sourceSpells damagemeter_combat_session_source
---@param classFileName string
local getSourceSpells = function(sourceSpells, classFileName)
    local maxAmount = sourceSpells.maxAmount
    local totalAmount = sourceSpells.totalAmount

    ---@type detailsbreakdownmidnight_spells[]
    local spellData = {}

    local couldGetPercent = false
    for i = 1, #sourceSpells.combatSpells do
        local spellDetails = sourceSpells.combatSpells[i]

        --spell details
        local spellId = spellDetails.spellID
        local spellAmount = spellDetails.totalAmount
        local dps = spellDetails.amountPerSecond
        local isDeadly = spellDetails.isDeadly
        local creatureName = spellDetails.creatureName
        local isAvoidable = spellDetails.isAvoidable
        local overkillAmount = spellDetails.overkillAmount

        --creature info
        local isPet = spellDetails.combatSpellDetails.isPet
        local unitClassFilename = spellDetails.combatSpellDetails.unitClassFilename
        local amount = spellDetails.combatSpellDetails.amount
        local unitName = spellDetails.combatSpellDetails.unitName
        local isMob = spellDetails.combatSpellDetails.isMob
        local classification = spellDetails.combatSpellDetails.classification

        local spellInfo = getSpellInfo(spellId)

        local leftText = ""
        if issecretvalue(creatureName) then
            if classFileName == "HUNTER" then
                leftText = spellInfo.name .. " (|cFFAAAAAA" .. creatureName .. "|r)"
            else
                leftText = spellInfo.name
            end
        else
            leftText = spellInfo.name .. (creatureName and creatureName ~= "" and " (|cFFAAAAAA" .. creatureName .. "|r)" or "")
        end
        --local result = DurationObject:EvaluateElapsedPercent(curve [, modifier])

        local success, percent = pcall(function()
            local curve = C_CurveUtil.CreateCurve()
            curve:AddPoint(0, 0)
            curve:AddPoint(totalAmount, 100.0)
            return curve:Evaluate(spellAmount)
        end)

        if not success then
            ---@type detailsbreakdownmidnight_spells
            local data = {
                icon = spellInfo.iconID,
                name = leftText,
                texts = {AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(dps, Details.abbreviateOptionsDPS)},
                amount = spellAmount,
                data = spellDetails,
                maxAmount = maxAmount,
            }
            spellData[#spellData + 1] = data

        else
            ---@type detailsbreakdownmidnight_spells
            local data = {
                icon = spellInfo.iconID,
                name = leftText,
                texts = {AbbreviateNumbers(spellAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(dps, Details.abbreviateOptionsDPS), format("%.1f%%", percent)},
                amount = spellAmount,
                data = spellDetails,
                maxAmount = maxAmount,
            }
            couldGetPercent = true
            spellData[#spellData + 1] = data
        end
    end

    local header
    if not couldGetPercent then
        header = {"Spell Name", "Amount", "DPS"}
    else
        header = {"Spell Name", "Amount", "DPS", "%"}
    end

    return spellData, header
end

---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.GenerateSpellData(windowFrame)
    local segmentId = windowFrame:GetCurrentSegmentId()
    local segmentType = windowFrame:GetCurrentSegmentType()
    local attributeId = windowFrame:GetCurrentAttributeId()
    local actor = windowFrame:GetPlayerObject()

    local spells, header, isDude
    if (isActor(actor)) then
        spells, header = getActorSpells(actor)
    else
        ---@cast actor damagemeter_combat_source
        --dumpt(actor)
        if attributeId == 9 then
            --print("actor.deathRecapID", actor.deathRecapID)
            local actors = Details222.B.GetSegment(segmentType <= 1 and "Type" or "ID", segmentType <= 1 and segmentType or segmentId, attributeId)
            for i = 1, #actors do
                if not issecretvalue(actors[i].sourceGUID) and actors[i].sourceGUID == actor.sourceGUID then
                    actor = actors[i]
                    break
                end
            end

            local hasRecap, events, maxHealth, link = Details222.Recap.GetRecapInfo(actor.deathRecapID)
            if hasRecap then
                local deathLog = Details:CreateDeathLogTable(actor.name, actor.classFilename, actor.specIconID, events, maxHealth)
                spells = {}
                if hasRecap then
                    local theseEvents = deathLog[1]
                    table.sort(theseEvents, function(a, b)
                        return (a[4] or 0) > (b[4] or 0) --sort by event time, the latest event first
                    end)

                    theseEvents = detailsFramework.table.reverse(theseEvents)
                    local timeOfDeath = deathLog[2]

                    for i = #theseEvents, 1, -1 do
                        local event = theseEvents[i]
                        local spellName, _, spellIcon = Details.getspellinfo(event[2] or 1)

                        local spellId = event[2]
                        local amount = event[3]
                        local eventTime = event[4]
                        local healthPercent = (event[5] or 0) * 100
                        if (healthPercent > 100) then
                            healthPercent = 100
                        end
                        local sourceName = event[6] or UNKNOWN
                        local absorbed = event[7]
                        local spellSchool = event[8]
                        local overkill = event[10]
                        local critical = event[11]
                        local crushing = event[12]

                        local data = {
                            icon = spellIcon,
                            name = spellName .. " (" .. sourceName .. ")", --as the first data is time
                            texts = {format("%.1f", eventTime - timeOfDeath) .. "s", format("-%d", amount), critical and "Critical" or ""},
                            amount = amount,
                            data = event,
                            maxAmount = maxHealth,
                        }
                        spells[#spells + 1] = data
                    end
                end
                return spells, {"Source", "Time", "Amount", "Critical"}, false
            end
            return {}, {"Source", "Time", "Amount", "Critical"}, false
        else

            local guid = actor.sourceGUID
            if issecretvalue(guid) then
                guid = Details222.BParser.GetSerial(actor, actor.specIconID)
            end

            local t = segmentType <= 1
            if guid and not issecretvalue(guid) then
                local sourceSpells = Details222.B.GetSpells(t and DETAILS_SEGMENTTYPE_TYPE or DETAILS_SEGMENTTYPE_ID, t and segmentType or segmentId, attributeId, guid)
                spells, header = getSourceSpells(sourceSpells, actor.classFilename)
                isDude = true

            elseif not guid then
                if (Details222.BParser.IsNotADude(actor) and not issecretvalue(actor.sourceCreatureID)) then
                    local sourceSpells = Details222.B.GetSpells(t and DETAILS_SEGMENTTYPE_TYPE or DETAILS_SEGMENTTYPE_ID, t and segmentType or segmentId, attributeId, nil, actor.sourceCreatureID)
                    if attributeId == 10 then
                        spells, header = getSourceTargets(sourceSpells, actor.classFilename)
                    end
                end
            end
        end
    end

    return spells, header, isDude
end

function breakdownMidnight.GeneratePlayerData(windowFrame)
    local segmentType = windowFrame:GetCurrentSegmentType()
    local segmentId = windowFrame:GetCurrentSegmentId()
    local attributeId = windowFrame:GetCurrentAttributeId()

    local playerList = Details222.B.GetSegment(segmentType <= 1 and "Type" or "ID", segmentType <= 1 and segmentType or segmentId, attributeId)
    ---@cast playerList damagemeter_combat_session
    if not playerList then
        return Details222.B.GetEmptySegment(), {"Name"}
    end

    return playerList, {"Name"}
end

---@param durationSeconds number?
---@return string
local formatElapsedTime = function(durationSeconds)
    if (type(durationSeconds) ~= "number" or durationSeconds <= 0) then
        return "00:00"
    end

    local totalSeconds = math.floor(durationSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

function breakdownMidnight.GenerateSegmentData(windowFrame)
    local segments = Details222.B.GetAllSegments()
    segments = detailsFramework.table.reverse(segments) --show the latest segment first

    local segmentData = {}
    for i = 1, #segments do
        local segment = segments[i]
        segmentData[i] = {
            sessionID = segment.sessionID,
            name = segment.name,
            elapsed = formatElapsedTime(segment.durationSeconds),
            icon = segment.icon,
        }
    end

    table.insert(segmentData, 1, { --current session
        sessionID = 0,
        name = DAMAGE_METER_CURRENT_SESSION,
        elapsed = "",
        icon = "",
    })
    table.insert(segmentData, 1, { --overall segment{
        sessionID = -1,
        name = DAMAGE_METER_OVERALL_SESSION,
        elapsed = "",
        icon = "",
    })

    return segmentData, {"", "", "Name"}
end
