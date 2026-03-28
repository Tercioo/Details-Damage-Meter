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

local lineAmount = 32
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

---@param linesInUse number
---@return number
local calculateMainFrameHeight = function(linesInUse)
    local visibleLines = math.max(linesInUse or 0, 0)
    local lineSpacing = math.max(visibleLines - 1, 0) * linePadding
    local linesContentHeight = lineTopOffset + (visibleLines * lineHeight) + lineSpacing
    return frameTopOffset + linesContentHeight
end

local mainSegmentFrame

local mainFrameMixin = {
    GetInstance = function(self)
        return self.instance
    end,

    GetStatusBarTexture = function(self)
        local instance = self:GetInstance()
        if instance then
            local SharedMedia = LibStub("LibSharedMedia-3.0")
            local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
            if textureFile then
                return textureFile
            end
        end
        return [[Interface\TargetingFrame\NameplateFill]]
    end,

    SetDataProviders = function(self, leftProvider, rightProvider)
        if leftProvider ~= nil then
            assert(type(leftProvider) == "function", "Left provider must be a function.")
            self.CustomLeftDataProvider = leftProvider
        end

        if rightProvider ~= nil then
            assert(type(rightProvider) == "function", "Right provider must be a function.")
            self.CustomRightDataProvider = rightProvider
        end
    end,

    RefreshMe = function(self)
        local leftProvider = self.CustomLeftDataProvider or self.LeftDataProvider
        local rightProvider = self.CustomRightDataProvider or self.RightDataProvider
        local leftData = leftProvider(self)
        local rightData = rightProvider(self)

        assert(type(leftData) == "table", "Left provider must return a table.")
        assert(type(rightData) == "table", "Right provider must return a table.")

        local linesInUseLeft = self.LeftPanel:Refresh(leftData)
        local linesInUseRight = self.RightPanel:Refresh(rightData)

        local mainFrameHeight = calculateMainFrameHeight(math.max(linesInUseLeft, linesInUseRight))
        self:SetHeight(mainFrameHeight)
    end,

    CloseFrame = function(self)
        self:Hide()
    end,
}

---@param line segmentframeline
local onClickLine = function(line) --~click õnclick ~onclick
    local panel = line:GetParent()
    local mainFrame = panel:GetParent()
    local sourceType = line.dataFor
    local rowData = line.rowData
    local instance = mainFrame:GetInstance()
    assert(instance, "Instance not found for segment selection frame.")

    if sourceType == "blizzard" then
        local bForceRefresh = true
        local afterSetSession = function()
            instance:RefreshWindow(bForceRefresh)
            mainFrame:RefreshMe()
        end

        local selectExpired = function(sessionId)
            instance:SetNewSegmentId(sessionId, byUser)
            instance:SetSegmentType(2, bForceRefresh, byUser)
            afterSetSession()
        end
        local selectCurrent = function()
            instance:SetSegmentType(1, bForceRefresh, byUser)
            afterSetSession()
        end
        local selectOverall = function()
            instance:SetSegmentType(0, bForceRefresh, byUser)
            afterSetSession()
        end

        if rowData.segmentId == -1 then
            selectOverall()
        elseif rowData.segmentId == 0 then
            selectCurrent()
        else
            selectExpired(rowData.segmentId)
        end

    elseif sourceType == "details" then
        instance:SetSegmentId(rowData.segmentId, byUser)
        Details.no_fade_animation = true
        Details:UpdateCombatObjectInUse(instance)
        Details:RefreshMainWindow(instance, true)
        Details.no_fade_animation = false
    end

    --mainFrame:CloseFrame()
end

