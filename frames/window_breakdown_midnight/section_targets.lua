
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshTargetsSection = function(self, data, offset, totalLines)
    local header = self:GetHeader()

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)

            line:AddFrameToHeaderAlignment(line.IconFrame)

            local statusBarWidth = 0
            if header:DoesColumnExists(2) then
                statusBarWidth = statusBarWidth + (header:GetColumnWidth(2))
            end
            if header:DoesColumnExists(3) then
                statusBarWidth = statusBarWidth + (header:GetColumnWidth(3))
            end
            line.StatusBar:SetWidth(statusBarWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(self:GetWindow():GetStatusBarTexture())

            line.Texts[1]:SetText(thisData.rank and tostring(thisData.rank) or tostring(lineIndex))
            line:AddFrameToHeaderAlignment(line.Texts[1])

            line.Texts[2]:SetText(thisData.name or thisData.text or thisData.label or tostring(thisData))
            line:AddFrameToHeaderAlignment(line.Texts[2])

            for textIndex = 3, #line.Texts do
                local value = thisData.texts and thisData.texts[textIndex - 2] or ""
                line.Texts[textIndex]:SetText(value)
                line:AddFrameToHeaderAlignment(line.Texts[textIndex])
            end

            line:AlignWithHeader(header, "left")
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.TargetsScrollInit(sectionFrame, windowFrame)
    local targetsScroll = windowFrame.TargetsScroll
    local sectionIds = breakdownMidnight.Enums.SectionIds

    ---@param thisTargetsScroll detailsbreakdownmidnight_sectionscroll
    targetsScroll.RefreshMe = function(thisTargetsScroll)
        local targetsData, headerLabels = breakdownMidnight.GenerateTargetsData(windowFrame)
        if targetsData then
            breakdownMidnight.UpdateSectionHeader(windowFrame, sectionIds.Targets, headerLabels)
            thisTargetsScroll:SetData(targetsData)
            thisTargetsScroll:Refresh()
        else
            thisTargetsScroll:SetData({})
            thisTargetsScroll:Refresh()
        end
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Targets] = refreshTargetsSection
