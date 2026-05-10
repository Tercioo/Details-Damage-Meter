
local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

local maxComparisonColumns = 10
local positiveDeltaColor = {1, 0.25, 0.25, 1} --other source did more than current spell amount
local negativeDeltaColor = {0.55, 0.55, 0.55, 1} --other source did less than current spell amount
local neutralDeltaColor = {0.82, 0.82, 0.82, 1}

---@param value number?
---@return string
local formatAmount = function(value)
    if (type(value) ~= "number") then
        return "0"
    end
    return AbbreviateNumbers(value, Details.abbreviateOptionsDamage)
end

---formats the delta between a comparison source amount and the current spell amount as a signed percentage of the current amount.
---@param delta number?
---@param currentAmount number?
---@return string
local formatDelta = function(delta, currentAmount)
    if (type(delta) ~= "number" or delta == 0) then
        return "0"
    end

    --when the current amount is zero a percentage is undefined; fall back to the raw delta so the user still sees the magnitude.
    if (type(currentAmount) ~= "number" or currentAmount == 0) then
        if (delta > 0) then
            return "+" .. AbbreviateNumbers(delta, Details.abbreviateOptionsDamage)
        end

        return "-" .. AbbreviateNumbers(math.abs(delta), Details.abbreviateOptionsDamage)
    end

    local percent = (delta / currentAmount) * 100

    if (percent > 0) then
        return string.format("+%.0f%%", percent)
    end

    return string.format("%.0f%%", percent)
end

---@param fontString fontstring
---@param value number?
local setDeltaTextColor = function(fontString, value)
    if (type(value) ~= "number" or value == 0) then
        fontString:SetTextColor(unpack(neutralDeltaColor))
        return
    end

    if (value > 0) then
        fontString:SetTextColor(unpack(positiveDeltaColor))
    else
        fontString:SetTextColor(unpack(negativeDeltaColor))
    end
end

---@param name string?
---@return string
local getActorDisplayName = function(name)
    if (type(name) ~= "string" or name == "") then
        return "Unknown"
    end

    if (issecretvalue(name)) then
        if (Details222.IsTOCBiggerOrEqualTo(120005)) then
            return Ambiguate(name, "none")
        end
        return UnitName(name) or name
    end

    local nameWithNoRealm = detailsFramework:RemoveRealmName(name)
    return nameWithNoRealm
end

---@param windowFrame detailsbreakdownmidnight_window
---@return number?
local getComparableSegmentId = function(windowFrame)
    local segmentType = windowFrame:GetCurrentSegmentType()
    if (segmentType == 1) then --current segment always resolves from live list
        local allSegments = Details222.B.GetAllSegments()
        local currentSegment = allSegments[1]
        local currentSegmentId = currentSegment and currentSegment.sessionID
        if (currentSegmentId >= 1) then
            return currentSegmentId
        end
    end

    local segmentId = windowFrame:GetCurrentSegmentId()
    if (segmentId >= 1) then
        return segmentId
    end

    return segmentId
end

---@param headerData table
---@param key string
---@param width number
---@param text string
local addHeaderColumn = function(headerData, key, width, text)
    headerData[#headerData + 1] = {
        key = key,
        text = text,
        width = width,
        align = "right",
        canSort = false,
        dataType = "number",
        offset = 0,
        useSavedWidth = false,
    }
end