---@param durationSeconds number?
---@return string
local formatElapsedTime = function(durationSeconds)
    if not durationSeconds or issecretvalue(durationSeconds) then
        return ""
    end

    local totalSeconds = math.floor(durationSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

---@return table
local generateGameSegmentData = function() --~data
    ---@type damagemeter_availablecombat_session[]
    local segments = Details222.B.GetAllSegments()
    local data = {}
    local maxDurationByName = {}

    for i = 1, #segments do
        local segment = segments[i]
        local segmentName = segment.name
        local duration = segment.durationSeconds or 0
        local currentMaxDuration = maxDurationByName[segmentName] or 0
        if duration > currentMaxDuration then
            maxDurationByName[segmentName] = duration
        end
    end

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }

    for i = #segments, 1, -1 do
        local segment = segments[i]
        local sessionName = segment.name
        local segmentName = segment.name
        if not sessionName or sessionName == "" then
            sessionName = DAMAGE_METER_COMBAT_NUMBER:format(segment.sessionID or 0)
        end

        local icon = Details:GetTextureAtlas("segment-icon-current")
        local maxDurationForThisName = maxDurationByName[segmentName] or 0
        local combatObject = Details:GetTwinCombat(segment.sessionID)
        if combatObject then
            local segmentIcon, zoneIcon = combatObject:GetCombatIcon()
            if segmentIcon then
                icon = segmentIcon
            end
        end
        data[#data + 1] = {
            icon = icon,
            statusbarColor = defaultStatusBarColor,
            leftText = sessionName,
            rightText = formatElapsedTime(segment.durationSeconds),
            durationPercent = maxDurationForThisName > 0 and (segment.durationSeconds or 0) / maxDurationForThisName or 0,
            segmentId = segment.sessionID,
        }
    end

    return data
end

---@return table
local generateDetailsData = function() --~data
    local data = {}
    local segmentsTable = Details:GetCombatSegments()
    local maxDuration = 1
    local segmentAmount = #segmentsTable

    for i = segmentAmount, 1, -1 do
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local duration = thisCombat:GetCombatTime() or 0
            if duration > maxDuration then
                maxDuration = duration
            end
        end
    end

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }

    for i = 1, segmentAmount do
        ---@type combat
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local combatName = thisCombat:GetCombatName()
            local duration = thisCombat:GetCombatTime()
            local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

            data[#data + 1] = {
                icon = combatIcon or categoryIcon or defaultIcon,
                statusbarColor = defaultStatusBarColor,
                leftText = combatName or "",
                rightText = detailsFramework:IntegerToTimer(duration),
                durationPercent = maxDuration > 0 and duration / maxDuration or 0,
                combatObject = thisCombat,
                segmentId = i,
            }
        end
    end

    return data
end

---@param parent frame
---@param index number
---@return segmentframeline
local createLine = function(parent, index) --~line
    local line = CreateFrame("button", nil, parent)
    ---@cast line segmentframeline
    line:EnableMouse(true)
    line:SetPoint("topleft", parent, "topleft", lineInsetX, -(lineTopOffset + ((index - 1) * (lineHeight + linePadding))))
    line:SetPoint("topright", parent, "topright", -lineInsetX, -(lineTopOffset + ((index - 1) * (lineHeight + linePadding))))
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

    line:SetScript("OnClick", onClickLine)

    return line
end

---@param panel segmentframelist
---@param rowData table
---@return boolean
local isLineSelected = function(panel, rowData)
    local mainFrame = panel:GetParent()
    local instance = mainFrame:GetInstance()

    if panel.dataFor == "blizzard" then
        if instance:GetApocalypseSourceType() == Details222.Apocalypse.TypeDetails then
            return false
        end

        local selectedSegmentType = instance:GetSegmentType()
        if rowData.segmentId == -1 then
            return selectedSegmentType == 0

        elseif rowData.segmentId == 0 then
            return selectedSegmentType == 1

        else
            return selectedSegmentType == 2 and rowData.segmentId == instance:GetNewSegmentId()
        end

    elseif panel.dataFor == "details" then
        if instance:GetApocalypseSourceType() == Details222.Apocalypse.TypeGame then
            return false
        end
        return rowData.segmentId == instance:GetSegmentId()
    end

    return false
end

