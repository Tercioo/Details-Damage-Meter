
local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

---@param line detailsbreakdownmidnight_line
---@param button string
local onClickSegmentLine = function(line, button)
    local windowFrame = line:GetWindow()
    local windowIndex = windowFrame:GetIndex()
    local instance = windowFrame:GetInstance()
    local segmentData = line:GetData()
    local segmentId = segmentData.sessionID
    local segmentType = Enum.DamageMeterSessionType.Expired
    local attributeId = windowFrame:GetCurrentAttributeId()
    local actorObject = windowFrame:GetPlayerObject()

    assert(type(segmentId) == "number", "segmentData.sessionID must be a number")
    Details.OpenApocalypseBreakdown(windowIndex, instance, segmentType, segmentId, attributeId, actorObject)
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshSegmentsSection = function(self, data, offset, totalLines)
    local header = self:GetHeader()
    local windowFrame = self:GetWindow()

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()

            local segmentId = thisData.sessionID
            if segmentId == windowFrame:GetCurrentSegmentId() then
                line.SelectedTexture:Show()
            elseif segmentId == -1 and windowFrame:GetCurrentSegmentType() == 0 then
                line.SelectedTexture:Show()
            elseif segmentId == 0 and windowFrame:GetCurrentSegmentType() == 1 then
                line.SelectedTexture:Show()
            else
                line.SelectedTexture:Hide()
            end

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)
            line:AddFrameToHeaderAlignment(line.IconFrame)

            local secondColumnWidth = header:GetColumnWidth(2) or 0
            local thirdColumnWidth = header:GetColumnWidth(3) or 0
            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(windowFrame:GetStatusBarTexture())

            line.Texts[1]:SetText(thisData.elapsed or "")
            line:AddFrameToHeaderAlignment(line.Texts[1])

            local segmentName = thisData.name
            if (not issecretvalue(segmentName) and segmentName == "") then
                segmentName = DAMAGE_METER_COMBAT_NUMBER:format(thisData.sessionID or 0)
            end
            line.Texts[2]:SetText(segmentName)

            if (not issecretvalue(segmentName)) then
                local columnWidth = header:GetColumnWidth(3) - 2
                detailsFramework:TruncateText(line.Texts[2], columnWidth)
            end
            line:AddFrameToHeaderAlignment(line.Texts[2])

            line:AlignWithHeader(header, "left")
            line:SetData(thisData)
            line:SetScript("OnClick", onClickSegmentLine)
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame frame
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.SegmentScrollInit(sectionFrame, windowFrame)
    local segmentScroll = windowFrame.SegmentScroll
    local sectionIds = breakdownMidnight.Enums.SectionIds

    ---@param thisSegmentScroll detailsbreakdownmidnight_sectionscroll
    segmentScroll.RefreshMe = function(thisSegmentScroll)
        local segmentData, headerLabels = breakdownMidnight.GenerateSegmentData(windowFrame)
        breakdownMidnight.UpdateSectionHeader(windowFrame, sectionIds.Segments, headerLabels)
        thisSegmentScroll:SetData(segmentData)
        thisSegmentScroll:Refresh()
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Segments] = refreshSegmentsSection
