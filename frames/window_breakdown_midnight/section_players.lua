
local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

---@param actorObject actor|damagemeter_combat_source|nil
---@return string|nil
local getActorGuid = function(actorObject)
    if (not actorObject) then
        return nil
    end

    ---@diagnostic disable-next-line: undefined-field
    return actorObject.sourceGUID or actorObject.serial
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

---@param line detailsbreakdownmidnight_line
---@param button string
local onClickPlayerLine = function(line, button)
    local windowFrame = line:GetWindow()
    local windowIndex = windowFrame:GetIndex()
    local actorObject = line:GetData()
    local instance = windowFrame:GetInstance()
    local segmentType = windowFrame:GetCurrentSegmentType()
    local segmentId = windowFrame:GetCurrentSegmentId()
    local attributeId = windowFrame:GetCurrentAttributeId()

    Details.OpenApocalypseBreakdown(windowIndex, instance, segmentType, segmentId, attributeId, actorObject)
end

---@param playerData table
local assignPlayerRank = function(playerData)
    local rankOrder = {}
    for i = 1, #playerData do
        rankOrder[i] = playerData[i]
    end

    table.sort(rankOrder, function(playerA, playerB)
        return playerA.totalAmount > playerB.totalAmount
    end)

    for i = 1, #rankOrder do
        rankOrder[i].rank = i
    end
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshFunc = function(self, data, offset, totalLines)
    if not data.combatSources then
        print(debugstack())
    end

    local header = self.Header
    local windowFrame = self:GetWindow()
    local selectedActor = windowFrame:GetPlayerObject()
    local selectedActorGuid = getActorGuid(selectedActor)
    local selectedActorName = getActorName(selectedActor)
    local playerData = data.combatSources
    local maxAmount = data.maxAmount

    for i = 1, totalLines do
        local index = i + offset
        ---@type damagemeter_combat_source
        local thisData = playerData[index]

        if thisData then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()

            local isSelected = false

            if (selectedActorGuid and not issecretvalue(thisData.sourceGUID)) then
                isSelected = thisData.sourceGUID == selectedActorGuid
            elseif (selectedActorName and not issecretvalue(thisData.name)) then
                isSelected = thisData.name == selectedActorName
            end

            if (isSelected) then
                line.SelectedTexture:Show()
            else
                line.SelectedTexture:Hide()
            end

            line.Texts[1]:SetText(index)

            local name = thisData.name
            if not issecretvalue(name) then
                name = detailsFramework:RemoveRealmName(name)
            else
                if Details222.IsTOCBiggerOrEqualTo(120005) then
                    name = Ambiguate(name, "none")
                else
                    name = UnitName(name) or name
                end
            end

            line.Texts[2]:SetText(name)
            line.Icon:SetTexture(thisData.specIconID)

            local secondColumnWidth = header:GetColumnWidth(2) or 0
            local thirdColumnWidth = header:GetColumnWidth(3) or 0
            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(windowFrame:GetStatusBarTexture())
            line.StatusBar:SetMinMaxValues(0, maxAmount)
            line.StatusBar:SetValue(thisData.totalAmount)

            local classColor = RAID_CLASS_COLORS[thisData.classFilename]
            if classColor then
                line.StatusBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            end

            line:AddFrameToHeaderAlignment(line.IconFrame)
            line:AddFrameToHeaderAlignment(line.Texts[1])
            line:AddFrameToHeaderAlignment(line.Texts[2])

            line:AlignWithHeader(self.Header, "left")

            line:SetData(thisData)
            line:SetScript("OnClick", onClickPlayerLine)
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.PlayerSectionInit(sectionFrame, windowFrame)
    local playerScroll = windowFrame.PlayerScroll

    ---@param thisPlayerScroll detailsbreakdownmidnight_sectionscroll
    playerScroll.RefreshMe = function(thisPlayerScroll)
        local playerData, headerLabels = breakdownMidnight.GeneratePlayerData(windowFrame)
        breakdownMidnight.UpdateSectionHeader(windowFrame, breakdownMidnight.Enums.SectionIds.Players, headerLabels)
        --assignPlayerRank(playerData.combatSources)

        local total = #playerData.combatSources
        for i = 1, total do
            playerData[i] = true
        end

        thisPlayerScroll:SetData(playerData)
        thisPlayerScroll:Refresh()
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Players] = refreshFunc
