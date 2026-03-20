
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
local refreshSpellDetailsSection = function(self, data, offset, totalLines)
    local header = self.Header

    for i = 1, totalLines do
        local lineIndex = i + offset
        local line = self:GetLine(i)
        ---@cast line detailsbreakdownmidnight_line
        line:ResetFramesToHeaderAlignment()

        local thisData = data[lineIndex]
        local firstText = ""
        if (thisData) then
            firstText = thisData.name or thisData.text or thisData.label or tostring(thisData)
            line.Icon:SetTexture(thisData.icon or sections.genericIcon)
        else
            line.Icon:SetTexture(sections.genericIcon)
        end

        line:AddFrameToHeaderAlignment(line.IconFrame)
        
        local secondColumnWidth = header:GetColumnWidth(2) or 0
        local thirdColumnWidth = header:GetColumnWidth(3) or 0
        line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
        line.StatusBar:SetStatusBarTexture(self:GetWindow():GetStatusBarTexture())
        
        line.Texts[1]:SetText(firstText)
        line:AddFrameToHeaderAlignment(line.Texts[1])

        for textIndex = 2, #line.Texts do
            local value = thisData and thisData.texts and thisData.texts[textIndex - 1] or ""
            line.Texts[textIndex]:SetText(value)
            line:AddFrameToHeaderAlignment(line.Texts[textIndex])
        end

        line:AlignWithHeader(self.Header, "left")
    end

    header.refreshColumn = nil
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.SpellDetails] = refreshSpellDetailsSection