---@param sectionFrame frame
---@param comparisonSources detailsbreakdownmidnight_comparesource[]
---@return table
local buildHeaderData = function(sectionFrame, comparisonSources)
    local compareColumnAmount = math.min(maxComparisonColumns, 1 + #comparisonSources) --first column is the current segment amount
    local frameWidth = math.floor(sectionFrame:GetWidth() or 240)
    local defaultNameWidth = 120
    local iconWidth = 22
    local minValueWidth = 45
    local extraPadding = 10

    local availableWithoutIcon = math.max(80, frameWidth - iconWidth - extraPadding)
    local valueWidth = math.max(minValueWidth, math.floor((availableWithoutIcon - defaultNameWidth) / compareColumnAmount))
    local nameWidth = math.max(70, availableWithoutIcon - (valueWidth * compareColumnAmount))

    local headerData = {
        {key = "icon", text = "", width = false, align = "left", canSort = false, dataType = "string", offset = 0},
        {key = "name", text = "Spell Name", width = nameWidth, align = "left", canSort = false, dataType = "string", offset = 0, useSavedWidth = false},
    }

    addHeaderColumn(headerData, "current", valueWidth, "")

    for i = 1, #comparisonSources do
        local source = comparisonSources[i]
        addHeaderColumn(headerData, "cmp" .. i, valueWidth, source.columnName)
    end

    return headerData
end

---@param line detailsbreakdownmidnight_line
---@return fontstring[]
local ensureComparisonTexts = function(line)
    local comparisonTexts = line.ComparisonTexts
    if (comparisonTexts) then
        return comparisonTexts
    end

    comparisonTexts = {}
    line.ComparisonTexts = comparisonTexts

    for i = 1, maxComparisonColumns do
        local fontString = line.StatusBar:CreateFontString("$parentComparisonText" .. i, "overlay", "GameFontNormal")
        breakdownMidnight.SetupFontString(line, fontString)
        fontString:SetJustifyH("RIGHT")
        comparisonTexts[i] = fontString
    end

    return comparisonTexts
end

---@param spellRows table[]?
---@return detailsbreakdownmidnight_comparespellrow[]
local buildSpellRowsFromCurrentData = function(spellRows)
    ---@type table<number, detailsbreakdownmidnight_comparespellrow>
    local spellMap = {}
    ---@type detailsbreakdownmidnight_comparespellrow[]
    local orderedRows = {}

    if (type(spellRows) ~= "table") then
        return orderedRows
    end

    for i = 1, #spellRows do
        local spellRow = spellRows[i]
        local spellId = spellRow and spellRow.spellID
        local amount = spellRow and spellRow.amount

        if (type(spellId) == "number" and type(amount) == "number") then
            local row = spellMap[spellId]
            if (not row) then
                row = {
                    spellID = spellId,
                    name = spellRow.name or "Unknown Spell",
                    icon = spellRow.icon or sections.genericIcon,
                    amount = 0,
                }
                spellMap[spellId] = row
                orderedRows[#orderedRows + 1] = row
            end

            row.amount = row.amount + amount
        end
    end

    table.sort(orderedRows, function(a, b)
        return (a.amount or 0) > (b.amount or 0)
    end)

    return orderedRows
end

---@param sourceSpells damagemeter_combat_session_source?
---@return table<number, number>
local buildSpellAmountMap = function(sourceSpells)
    local spellAmountMap = {}
    if (not sourceSpells or type(sourceSpells.combatSpells) ~= "table") then
        return spellAmountMap
    end

    local combatSpells = sourceSpells.combatSpells
    for i = 1, #combatSpells do
        local spellData = combatSpells[i]
        local spellId = spellData and spellData.spellID
        local amount = spellData and spellData.totalAmount

        if (type(spellId) == "number" and type(amount) == "number") then
            spellAmountMap[spellId] = (spellAmountMap[spellId] or 0) + amount
        end
    end

    return spellAmountMap
end

---@param actorObject actor|damagemeter_combat_source|nil
---@return string|nil
local getActorName = function(actorObject)
    if (not actorObject) then
        return nil
    end

    ---@diagnostic disable-next-line: undefined-field
    return actorObject.name or actorObject.nome
end

---@param actorObject actor|damagemeter_combat_source|nil
---@return number|nil
local getActorSpecIcon = function(actorObject)
    if (not actorObject) then
        return nil
    end

    return actorObject.specIconID
end

---@param actorList damagemeter_combat_source[]?
---@return table<string, damagemeter_combat_source>
local buildActorMapByName = function(actorList)
    local actorByName = {}
    if (type(actorList) ~= "table") then
        return actorByName
    end

    for i = 1, #actorList do
        local actor = actorList[i]
        local name = actor and actor.name
        if (type(name) == "string" and name ~= "") then
            actorByName[name] = actor
        end
    end

    return actorByName
end

---@param currentSegmentId number
---@param attributeId number
---@param actorObject actor|damagemeter_combat_source
---@return detailsbreakdownmidnight_comparesource[]
local buildComparisonSources = function(currentSegmentId, attributeId, actorObject)
    ---@type detailsbreakdownmidnight_comparesource[]
    local comparisonSources = {}
    local maxExtraSources = maxComparisonColumns - 1
    local maxPreviousSegments = 4

    local playerGuid = UnitGUID("player")
    for offset = 1, maxPreviousSegments do
        if (#comparisonSources >= maxExtraSources) then
            break
        end
        local previousSegmentId = currentSegmentId - offset
        if (previousSegmentId < 1) then
            break
        end
        if (playerGuid and not issecretvalue(playerGuid)) then
            local playerSpells = Details222.B.GetSpells("ID", previousSegmentId, attributeId, playerGuid)
            local playerSpellMap = buildSpellAmountMap(playerSpells)
            if (next(playerSpellMap) ~= nil) then
                comparisonSources[#comparisonSources + 1] = {
                    columnName = "-" .. offset,
                    spellAmountMap = playerSpellMap,
                }
            end
        end
    end

    if (#comparisonSources >= maxExtraSources) then
        return comparisonSources
    end

    local previousSegmentId = currentSegmentId - 1
    if (previousSegmentId < 1) then
        return comparisonSources
    end

    local currentSegment = Details222.B.GetSegment("ID", currentSegmentId, attributeId)
    local previousSegment = Details222.B.GetSegment("ID", previousSegmentId, attributeId)

    local currentActorList = currentSegment and Details222.B.GetSegmentInfo(currentSegment)
    local previousActorList = previousSegment and Details222.B.GetSegmentInfo(previousSegment)
    local previousActorsByName = buildActorMapByName(previousActorList)

    local selectedActorName = getActorName(actorObject)
    local selectedSpecIcon = getActorSpecIcon(actorObject)
    if (not selectedSpecIcon) then
        return comparisonSources
    end

    ---@type damagemeter_combat_source[]
    local sameSpecActors = {}
    if (type(currentActorList) == "table") then
        for i = 1, #currentActorList do
            local actor = currentActorList[i]
            if (actor and actor.specIconID == selectedSpecIcon and actor.name ~= selectedActorName) then
                sameSpecActors[#sameSpecActors + 1] = actor
            end
        end
    end

    table.sort(sameSpecActors, function(actorA, actorB)
        return (actorA.totalAmount or 0) > (actorB.totalAmount or 0)
    end)

    local namesAdded = {}

    for i = 1, #sameSpecActors do
        if (#comparisonSources >= maxExtraSources) then
            break
        end

        local actorToCompare = sameSpecActors[i]
        local actorName = actorToCompare.name
        if (actorName and not namesAdded[actorName]) then
            namesAdded[actorName] = true
            local previousActorData = previousActorsByName[actorName]
            local sourceGuid = previousActorData and previousActorData.sourceGUID
            if (sourceGuid and not issecretvalue(sourceGuid)) then
                local actorSpells = Details222.B.GetSpells("ID", previousSegmentId, attributeId, sourceGuid)
                local actorSpellMap = buildSpellAmountMap(actorSpells)
                comparisonSources[#comparisonSources + 1] = {
                    columnName = getActorDisplayName(actorName),
                    spellAmountMap = actorSpellMap,
                }
            end
        end
    end

    return comparisonSources
end

---@param currentSpells detailsbreakdownmidnight_comparespellrow[]
---@param comparisonSources detailsbreakdownmidnight_comparesource[]
---@return table[]
local buildComparisonRows = function(currentSpells, comparisonSources)
    local rows = {}

    for i = 1, #currentSpells do
        local currentSpell = currentSpells[i]
        local currentAmount = currentSpell.amount or 0
        local spellId = currentSpell.spellID

        local compareTexts = {}
        local compareValues = {}
        compareTexts[1] = formatAmount(currentAmount)
        compareValues[1] = nil

        for sourceIndex = 1, #comparisonSources do
            local sourceData = comparisonSources[sourceIndex]
            local sourceAmount = sourceData.spellAmountMap[spellId] or 0
            local delta = sourceAmount - currentAmount
            compareValues[sourceIndex + 1] = delta
            compareTexts[sourceIndex + 1] = formatDelta(delta, currentAmount)
        end

        rows[#rows + 1] = {
            spellID = spellId,
            name = currentSpell.name,
            icon = currentSpell.icon,
            compareTexts = compareTexts,
            compareValues = compareValues,
        }
    end

    return rows
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshCompareSection = function(self, data, offset, totalLines)
    local header = self.Header
    local headerTable = header:GetHeaderTable() or {}
    local nameColumnWidth = header:GetColumnWidth(2) or 0
    local activeComparisonColumns = self.ActiveComparisonColumns or 1
    local defaultTextColor = Details.breakdown_general.font_color
    local windowFrame = self:GetWindow()

    local statusBarWidth = 0
    for columnIndex = 2, #headerTable do
        if (header:DoesColumnExists(columnIndex)) then
            statusBarWidth = statusBarWidth + (header:GetColumnWidth(columnIndex) or 0)
        end
    end

    local resizerCount = math.max(0, #headerTable - 1)

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]

        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()
            line:SetScript("OnClick", nil)

            local comparisonTexts = ensureComparisonTexts(line)

            line.ExpandButton:Hide()
            line.ExpandButton:EnableMouse(false)
            line.ExpandButton:SetScript("OnClick", nil)
            line.IconFrame:SetScript("OnEnter", nil)
            line.IconFrame:SetScript("OnLeave", nil)
            line.IconFrame.data = nil

            line.StatusBar:SetWidth(statusBarWidth + header.options.reziser_width * resizerCount)
            line.StatusBar:SetStatusBarTexture(windowFrame:GetStatusBarTexture())
            line.StatusBar:SetMinMaxValues(0, 1)
            line.StatusBar:SetValue(0)
            line.StatusBar:SetStatusBarColor(1, 1, 1, 0)

            line:AddFrameToHeaderAlignment(line.IconFrame)
            line:AddFrameToHeaderAlignment(line.Texts[1])

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)

            local spellName = thisData.name or ""
            line.Texts[1]:SetText(spellName)
            line.Texts[1]:SetTextColor(unpack(defaultTextColor))
            if (spellName ~= "" and not issecretvalue(spellName)) then
                detailsFramework:TruncateText(line.Texts[1], nameColumnWidth)
            end

            for compareIndex = 1, maxComparisonColumns do
                local fontString = comparisonTexts[compareIndex]
                if (compareIndex <= activeComparisonColumns) then
                    local text = thisData.compareTexts and thisData.compareTexts[compareIndex] or ""
                    local value = thisData.compareValues and thisData.compareValues[compareIndex]
                    fontString:SetText(text)
                    if (compareIndex == 1) then
                        fontString:SetTextColor(unpack(defaultTextColor))
                    else
                        setDeltaTextColor(fontString, value)
                    end
                    fontString:Show()
                    line:AddFrameToHeaderAlignment(fontString)
                else
                    fontString:SetText("")
                    fontString:SetTextColor(unpack(defaultTextColor))
                    fontString:Hide()
                end
            end

            line:AlignWithHeader(self.Header, "left")
            line:SetData(thisData)
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.CompareScrollInit(sectionFrame, windowFrame)
    local comparisonScroll = windowFrame.ComparisonScroll
    local sectionIds = breakdownMidnight.Enums.SectionIds

    ---@param thisComparisonScroll detailsbreakdownmidnight_sectionscroll
    comparisonScroll.RefreshMe = function(thisComparisonScroll)
        local actorObject = windowFrame:GetPlayerObject()
        local attributeId = windowFrame:GetCurrentAttributeId()
        local segmentId = getComparableSegmentId(windowFrame)

        local compareRows = {}
        local comparisonSources = {}

        if (actorObject and type(attributeId) == "number" and type(segmentId) == "number" and segmentId >= 1) then
            local currentSpellRows = {}
            local spellScroll = windowFrame:GetSpellScroll()
            if (spellScroll and type(spellScroll.RawSpellData) == "table" and #spellScroll.RawSpellData > 0) then
                currentSpellRows = buildSpellRowsFromCurrentData(spellScroll.RawSpellData)
            else
                local generatedSpellData = breakdownMidnight.GenerateSpellData(windowFrame)
                currentSpellRows = buildSpellRowsFromCurrentData(generatedSpellData)
            end

            if (#currentSpellRows > 0) then
                comparisonSources = buildComparisonSources(segmentId, attributeId, actorObject)
                compareRows = buildComparisonRows(currentSpellRows, comparisonSources)
            end
        end

        thisComparisonScroll.ActiveComparisonColumns = math.min(maxComparisonColumns, 1 + #comparisonSources)

        local headerData = buildHeaderData(sectionFrame, comparisonSources)
        breakdownMidnight.UpdateSectionHeader(windowFrame, sectionIds.Compare, headerData)
        thisComparisonScroll:SetData(compareRows)
        thisComparisonScroll:Refresh()
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Compare] = refreshCompareSection
