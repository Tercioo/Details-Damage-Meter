
local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

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
        return rowData.amount
    elseif (sortKey == "percent") then
        return rowData.amount
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
    if (offset == 0 and windowFrame:GetCurrentAttributeId() ~= 9) then
        sortDataBySelectedColumn(self, data)
    end

    local header = self:GetHeader()

    if #data == 0 then
        self.NoDataPanel:Show()
    else
        self.NoDataPanel:Hide()
    end

    local statusBarTexture = windowFrame:GetStatusBarTexture()

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line

            line:ResetFramesToHeaderAlignment()
            local secondColumnWidth = header:GetColumnWidth(2)
            local thirdColumnWidth = header:GetColumnWidth(3)

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)
            line:AddFrameToHeaderAlignment(line.IconFrame)

            line.Texts[1]:SetText(thisData.rank and tostring(thisData.rank) or "")
            line:AddFrameToHeaderAlignment(line.Texts[1])

            line.Texts[2]:SetText(thisData.name)

            if not issecretvalue(thisData.name) then
                Details:BleachFontString(line.Texts[2])
                breakdownMidnight.SetupFontString(line, line.Texts[2])
                line.Texts[2]:SetParent(line.StatusBar)
                line.Texts[2]:SetDrawLayer("artwork")
                line.Texts[2]:SetText(thisData.name)

                local width = line.Texts[2]:GetStringWidth()
                if not issecretvalue(width) then
                    detailsFramework:TruncateText(line.Texts[2], thirdColumnWidth)
                end
            end
            line.Texts[2]:Show()
            line:AddFrameToHeaderAlignment(line.Texts[2])

            for textIndex = 3, #line.Texts do
                local value = thisData.texts[textIndex - 2]
                line.Texts[textIndex]:SetText(value)
                line:AddFrameToHeaderAlignment(line.Texts[textIndex])
            end

            line.IconFrame:SetScript("OnEnter", iconOnEnter)
            line.IconFrame:SetScript("OnLeave", iconOnLeave)
            line.IconFrame.data = thisData.data

            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2 + 5)
            line.StatusBar:SetStatusBarTexture(statusBarTexture)
            line.StatusBar:SetMinMaxValues(0, thisData.maxAmount)
            line.StatusBar:SetValue(thisData.amount)

            line:AlignWithHeader(header, "left")
        end
    end

    header.refreshColumn = nil
end

---@param spellData table
local assignSpellRank = function(spellData)
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

    ---@param thisSpellScroll detailsbreakdownmidnight_sectionscroll
    spellScroll.RefreshMe = function(thisSpellScroll)
        local attributeId = windowFrame:GetCurrentAttributeId()
        local attributeName = Details.ApocalypseAttributeNames[attributeId]
        thisSpellScroll.AttributeNameText:SetText(attributeName or "")

        local spellData, headerLabels, isDude = breakdownMidnight.GenerateSpellData(windowFrame)
        thisSpellScroll.isSpells = isDude
        if spellData then
            if attributeId ~= 9 then
                assignSpellRank(spellData)
            end
            breakdownMidnight.UpdateSectionHeader(windowFrame, breakdownMidnight.Enums.SectionIds.Spells, headerLabels)
            thisSpellScroll:SetData(spellData)
            thisSpellScroll:Refresh()
        else
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
    frame:SetSize(totalWidth, buttonSize)
    frame:SetPoint("bottom", spellScroll, "bottom", 0, 1)
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Spells] = refreshFunc
