
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
---@type detailsframework
local detailsFramework = DetailsFramework
local _, Details222 = ...

---@class detailssegmentselectionmidnight : table
---@field GetFrame fun(): segmentframe
---@field Show fun(instance:instance, leftProvider:fun()?, rightProvider:fun()?):segmentframe
local segmentSelectionMidnight = Details222.SegmentSelectionMidnight or {}
Details222.SegmentSelectionMidnight = segmentSelectionMidnight

---@class segmentframe : frame
---@field mouseOutsideTime number
---@field instance instance
---@field LeftPanel segmentframelist
---@field RightPanel segmentframelist
---@field LeftDataProvider fun(window:segmentframe):table?
---@field RightDataProvider fun(window:segmentframe):table?
---@field CustomLeftDataProvider fun(window:segmentframe):table?
---@field CustomRightDataProvider fun(window:segmentframe):table?
---@field GetInstance fun(self:segmentframe):instance?
---@field SetDataProviders fun(self:segmentframe, leftProvider:fun(), rightProvider:fun())
---@field RefreshMe fun(self:segmentframe)
---@field CloseFrame fun(self:segmentframe)

---@class segmentframelist : frame
---@field TitleText fontstring
---@field Lines segmentframeline[]
---@field dataFor "blizzard"|"details"
---@field Refresh fun(self:segmentframelist, rows:table):number
---@field GetLine fun(self:segmentframelist, index:number):segmentframeline
---@field HideAllLines fun(self:segmentframelist)

---@class segmentframeline : button
---@field StatusBar statusbar
---@field Icon texture
---@field LeftText fontstring
---@field RightText fontstring
---@field SelectedTexture texture
---@field HighlightTexture texture
---@field DisabledFrame frame
---@field DisabledTexture texture
---@field dataFor "blizzard"|"details"|nil
---@field rowData table

local lineAmount = 33
local lineHeight = 18
local linePadding = 1
local defaultIcon = [[Interface\ICONS\INV_Misc_QuestionMark]]
local lineFontSize = 10
local frameWidth = 180
local lineInsetX = 2
local lineTopOffset = 26
local hideDelay = 0.4
local defaultStatusBarColor = {0.1, 0.42, 0.6, 0.25}
local overallAndCurrentStatusBarColor = {.5, 0.5, 0.5, 0.25}
local frameTopOffset = 6
local byUser = true

segmentSelectionMidnight.settings = {
    defaultStatusBarColor = defaultStatusBarColor,
    overallAndCurrentStatusBarColor = overallAndCurrentStatusBarColor,
    lineAmount = lineAmount,
    lineHeight = lineHeight,
    linePadding = linePadding,
    defaultIcon = defaultIcon,
    lineFontSize = lineFontSize,
    frameWidth = frameWidth,
    lineInsetX = lineInsetX,
    lineTopOffset = lineTopOffset,
    hideDelay = hideDelay,
    frameTopOffset = frameTopOffset,
    byUser = byUser,
}

local mainSegmentFrame

---@param parent frame
---@param index number
---@return segmentframeline
local createLine = function(parent, index) --~line
    local line = CreateFrame("button", nil, parent)
    ---@cast line segmentframeline
    line:EnableMouse(true)

    local yOffset = (index - 1) * (lineHeight + linePadding) + 3
    line:SetPoint("bottomleft", parent, "bottomleft", lineInsetX, yOffset)
    line:SetPoint("bottomright", parent, "bottomright", -lineInsetX, yOffset)
    line:SetHeight(lineHeight)

    local statusBar = CreateFrame("StatusBar", nil, line)
    ---@cast statusBar statusbar
    statusBar:SetAllPoints()
    statusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    line.StatusBar = statusBar

    local icon = statusBar:CreateTexture(nil, "overlay")
    icon:SetPoint("left", statusBar, "left", 2, 0)
    icon:SetSize(lineHeight - 4, lineHeight - 4)
    icon:SetTexture(defaultIcon)
    line.Icon = icon

    local leftText = statusBar:CreateFontString(nil, "overlay", "GameFontNormal")
    leftText:SetPoint("left", icon, "right", 2, 0)
    detailsFramework:SetFontSize(leftText, lineFontSize)
    line.LeftText = leftText

    local rightText = statusBar:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
    rightText:SetPoint("right", line, "right", -2, 0)
    detailsFramework:SetFontSize(rightText, lineFontSize)
    line.RightText = rightText

    local highlightTexture = line:CreateTexture(nil, "highlight")
    highlightTexture:SetAllPoints()
    highlightTexture:SetColorTexture(1, 1, 1, 0.08)
    line.HighlightTexture = highlightTexture

    local selectedTexture = line:CreateTexture(nil, "artwork")
    selectedTexture:SetAllPoints()
    selectedTexture:SetColorTexture(1, 0.82, 0, 0.2)
    selectedTexture:Hide()
    line.SelectedTexture = selectedTexture

    local disabledFrame = CreateFrame("frame", nil, statusBar)
    disabledFrame:SetAllPoints()
    line.DisabledFrame = disabledFrame

    local disabledTexture = disabledFrame:CreateTexture(nil, "overlay")
    disabledTexture:SetAllPoints()
    disabledTexture:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    line.DisabledTexture = disabledTexture

    line:SetScript("OnClick", segmentSelectionMidnight.OnClickLine)

    return line
end

