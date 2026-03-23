
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

local getEDT = function(sourceSpells, classFileName)
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

    local headerData = {
        --align is the columnAlign key in the columnHeader
        --text is the localize string shown in the header
        --if width is false, use the default width
        {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0}, --icon
        {key="rank", text="#", width=false, align="center", canSort=true, dataType="number", offset=0}, --rank
        {key="name", text="From Player", width=170, align="left", canSort=true, dataType="string", offset=0}, --spell name
        {key="amount", text="Amount", width=false, align="right", canSort=true, dataType="number", offset=0}, --amount
        --{key="dps", text="DPS", width=false, align="right", canSort=true, dataType="number", offset=0}, --dps
        --{key="percent", text="Percent", width=false, align="right", canSort=true, dataType="number", offset=0, usable=false}, --percent
    }

    return targetData, headerData
end

local getTargets = function()

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

    local headerData = {
        --align is the columnAlign key in the columnHeader
        --text is the localize string shown in the header
        --if width is false, use the default width
        {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0}, --icon
        {key="rank", text="#", width=false, align="center", canSort=true, dataType="number", offset=0}, --rank
        {key="name", text="Spell Name", width=190, align="left", canSort=true, dataType="string", offset=0}, --spell name
        {key="amount", text="Amount", width=false, align="center", canSort=true, dataType="number", offset=0}, --amount
        {key="dps", text="DPS", width=false, align="center", canSort=true, dataType="number", offset=0}, --dps
        {key="percent", text="Percent", width=false, align="center", canSort=true, dataType="number", offset=0, usable=true}, --percent
    }

    if not couldGetPercent then
        headerData[6].usable = false
    end

    return spellData, headerData
end

function breakdownMidnight.LoadTargets(segmentType, segmentId, actorName)
    local actors = Details222.B.GetSegment(segmentType <= 1 and "Type" or "ID", segmentType <= 1 and segmentType or segmentId, 10)
    --dumpt(actors)
    local targets = {}
    for i = 1, #actors.combatSources do
        local thisActor = actors.combatSources[i]
        local id = thisActor.sourceCreatureID
        if not issecretvalue(id) then
            local t = segmentType <= 1
            local sourceSpells = Details222.B.GetSpells(t and DETAILS_SEGMENTTYPE_TYPE or DETAILS_SEGMENTTYPE_ID, t and segmentType or segmentId, 10, nil, id)
            local result = sourceSpells.combatSpells
            for j = 1, #result do
                local thisResult = result[j]
                local spellDetails = thisResult.combatSpellDetails
                local playerName = spellDetails.unitName
                if playerName == actorName then
                    local percent = thisResult.totalAmount / thisActor.totalAmount * 100
                    local data = {
                        icon = spellDetails.specIconID,
                        name = thisActor.name,
                        texts = {AbbreviateNumbers(thisResult.totalAmount, Details.abbreviateOptionsDamage), AbbreviateNumbers(thisResult.amountPerSecond, Details.abbreviateOptionsDPS), string.format("%.1f%%", percent)},
                        amount = thisResult.totalAmount,
                        data = thisResult,
                        maxAmount = 1,
                    }
                    targets[#targets+1] = data
                end
            end
        end
    end
    return targets
end

---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.GenerateTargetsData(windowFrame)
    local segmentId = windowFrame:GetCurrentSegmentId()
    local segmentType = windowFrame:GetCurrentSegmentType()
    local attributeId = windowFrame:GetCurrentAttributeId()
    local actor = windowFrame:GetPlayerObject()
    local targets = breakdownMidnight.LoadTargets(segmentType, segmentId, actor.name)

    local headerData = {
        {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0},
        {key="rank", text="#", width=false, align="center", canSort=true, dataType="number", offset=0},
        {key="name", text="Target Name", width=180, align="left", canSort=true, dataType="string", offset=0},
        {key="amount", text="Amount", width=false, align="left", canSort=true, dataType="number", offset=0},
        --{key="dps", text="DPS", width=false, align="right", canSort=true, dataType="number", offset=0},
        --{key="percent", text="Percent", width=false, align="right", canSort=true, dataType="number", offset=0},
    }

    return targets, headerData
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

            local headerData = {
                {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0}, --icon
                {key="rank", text="#", width=false, align="center", canSort=true, dataType="number", offset=0}, --rank
                {key="name", text="Source", width=170, align="left", canSort=true, dataType="string", offset=0}, --spell name
                {key="time", text="Time", width=false, align="right", canSort=true, dataType="number", offset=0}, --time
                {key="amount", text="Amount", width=false, align="right", canSort=true, dataType="number", offset=0}, --amount
                {key="critical", text="Critical", width=false, align="left", canSort=true, dataType="string", offset=0}, --critical
            }

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
                            texts = {format("%.1f", eventTime - timeOfDeath) .. "s", format("-%s", Details:comma_value(amount)), critical and "Critical" or ""},
                            amount = healthPercent,
                            data = event,
                            maxAmount = 100,
                        }
                        spells[#spells + 1] = data
                    end
                end

                return spells, headerData, false
            end
            return {}, headerData, false
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

                --for k,v in pairs(spells) do
                --    for k,v in pairs(v) do
                --        print(k,v)
                --    end
                --end

            elseif not guid then
                if (Details222.BParser.IsNotADude(actor) and not issecretvalue(actor.sourceCreatureID)) then
                    local sourceSpells = Details222.B.GetSpells(t and DETAILS_SEGMENTTYPE_TYPE or DETAILS_SEGMENTTYPE_ID, t and segmentType or segmentId, attributeId, nil, actor.sourceCreatureID)
                    if attributeId == 10 then
                        spells, header = getEDT(sourceSpells, actor.classFilename)
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
    local headerData = {
        {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0},
        {key="rank", text="#", width=false, align="center", canSort=true, dataType="number", offset=0},
        {key="name", text="Name", width=150, align="left", canSort=true, dataType="string", offset=0},
    }

    ---@cast playerList damagemeter_combat_session
    if not playerList then
        return Details222.B.GetEmptySegment(), headerData
    end

    return playerList, headerData
end

---@param durationSeconds number?
---@return string
local formatElapsedTime = function(durationSeconds)
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
        local combatTime = segment.durationSeconds
        if not combatTime then
            local combatObject = Details:GetTwinCombat(segment.sessionID)
			if combatObject then
				combatTime = combatObject:GetCombatTime()
            end
        end
        segmentData[i] = {
            sessionID = segment.sessionID,
            name = segment.name,
            elapsed = combatTime and formatElapsedTime(combatTime) or 1,
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

    local headerData = {
        {key="icon", text="", width=false, align="left", canSort=false, dataType="string", offset=0},
        {key="elapsed", text="", width=34, align="left", canSort=true, dataType="string", offset=0},
        {key="name", text="Name", width=137, align="left", canSort=true, dataType="string", offset=0},
    }

    return segmentData, headerData
end
