
local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections
local assignSpellRank
local collapsedExpandColumnWidth = 1
local defaultExpandColumnWidth = 16

---@param headerData table
---@param width number
local setExpandColumnWidth = function(headerData, width)
    for i = 1, #headerData do
        local columnData = headerData[i]
        if (columnData.key == "expand") then
            columnData.width = width
            columnData.useSavedWidth = false
            return
        end
    end
end

---@param spellRows table[]
---@return boolean
local hasExpandableSpellRows = function(spellRows)
    for i = 1, #spellRows do
        local rowData = spellRows[i]
        if (rowData and rowData.isExpandable) then
            return true
        end
    end
    return false
end

---@param rowData table
---@param sortKey string
---@return string|number
local getSortValue = function(rowData, sortKey)
    if not rowData then --if player data is missing
        return 0
    elseif (sortKey == "name") then
        return rowData.name
    elseif (sortKey == "rank") then
        return rowData.rank
    elseif (sortKey == "amount") then
        return rowData.amount
    elseif (sortKey == "dps") then
        return rowData.dps or rowData.amount
    elseif (sortKey == "percent") then
        return rowData.percent or rowData.amount
    elseif (sortKey == "icon") then
        return rowData.icon
    end

    local value = rowData[sortKey]
    if (value ~= nil) then
        return value
    end

    return ""
end

---@param scrollBox detailsbreakdownmidnight_sectionscroll
---@param data table
local sortDataBySelectedColumn = function(scrollBox, data)
    local _, order, key = scrollBox.Header:GetSelectedColumn()
    if (not key) then
        return
    end

    if not data[1] then
        return
    end

    local v1 = getSortValue(data[1], key)
    if v1 and issecretvalue(v1) then
        return
    end

    table.sort(data, function(t1, t2)
        local v1 = getSortValue(t1, key)
        local v2 = getSortValue(t2, key)

        if (type(v1) == "number" and type(v2) == "number") then
            if (order == "ASC") then
                return v1 < v2
            end
            return v1 > v2
        end

        local s1 = tostring(v1)
        local s2 = tostring(v2)
        if (order == "ASC") then
            return s1 < s2
        end
        return s1 > s2
    end)
end

---@param a table
---@param b table
---@param sortKey string
---@param sortOrder string
---@return boolean
local compareRows = function(a, b, sortKey, sortOrder)
    local v1 = getSortValue(a, sortKey)
    local v2 = getSortValue(b, sortKey)

    if (type(v1) == "number" and type(v2) == "number") then
        if (sortOrder == "ASC") then
            return v1 < v2
        end
        return v1 > v2
    end

    local s1 = tostring(v1 or "")
    local s2 = tostring(v2 or "")
    if (sortOrder == "ASC") then
        return s1 < s2
    end
    return s1 > s2
end

---@param rows table[]
---@param sortKey string
---@param sortOrder string
local sortRowsByKeyAndOrder = function(rows, sortKey, sortOrder)
    table.sort(rows, function(a, b)
        return compareRows(a, b, sortKey, sortOrder)
    end)
end