---the main frame is formed by two segment frames that list segments, this function create a segment frame
---@param parent frame
---@param title string
---@param dataFor "blizzard"|"details"
---@return segmentframelist
local createSegmentFrameList = function(parent, title, dataFor) --~frame
    local segmentFrameList = CreateFrame("frame", "$parent", parent, "BackdropTemplate")
    ---@cast segmentFrameList segmentframelist
    segmentFrameList.dataFor = dataFor

    Mixin(segmentFrameList, segmentSelectionMidnight.SegmentFrameMixin)

    local titleText = segmentFrameList:CreateFontString(nil, "overlay", "GameFontNormal")
    titleText:SetPoint("topleft", segmentFrameList, "topleft", 10, -8)
    titleText:SetText(title)
    segmentFrameList.TitleText = titleText

    segmentFrameList.Lines = {}
    for i = 1, lineAmount do
        local line = createLine(segmentFrameList, i)

        if dataFor == "details" then --~disabled ~disable
            if Details222.Apocalypse.IsServerInCombat() then
                line:EnableMouse(false)
                line.DisabledFrame:Show()
            else
                line:EnableMouse(true)
                line.DisabledFrame:Hide()
            end
        else
            line:EnableMouse(true)
            line.DisabledFrame:Hide()
        end

        segmentFrameList.Lines[i] = line
    end

    return segmentFrameList
end


function segmentSelectionMidnight.GetFrame() --~main
    if mainSegmentFrame then
        return mainSegmentFrame
    end

    local mainFrame = CreateFrame("frame", "DetailsMidnightSegmentSelectionFrame", UIParent)
    ---@cast mainFrame segmentframe
    local gap = 1
    local horizontalPadding = 1
    local topOffset = 1
    local bottomOffset = 1
    local contentBottomPadding = 2
    local linesContentHeight = lineTopOffset + (lineAmount * lineHeight) + ((lineAmount - 1) * linePadding) + contentBottomPadding
    local frameHeight = topOffset + bottomOffset + linesContentHeight

    if GameCooltipFrame1 then
        GameCooltipFrame1:HookScript("OnShow", function(self)
            if mainFrame:IsShown() then
                mainFrame:Hide()
            end
        end)
    end

    mainFrame:SetSize(frameWidth * 2 + gap + (horizontalPadding * 2), frameHeight)
    mainFrame:SetPoint("center", UIParent, "center", 0, 0)
    mainFrame:SetFrameStrata("TOOLTIP")
    mainFrame:EnableMouse(true)
    mainSegmentFrame = mainFrame

    local roundedCornerPreset = {
        roundness = 12,
        color = {0.1216*0.7, 0.1176*0.7, 0.1294*0.7, 0.98},
        border_color = {.2, .2, .2, 0.98},
    }

    detailsFramework:AddRoundedCornersToFrame(mainFrame, roundedCornerPreset)
    mainFrame:Hide()
    mainFrame.mouseOutsideTime = 0

    mainFrame:SetScript("OnShow", function(self)
        self.mouseOutsideTime = 0
    end)

    mainFrame:SetScript("OnHide", function(self)
        self.CustomLeftDataProvider = nil
        self.CustomRightDataProvider = nil
        self.mouseOutsideTime = 0
    end)

    mainFrame:SetScript("OnUpdate", function(self, elapsedTime)
        if self:IsMouseOver() then
            self.mouseOutsideTime = 0
            return
        end

        local instance = self:GetInstance()
        local segmentButton = instance:GetSegmentButton()
        if segmentButton and segmentButton:IsMouseOver() then
            return
        end

        self.mouseOutsideTime = self.mouseOutsideTime + elapsedTime

        if self.mouseOutsideTime > hideDelay then
            self:Hide()
        end
    end)

    local columnWidth = frameWidth

    local leftPanel = createSegmentFrameList(mainFrame, "Temporarily", "blizzard")
    leftPanel:SetPoint("topleft", mainFrame, "topleft", horizontalPadding, -topOffset)
    leftPanel:SetPoint("bottomleft", mainFrame, "bottomleft", horizontalPadding, bottomOffset)
    leftPanel:SetWidth(columnWidth)
    mainFrame.LeftPanel = leftPanel

    local rightPanel = createSegmentFrameList(mainFrame, "Permanent", "details")
    rightPanel:SetPoint("topleft", leftPanel, "topright", gap, 0)
    rightPanel:SetPoint("bottomleft", mainFrame, "bottomleft", horizontalPadding + columnWidth + gap, bottomOffset)
    rightPanel:SetWidth(columnWidth)
    mainFrame.RightPanel = rightPanel

    mainFrame.LeftDataProvider = segmentSelectionMidnight.GenerateGameSegmentData
    mainFrame.RightDataProvider = segmentSelectionMidnight.GenerateDetailsData
    mainFrame.CustomLeftDataProvider = nil
    mainFrame.CustomRightDataProvider = nil

    return mainFrame
end

---@param leftProvider? fun(): table
---@param rightProvider? fun(): table
function segmentSelectionMidnight.Show(instance, leftProvider, rightProvider)
    ---@type segmentframe
    local mainFrame = segmentSelectionMidnight.GetFrame()
    Mixin(mainFrame, segmentSelectionMidnight.MainFrameMixin)

    if leftProvider or rightProvider then
        mainFrame:SetDataProviders(leftProvider, rightProvider)
    end

    assert(instance, "A window reference is required to show the segment selection frame.")
    mainFrame.instance = instance
    mainFrame:RefreshMe()
    mainFrame:Show()
    GameCooltip:Hide()

    return mainFrame
end