---@param parent frame
---@param title string
---@param dataFor "blizzard"|"details"
---@return segmentframelist
local createSegmentFrame = function(parent, title, dataFor) --~frame
    local panel = CreateFrame("frame", "$parent", parent, "BackdropTemplate")
    ---@cast panel segmentframelist
    --detailsFramework:ApplyStandardBackdrop(panel)
    panel.dataFor = dataFor

    function panel:HideAllLines()
        for i = 1, lineAmount do
            self.Lines[i]:Hide()
            self.Lines[i].rowData = nil
            self.Lines[i].dataFor = nil
        end
    end

    function panel:GetLine(index)
        return self.Lines[index]
    end

    local titleText = panel:CreateFontString(nil, "overlay", "GameFontNormal")
    titleText:SetPoint("topleft", panel, "topleft", 10, -8)
    titleText:SetText(title)
    panel.TitleText = titleText

    panel.Lines = {}
    for i = 1, lineAmount do
        local line = createLine(panel, i)

        if dataFor == "details" then --~disabled ~disable
            if Details222.Apocalypse.IsServerInCombat() then
                line:EnableMouse(false)
                line.DisabledFrame:Show()
            else
                line:EnableMouse(true)
                line.DisabledFrame:Hide()
                --line:EnableMouse(false)
                --line.DisabledFrame:Show()
            end
        else
            line:EnableMouse(true)
            line.DisabledFrame:Hide()
        end

        panel.Lines[i] = line
    end

    ---@param data table
    function panel:Refresh(data) --~refresh
        local lineIndex = math.min(#data, lineAmount)

        self:HideAllLines()
        local statusBarTexture = self:GetParent():GetStatusBarTexture()
        local leftTextMaxWidth = frameWidth - 55
        local linesInUse = 0

        for i = 1, lineAmount do
            local thisData = data[i]
            if thisData then
                local line = self:GetLine(lineIndex)
                local icon = thisData.icon
                local leftText = thisData.leftText
                local rightText = thisData.rightText
                local percent = detailsFramework.Math.Clamp(0, 1, thisData.durationPercent)

                detailsFramework:SetAtlas(line.Icon, icon)

                line.LeftText:SetText(leftText or "")
                detailsFramework:TruncateText(line.LeftText, leftTextMaxWidth)

                line.RightText:SetText(rightText or "")

                line.StatusBar:SetStatusBarTexture(statusBarTexture)
                local statusBarColor = thisData.statusbarColor
                line.StatusBar:SetStatusBarColor(unpack(statusBarColor))
                line.StatusBar:SetValue(percent or 0)

                if isLineSelected(self, thisData) then
                    line.SelectedTexture:Show()
                else
                    line.SelectedTexture:Hide()
                end

                line.rowData = thisData
                line.dataFor = self.dataFor
                lineIndex = lineIndex - 1
                line:Show()

                linesInUse = linesInUse + 1
            end
        end

        return linesInUse
    end

    return panel
end

---@return segmentframe
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
    --mainFrame:SetClampedToScreen(true)
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

        self.mouseOutsideTime = self.mouseOutsideTime + elapsedTime
        if self.mouseOutsideTime > hideDelay then
            self:Hide()
        end
    end)

    local columnWidth = frameWidth

    local leftPanel = createSegmentFrame(mainFrame, "Segments", "blizzard")
    leftPanel:SetPoint("topleft", mainFrame, "topleft", horizontalPadding, -topOffset)
    leftPanel:SetPoint("bottomleft", mainFrame, "bottomleft", horizontalPadding, bottomOffset)
    leftPanel:SetWidth(columnWidth)
    mainFrame.LeftPanel = leftPanel

    local rightPanel = createSegmentFrame(mainFrame, "Segments", "details")
    rightPanel:SetPoint("topleft", leftPanel, "topright", gap, 0)
    rightPanel:SetPoint("bottomleft", mainFrame, "bottomleft", horizontalPadding + columnWidth + gap, bottomOffset)
    rightPanel:SetWidth(columnWidth)
    mainFrame.RightPanel = rightPanel

    mainFrame.LeftDataProvider = generateGameSegmentData
    mainFrame.RightDataProvider = generateDetailsData
    mainFrame.CustomLeftDataProvider = nil
    mainFrame.CustomRightDataProvider = nil

    return mainFrame
end

---@param leftProvider? fun(): table
---@param rightProvider? fun(): table
function segmentSelectionMidnight.Show(instance, leftProvider, rightProvider)
    ---@type segmentframe
    local mainFrame = segmentSelectionMidnight.GetFrame()
    Mixin(mainFrame, mainFrameMixin)

    if leftProvider or rightProvider then
        mainFrame:SetDataProviders(leftProvider, rightProvider)
    end
    assert(instance, "Instance is required to show the segment selection frame.")
    mainFrame.instance = instance
    mainFrame:RefreshMe()
    mainFrame:Show()
    GameCooltip:Hide()

    return mainFrame
end