---@param spellScroll detailsbreakdownmidnight_sectionscroll
---@param spellData table[]
---@return table[]
local buildGroupedSpellDisplayData = function(spellScroll, spellData)
    local header = spellScroll:GetHeader()
    local _, sortOrder, sortKey = header:GetSelectedColumn()
    sortOrder = sortOrder or "DESC"
    sortKey = sortKey or "amount"

    spellScroll.ExpandedSpellGroups = spellScroll.ExpandedSpellGroups or {}

    ---@type table<string, table>
    local groupsByName = {}
    ---@type table[]
    local groups = {}

    for i = 1, #spellData do
        local spellRow = spellData[i]
        local groupKey = spellRow.name or ("unknown_" .. i)
        local group = groupsByName[groupKey]
        if (not group) then
            group = {
                groupKey = groupKey,
                name = spellRow.name,
                icon = spellRow.icon,
                spellID = spellRow.spellID,
                data = spellRow.data,
                maxAmount = spellRow.maxAmount or 0,
                amount = 0,
                dps = 0,
                percent = 0,
                hasPercent = false,
                children = {},
            }
            groupsByName[groupKey] = group
            groups[#groups + 1] = group
        end

        group.children[#group.children + 1] = spellRow
        group.amount = group.amount + (spellRow.amount or 0)
        group.dps = group.dps + (spellRow.dps or 0)
        group.maxAmount = math.max(group.maxAmount, spellRow.maxAmount or 0)

        if (type(spellRow.percent) == "number") then
            group.percent = group.percent + spellRow.percent
            group.hasPercent = true
        end

        if (not group.data) then
            group.data = spellRow.data
        end
        if (not group.icon) then
            group.icon = spellRow.icon
        end
        if (not group.spellID) then
            group.spellID = spellRow.spellID
        end
    end

    ---@type table[]
    local parentRows = {}
    for i = 1, #groups do
        local group = groups[i]
        local isExpandable = #group.children > 1
        local isExpanded = isExpandable and spellScroll.ExpandedSpellGroups[group.groupKey] or false
        local percentText = group.hasPercent and format("%.1f%%", group.percent) or nil

        local dps = group.dps
        if not issecretvalue(dps) then
            dps = breakdownMidnight.FixUnderOneValue(dps)
        end

        parentRows[#parentRows + 1] = {
            groupKey = group.groupKey,
            name = group.name,
            icon = group.icon,
            spellID = group.spellID,
            data = group.data,
            texts = {
                AbbreviateNumbers(group.amount, Details.abbreviateOptionsDamage),
                AbbreviateNumbers(dps, Details.abbreviateOptionsDPS),
                percentText,
            },
            amount = group.amount,
            dps = group.dps,
            percent = group.percent,
            maxAmount = group.maxAmount,
            isExpandable = isExpandable,
            isExpanded = isExpanded,
            children = group.children,
        }
    end

    sortRowsByKeyAndOrder(parentRows, sortKey, sortOrder)
    assignSpellRank(parentRows)

    ---@type table[]
    local displayRows = {}
    for i = 1, #parentRows do
        local parentRow = parentRows[i]
        displayRows[#displayRows + 1] = parentRow

        if (parentRow.isExpandable and parentRow.isExpanded) then
            ---@type table[]
            local childRows = {}
            for childIndex = 1, #parentRow.children do
                childRows[childIndex] = parentRow.children[childIndex]
            end

            sortRowsByKeyAndOrder(childRows, sortKey, sortOrder)

            for childIndex = 1, #childRows do
                local childRow = childRows[childIndex]
                displayRows[#displayRows + 1] = {
                    parentGroupKey = parentRow.groupKey,
                    name = childRow.name,
                    icon = nil,
                    spellID = childRow.spellID,
                    data = childRow.data,
                    texts = childRow.texts,
                    amount = childRow.amount,
                    dps = childRow.dps,
                    percent = childRow.percent,
                    maxAmount = parentRow.maxAmount,
                    rank = nil,
                    isExpandedChild = true,
                }
            end
        end
    end

    return displayRows
end

---@param line detailsbreakdownmidnight_line
local onClickExpandButton = function(line)
    local scroll = line:GetScroll()
    ---@cast scroll detailsbreakdownmidnight_sectionscroll
    local data = line:GetData()
    if (not data or not data.groupKey) then
        return
    end

    scroll.ExpandedSpellGroups = scroll.ExpandedSpellGroups or {}
    scroll.ExpandedSpellGroups[data.groupKey] = not scroll.ExpandedSpellGroups[data.groupKey]
    scroll:Refresh()
end

local iconOnEnter = function(self)
    local spellId = self.data.spellID
    if spellId then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(spellId)
        GameTooltip:Show()
    end
end

local iconOnLeave = function(self)
    GameTooltip:Hide()

end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshFunc = function(self, data, offset, totalLines)
    local windowFrame = self:GetWindow()

    if (self.bUseGroupedSpellData and self.RawSpellData) then
        local groupedData = buildGroupedSpellDisplayData(self, self.RawSpellData)
        self:SetData(groupedData)
        data = groupedData
    elseif (offset == 0 and windowFrame:GetCurrentAttributeId() ~= 9) then
        sortDataBySelectedColumn(self, data)
    end

    local header = self:GetHeader()

    if #data == 0 then
        self.NoDataPanel:Show()
    else
        self.NoDataPanel:Hide()
    end

    local statusBarTexture = windowFrame:GetStatusBarTexture()
    local maxGroupedAmount = 1
    if (self.bUseGroupedSpellData) then
        for rowIndex = 1, #data do
            local rowData = data[rowIndex]
            if (rowData and not rowData.isExpandedChild) then
                maxGroupedAmount = math.max(maxGroupedAmount, rowData.amount or 0)
            end
        end
    end

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line

            line:ResetFramesToHeaderAlignment()
            local rankColumnWidth = header:GetColumnWidth(2) or 0
            local hasExpandColumn = header:DoesColumnExists(4)
            local expandColumnWidth = hasExpandColumn and (header:GetColumnWidth(3) or 0) or 0
            local nameColumnIndex = hasExpandColumn and 4 or 3
            local nameColumnWidth = header:GetColumnWidth(nameColumnIndex) or 0

            line.ExpandButton:Hide()
            line.ExpandButton:EnableMouse(false)
            line.ExpandButton:SetScript("OnClick", nil)
            line.ExpandTexture:SetAlpha(0)
            line.Icon:Show()
            line.Icon:SetTexture(thisData.icon or sections.genericIcon)
            line:AddFrameToHeaderAlignment(line.IconFrame)

            if (thisData.isExpandedChild) then
                line.Texts[1]:SetText("")
                line.Icon:Hide()
                line.Icon:SetTexture(nil)
                line.IconFrame:SetScript("OnEnter", nil)
                line.IconFrame:SetScript("OnLeave", nil)
                line.IconFrame.data = nil
            else
                line.Texts[1]:SetText(thisData.rank and tostring(thisData.rank) or "")
                line.IconFrame:SetScript("OnEnter", iconOnEnter)
                line.IconFrame:SetScript("OnLeave", iconOnLeave)
                line.IconFrame.data = thisData.data
            end
            line:AddFrameToHeaderAlignment(line.Texts[1])
            line:AddFrameToHeaderAlignment(line.ExpandButton)

            line.Texts[2]:SetText(thisData.name)

            if not issecretvalue(thisData.name) then
                Details:BleachFontString(line.Texts[2])
                breakdownMidnight.SetupFontString(line, line.Texts[2])
                line.Texts[2]:SetParent(line.StatusBar)
                line.Texts[2]:SetDrawLayer("artwork")
                line.Texts[2]:SetText(thisData.name)

                local width = line.Texts[2]:GetStringWidth()
                if not issecretvalue(width) then
                    detailsFramework:TruncateText(line.Texts[2], nameColumnWidth)
                end
            end
            line.Texts[2]:Show()
            line:AddFrameToHeaderAlignment(line.Texts[2])

            for textIndex = 3, #line.Texts do
                local value = thisData.texts and thisData.texts[textIndex - 2] or ""
                line.Texts[textIndex]:SetText(value)
                line:AddFrameToHeaderAlignment(line.Texts[textIndex])
            end

            if (thisData.isExpandable) then
                line.ExpandButton:Show()
                line.ExpandButton:EnableMouse(true)
                line.ExpandButton:SetScript("OnClick", function()
                    onClickExpandButton(line)
                end)
                line.ExpandTexture:SetAlpha(0.8)

                if (thisData.isExpanded) then
                    line.ExpandTexture:SetRotation(0)
                else
                    line.ExpandTexture:SetRotation(math.pi / 2)
                end
            end

            local statusBarWidth = rankColumnWidth + expandColumnWidth + nameColumnWidth
            local resizerCount = hasExpandColumn and 3 or 2
            line.StatusBar:SetWidth(statusBarWidth + header.options.reziser_width * resizerCount + 5)
            line.StatusBar:SetStatusBarTexture(statusBarTexture)
            local maxValue = self.bUseGroupedSpellData and maxGroupedAmount or thisData.maxAmount
            if (not maxValue or maxValue <= 0) then
                maxValue = math.max(1, thisData.amount or 0)
            end
            line.StatusBar:SetMinMaxValues(0, maxValue)
            line.StatusBar:SetValue(thisData.amount or 0)

            line:AlignWithHeader(header, "left")
            line:SetData(thisData)
        end
    end

    header.refreshColumn = nil
end

---@param spellData table
assignSpellRank = function(spellData)
    local rankOrder = {}
    for i = 1, #spellData do
        rankOrder[i] = spellData[i]
    end

    if spellData[1] and issecretvalue(spellData[1].amount) then
        return
    end

    table.sort(rankOrder, function(spellA, spellB)
        return (spellA.amount or 0) > (spellB.amount or 0)
    end)

    for i = 1, #rankOrder do
        rankOrder[i].rank = i
    end
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.SpellScrollInit(sectionFrame, windowFrame)
    local spellScroll = windowFrame.SpellScroll
    ---@cast spellScroll detailsbreakdownmidnight_sectionscroll
    local attributeNameText = sectionFrame:CreateFontString("$parentAttributeNameText", "overlay", "GameFontNormal")
    detailsFramework:SetFontSize(attributeNameText, 14)
    attributeNameText:SetPoint("bottom", sectionFrame, "top", 0, 6)
    spellScroll.AttributeNameText = attributeNameText
    spellScroll.ExpandedSpellGroups = spellScroll.ExpandedSpellGroups or {}
    spellScroll.RawSpellData = spellScroll.RawSpellData or {}
    spellScroll.bUseGroupedSpellData = false
    spellScroll.ExpandColumnOpenWidth = spellScroll.ExpandColumnOpenWidth or defaultExpandColumnWidth

    ---@param thisSpellScroll detailsbreakdownmidnight_sectionscroll
    spellScroll.RefreshMe = function(thisSpellScroll)
        local attributeId = windowFrame:GetCurrentAttributeId()
        local attributeName = Details.ApocalypseAttributeNames[attributeId]
        thisSpellScroll.AttributeNameText:SetText(attributeName or "")

        local spellData, headerLabels, isDude = breakdownMidnight.GenerateSpellData(windowFrame)
        thisSpellScroll.isSpells = isDude
        if spellData then
            local shouldGroupSpells = attributeId ~= 9 and isDude and Details.breakdown_spell_tab.nest_players_spells_with_same_name
            thisSpellScroll.RawSpellData = spellData
            thisSpellScroll.bUseGroupedSpellData = shouldGroupSpells

            local header = thisSpellScroll:GetHeader()
            if (header and header:DoesColumnExists(3)) then
                local currentExpandWidth = header:GetColumnWidth(3) or 0
                if (currentExpandWidth > collapsedExpandColumnWidth) then
                    thisSpellScroll.ExpandColumnOpenWidth = currentExpandWidth
                end
            end

            if shouldGroupSpells then
                spellData = buildGroupedSpellDisplayData(thisSpellScroll, spellData)
            elseif attributeId ~= 9 then
                assignSpellRank(spellData)
            end

            local hasExpandableRows = hasExpandableSpellRows(spellData)
            local expandColumnWidth = hasExpandableRows and thisSpellScroll.ExpandColumnOpenWidth or collapsedExpandColumnWidth
            setExpandColumnWidth(headerLabels, expandColumnWidth)

            breakdownMidnight.UpdateSectionHeader(windowFrame, breakdownMidnight.Enums.SectionIds.Spells, headerLabels)
            thisSpellScroll:SetData(spellData)
            thisSpellScroll:Refresh()
        else
            thisSpellScroll.RawSpellData = {}
            thisSpellScroll.bUseGroupedSpellData = false
            thisSpellScroll:SetData({})
            thisSpellScroll:Refresh()
        end
    end

    --when there is no actor to show, show this panel saying there is no data available
    local noDataPanel = CreateFrame("frame", "$parentNoDataPanel", spellScroll)
    noDataPanel:SetAllPoints()
    local noDataText = noDataPanel:CreateFontString("$parentNoDataText", "overlay", "GameFontNormal")
    noDataText:SetPoint("center", noDataPanel, "center", 0, 0)
    noDataText:SetText("No data available or data is secret value.")
    detailsFramework:SetFontSize(noDataText, 14)
    spellScroll.NoDataPanel = noDataPanel
    spellScroll.NoDataText = noDataText

    --create a quick menu to select the attributeId
    local frame = CreateFrame("frame", "$parentAttributeMenu", spellScroll)
    frame.Background = frame:CreateTexture("$parentBackground", "background")
    frame.Background:SetAllPoints()
    frame.Background:SetColorTexture(0, 0, 0, .1)

    local iconIndex = 0
    local latestButton = nil
    local spacing = 4
    local buttonSize = 22
    local quickMenuBottomOffset = 1
    local quickMenuTargetsPadding = 2

    local buttonOnClick = function(self)
        local attributeId = self.attributeId
        --windowFrame:SetPlayerObject(actorObject)

        windowFrame:SetCurrentAttributeId(attributeId)
        local playerScroll = windowFrame:GetPlayerScroll()
        local spellScroll = windowFrame:GetSpellScroll()
        local targetsScroll = windowFrame:GetTargetsScroll()
        playerScroll:RefreshMe()
        spellScroll:RefreshMe()
        targetsScroll:RefreshMe()

        --if there is no data in the spell scroll, try to click the first line of the player scroll
        local data = spellScroll:GetData()
        if data and #data == 0 then
            local playerData = playerScroll:GetData()
            if playerData and playerData.combatSources and #playerData.combatSources > 0 then
                --click on the first button of the playerScroll
                local firstPlayerLine = playerScroll:GetLines()[1]
                if firstPlayerLine and firstPlayerLine:IsShown() then
                    firstPlayerLine:Click()
                end
            end
        end
    end

    local dontAdd = {
        [1] = true,
        [3] = true,
    }

    ---@class detailsbreakdownmidnight_attributebutton : button
    ---@field attributeId number
    ---@field IconHighlight texture
    ---@field Icon texture

    local onEnter = function(self)
        GameCooltip:Preset(2)
        GameCooltip:SetOwner(self, "bottom", "top", 0, -2)
        GameCooltip:AddLine(Details.ApocalypseAttributeNames[self.attributeId] or "")
        GameCooltip:SetOption("FixedWidth", nil)
        GameCooltip:Show()
    end
    local onLeave = function(self)
        GameCooltip:Hide()
    end

    for attribute = 1, Details.atributos[0] do
        local attributeName = Details.atributos.lista[attribute]
        for i = 1, #Details.sub_atributos[attribute].lista do
            local mainDisplay, subDisplay = attribute, i
            local damageMeterType = Details222.BParser.GetAttributeTypeFromDisplay(mainDisplay, subDisplay)
            local canAdd = damageMeterType < 100 and not dontAdd[damageMeterType]

            if canAdd then
                local button = CreateFrame("button", "$parent"..attributeName..i, frame)
                ---@cast button detailsbreakdownmidnight_attributebutton

                button.attributeId = damageMeterType
                button:SetScript("OnClick", buttonOnClick)
                button:SetScript("OnEnter", onEnter)
                button:SetScript("OnLeave", onLeave)

                button.Icon = button:CreateTexture("$parentIcon", "overlay")
				button.Icon:SetTexture(Details.sub_atributos[attribute].icones[i][1])
				button.Icon:SetTexCoord(unpack(Details.sub_atributos[attribute].icones[i][2]))
                button.Icon:SetAllPoints()

                button.IconHighlight = button:CreateTexture("$parentIconHighlight", "highlight")
				button.IconHighlight:SetTexture(Details.sub_atributos[attribute].icones[i][1])
				button.IconHighlight:SetTexCoord(unpack(Details.sub_atributos[attribute].icones[i][2]))
                button.IconHighlight:SetAllPoints()
                button.IconHighlight:SetBlendMode("ADD")
                button.IconHighlight:SetAlpha(0.5)

                button:SetSize(buttonSize, buttonSize)

                iconIndex = iconIndex + 1

                if iconIndex == 1 then
                    button:SetPoint("left", frame, "left", 0, 0)
                else
                    button:SetPoint("left", latestButton, "right", spacing, 0)
                end

                latestButton = button
            end
        end
    end

    local children = {frame:GetChildren()}
    local amountOfButtons = #children
    local totalWidth = amountOfButtons * buttonSize + ((amountOfButtons - 1) * spacing)

    local updateVisibleLines = function(bottomOffset)
        local scrollHeight = spellScroll:GetHeight()
        if (scrollHeight <= 0) then
            return
        end

        -- reserve room for the quick attribute menu at the bottom of the spells area
        local reservedHeight = bottomOffset + buttonSize + 1
        local lineStep = (sections.lineHeight or 20) + 1
        local availableHeight = math.max(0, scrollHeight - reservedHeight)
        local desiredLines = math.max(1, math.floor(availableHeight / lineStep))
        desiredLines = math.min(desiredLines, spellScroll:GetNumFramesCreated())

        local currentLines = spellScroll:GetNumFramesShown()
        if (currentLines ~= desiredLines) then
            spellScroll:SetNumFramesShown(desiredLines)
            spellScroll:Refresh()
        end
    end

    local updateAttributeMenuAnchor = function()
        local bottomOffset = quickMenuBottomOffset

        local targetsScroll = windowFrame:GetTargetsScroll()
        if (targetsScroll) then --all windowFrame has a target scroll, but this maybe called before the scroll gets created.
            local targetsHeader = targetsScroll:GetHeader()
            local spellScrollBottom = spellScroll:GetBottom()
            local targetsHeaderTop = targetsHeader:GetTop()
            if (spellScrollBottom and targetsHeaderTop) then
                local currentMenuBottom = spellScrollBottom + quickMenuBottomOffset
                local desiredMenuBottom = targetsHeaderTop + quickMenuTargetsPadding
                if (currentMenuBottom < desiredMenuBottom) then
                    bottomOffset = bottomOffset + math.ceil(desiredMenuBottom - currentMenuBottom)
                end
            end
        end

        frame:ClearAllPoints()
        frame:SetPoint("bottom", spellScroll, "bottom", 0, bottomOffset)
        updateVisibleLines(bottomOffset)
    end

    spellScroll.UpdateAttributeMenuAnchor = updateAttributeMenuAnchor
    sectionFrame:HookScript("OnShow", updateAttributeMenuAnchor)
    sectionFrame:HookScript("OnSizeChanged", updateAttributeMenuAnchor)

    frame:SetSize(totalWidth, buttonSize)
    updateAttributeMenuAnchor()
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Spells] = refreshFunc
