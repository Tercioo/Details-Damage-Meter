
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

---@class detailsbreakdownmidnight_sections
---@field contentTop number
---@field columnSpacing number
---@field sectionSpacing number
---@field headerHeight number
---@field lineHeight number
---@field genericIcon string
---@field defaultSettings table<string, detailsbreakdownmidnight_sectionsetting>
---@field refreshFunctions table<number, function>

---@class detailsbreakdownmidnight_sectionsetting
---@field width number
---@field height number
---@field resizeTopBorder boolean
---@field resizeBottomBorder boolean
---@field resizeLeftBorder boolean
---@field resizeRightBorder boolean
breakdownMidnight.Sections = {}

---@type detailsbreakdownmidnight_sections
local sections = breakdownMidnight.Sections
sections.contentTop = 30
sections.columnSpacing = 10
sections.sectionSpacing = 10
sections.headerHeight = 20
sections.lineHeight = 20
sections.genericIcon = [[Interface\Icons\INV_Misc_QuestionMark]]
sections.refreshFunctions = sections.refreshFunctions or {}
sections.defaultSettings = {
    players = {width = 200, height = 360, resizeTopBorder = true, resizeBottomBorder = true, resizeLeftBorder = true, resizeRightBorder = true},
    segments = {width = 200, height = 240, resizeTopBorder = true, resizeBottomBorder = true, resizeLeftBorder = true, resizeRightBorder = true},
    spells = {width = 618+28, height = 360, resizeTopBorder = true, resizeBottomBorder = true, resizeLeftBorder = true, resizeRightBorder = true},
    spelldetails = {width = 285, height = 270, resizeTopBorder = true, resizeBottomBorder = true, resizeLeftBorder = true, resizeRightBorder = true},
    targets = {width = 618, height = 240, resizeTopBorder = true, resizeBottomBorder = true, resizeLeftBorder = true, resizeRightBorder = true},
    compare = {width = 240, height = 270, resizeTopBorder = false, resizeBottomBorder = false, resizeLeftBorder = false, resizeRightBorder = false},
}

local colorStrip = {
    {0.1, 0.1, 0.1, 0.5},
    {0.17, 0.17, 0.17, 0.5}
}

---@param sectionKey string
---@param width number
---@param height number
local saveSectionSizeToProfile = function(sectionKey, width, height)
    local profile = breakdownMidnight.GetProfile()
    local sectionSettings = profile[sectionKey]
    sectionSettings.width = width
    sectionSettings.height = height
end

---@param sectionFrame frame
---@param sectionKey string
---@param settings detailsbreakdownmidnight_sectionsetting
local restoreSectionSizeFromProfile = function(sectionFrame, sectionKey, settings)
    local profile = breakdownMidnight.GetProfile()
    local sectionSettings = profile[sectionKey]
    sectionFrame:SetSize(sectionSettings.width, sectionSettings.height)
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshFunc = function(self, data, offset, totalLines)
    local sectionId = self.sectionId
    local sectionRefreshFunc = sections.refreshFunctions[sectionId]
    assert(type(sectionRefreshFunc) == "function", "missing refresh function for sectionId: " .. tostring(sectionId))
    sectionRefreshFunc(self, data, offset, totalLines)
end

---@param sectionHeight number
---@return number
local getSectionLineAmount = function(sectionHeight)
    return math.max(1, math.floor((sectionHeight - sections.headerHeight - 3) / (sections.lineHeight + 1)))
end

---@param sectionId number
---@param sectionHeight number
---@return number
local getSectionLineAmountForSection = function(sectionId, sectionHeight)
    local lineAmount = getSectionLineAmount(sectionHeight)
    if (sectionId == breakdownMidnight.Enums.SectionIds.Spells) then
        lineAmount = math.max(1, lineAmount - 1)
    end
    return lineAmount
end


---@param self df_scrollbox
---@param index number
---@return button
local createLine = function(self, index) --~line
    local line = CreateFrame("button", "$parentLine" .. index, self, "BackdropTemplate")
    ---@cast line detailsbreakdownmidnight_line

    Mixin(line, breakdownMidnight.lineButtonMixin)

    detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)
    PixelUtil.SetPoint(line, "topleft", self, "topleft", 1, -((index - 1) * (sections.lineHeight + 1)))
    PixelUtil.SetPoint(line, "topright", self, "topright", -1, -((index - 1) * (sections.lineHeight + 1)))
    line:SetHeight(sections.lineHeight)

    ---@diagnostic disable-next-line: assign-type-mismatch
    line.StatusBar = CreateFrame("statusbar", "$parentStatusBar", line)
    line.StatusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    line.StatusBar:SetStatusBarColor(1, 0.82, 0, 0.5)
    line.StatusBar:SetMinMaxValues(0, 100)
    line.StatusBar:SetValue(0)
    line.StatusBar:EnableMouse(false)

    line.IconFrame = CreateFrame("frame", "$parentIconFrame", line.StatusBar)
    line.IconFrame:SetSize(sections.lineHeight, sections.lineHeight)

    line.StatusBar:SetPoint("topleft", line.IconFrame, "topright", 2, 0)
    line.StatusBar:SetPoint("bottomleft", line.IconFrame, "bottomright", 2, 0)

    local colorIndex = (index % 2) + 1
    line.Background = line:CreateTexture("$parentBackground", "background")
    line.Background:SetAllPoints()
    line.Background:SetColorTexture(unpack(colorStrip[colorIndex]))

    line.Icon = line.IconFrame:CreateTexture("$parentIcon", "overlay")
    line.Icon:SetSize(sections.lineHeight-2, sections.lineHeight-2)
    line.Icon:SetTexture(sections.genericIcon)
    line.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    line.Icon:SetAllPoints()

    local highlight = line.IconFrame:CreateTexture("$parentHighlight", "highlight")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.1)

    line.Highlight = line:CreateTexture("$parentHighlight", "highlight")
    line.Highlight:SetAllPoints()
    line.Highlight:SetColorTexture(1, 1, 1, 0.15)

    line.SelectedTexture = line.StatusBar:CreateTexture("$parentSelectedTexture", "artwork")
    line.SelectedTexture:SetAllPoints()
    line.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.25)
    line.SelectedTexture:Hide()

    line.Texts = {}
    local textAmount = 6
    for textIndex = 1, textAmount do
        local textFontString = line.StatusBar:CreateFontString("$parentText" .. textIndex, "overlay", "GameFontNormal")
        textFontString:SetJustifyH("LEFT")
        textFontString:SetTextColor(1, 1, 1, 0.9)
        detailsFramework:SetFontSize(textFontString, 10)
        line.Texts[textIndex] = textFontString
    end

    line.Text = line.Texts[1]
    line.Text:SetPoint("left", line.IconFrame, "right", 2, 0)

    line:AddFrameToHeaderAlignment(line.IconFrame)
    for textIndex = 1, #line.Texts do
        line:AddFrameToHeaderAlignment(line.Texts[textIndex])
    end

    return line
end

---@param windowFrame detailsbreakdownmidnight_window
---@param sectionId number
---@param parent frame
---@param name string
---@param width number
---@param height number
---@param title string
---@param data table
---@return detailsbreakdownmidnight_sectionscroll
function breakdownMidnight.CreateSectionScroll(windowFrame, sectionId, parent, name, width, height, title, data)
    local lineAmount = getSectionLineAmountForSection(sectionId, height)

    local scrollBox = detailsFramework:CreateScrollBox(parent, name, refreshFunc, data, width, height - sections.headerHeight - 2, lineAmount, sections.lineHeight)
    ---@cast scrollBox detailsbreakdownmidnight_sectionscroll
    scrollBox.sectionId = sectionId
    scrollBox.HideScrollBar = true

    Mixin(scrollBox, breakdownMidnight.scrollBarMixin)

    local initialHeaderData = {
        {key = "name", text = title, width = 120, align = "left", canSort = true, dataType = "string", offset = 0},
    }

    local header = breakdownMidnight.CreateSectionHeader(windowFrame, parent, sectionId, scrollBox, initialHeaderData)
    header:ClearAllPoints()
    header:SetPoint("topleft", parent, "topleft", 0, 0)
    header:SetPoint("topright", parent, "topright", 0, 0)
    header.ScrollOwner = scrollBox
    scrollBox.Header = header

    scrollBox:ClearAllPoints()
    scrollBox:SetPoint("topleft", parent, "topleft", 0, -sections.headerHeight - 2)
    scrollBox:SetPoint("bottomright", parent, "bottomright", 0, 0)
    detailsFramework:ReskinSlider(scrollBox)

    local scrollFrameName = scrollBox:GetName()
    if (scrollFrameName) then
        local scrollBar = _G[scrollFrameName .. "ScrollBar"]
        if (scrollBar) then
            scrollBar:Hide()
            scrollBar:SetAlpha(0)
            scrollBar:EnableMouse(false)
        end
    end

    for i = 1, lineAmount do
        scrollBox:CreateLine(createLine)
    end

    local isInitializing = true

    local updateScrollLineAmount = function(sectionFrame)
        local sectionHeight = sectionFrame:GetHeight() or 0
        local newLineAmount = getSectionLineAmountForSection(sectionId, sectionHeight)
        local currentLineAmount = scrollBox:GetNumFramesShown()

        if (newLineAmount > scrollBox:GetNumFramesCreated()) then
            for i = scrollBox:GetNumFramesCreated() + 1, newLineAmount do
                scrollBox:CreateLine(createLine)
            end
        end

        if (newLineAmount ~= currentLineAmount) then
            scrollBox:SetNumFramesShown(newLineAmount)
            if not isInitializing then
                scrollBox:Refresh()
            end
        end
    end

    local previousOnSizeChanged = parent:GetScript("OnSizeChanged")

    parent:SetScript("OnSizeChanged", function(sectionFrame, ...)
        if (previousOnSizeChanged) then
            previousOnSizeChanged(sectionFrame, ...)
        end
        updateScrollLineAmount(sectionFrame)
    end)

    updateScrollLineAmount(parent)

    isInitializing = false

    return scrollBox
end

---@param parent frame
---@param containerName string
---@param width number
---@param height number
---@return df_framecontainer
function breakdownMidnight.CreateMainContainer(parent, containerName, width, height)
    local options = {
        width = width,
        height = height,
        is_movement_locked = true,
        can_move_children = false,
        can_resize_children = true,
        use_top_child_resizer = true,
        use_bottom_child_resizer = true,
        use_left_child_resizer = true,
        use_right_child_resizer = true,
        use_top_resizer = false,
        use_bottom_resizer = false,
        use_left_resizer = false,
        use_right_resizer = false,
        is_locked = true,
        show_resize_grips = false,
    }

    local container = detailsFramework:CreateFrameContainer(parent, options, containerName)
    return container
end

---@param parent frame
---@param sectionName string
---@param sectionKey string
---@param settings detailsbreakdownmidnight_sectionsetting
---@return frame
function breakdownMidnight.CreateSectionFrame(parent, sectionName, sectionKey, settings)
    local sectionFrame = CreateFrame("frame", sectionName, parent)

    restoreSectionSizeFromProfile(sectionFrame, sectionKey, settings)
    detailsFramework:ApplyStandardBackdrop(sectionFrame)
    sectionFrame.__background:SetVertexColor(0.08, 0.08, 0.08, 0.5)

    sectionFrame:HookScript("OnSizeChanged", function(thisFrame)
        local width = thisFrame:GetWidth()
        local height = thisFrame:GetHeight()
        saveSectionSizeToProfile(sectionKey, width, height)
    end)

    sectionFrame:HookScript("OnShow", function(thisFrame)
        restoreSectionSizeFromProfile(thisFrame, sectionKey, settings)
    end)

    return sectionFrame
end

---@param windowFrame detailsbreakdownmidnight_window
---@param windowPadding number
---@param contentTop number
---@param contentWidth number
---@param contentHeight number
function breakdownMidnight.BuildSectionLayout(windowFrame, windowPadding, contentTop, contentWidth, contentHeight)
    local sectionIds = breakdownMidnight.Enums.SectionIds
    local defaultSettings = sections.defaultSettings

    local mainContainer = breakdownMidnight.CreateMainContainer(windowFrame, "$parentMainContainer", contentWidth, contentHeight)
    mainContainer:ClearAllPoints()
    mainContainer:SetPoint("topleft", windowFrame, "topleft", windowPadding, -contentTop)
    windowFrame.MainContainer = mainContainer

    --top left, select which player to show in the breakdown
    local playerContainer = breakdownMidnight.CreateSectionFrame(mainContainer, "$parentPlayersContainer", "players", defaultSettings.players)
    mainContainer:RegisterChild(playerContainer)
    mainContainer:SetChildResizerSides(playerContainer, {left = false, right = false, top = false, bottom = true})
    windowFrame.PlayerContainer = playerContainer
    windowFrame.PlayerScroll = breakdownMidnight.CreateSectionScroll(windowFrame, sectionIds.Players, playerContainer, "$parentPlayerScroll", defaultSettings.players.width, defaultSettings.players.height, "Players", windowFrame.playerData)
    breakdownMidnight.PlayerSectionInit(playerContainer, windowFrame)

    --bottom left, show the segments available
    local segmentContainer = breakdownMidnight.CreateSectionFrame(mainContainer, "$parentSegmentsContainer", "segments", defaultSettings.segments)
    mainContainer:RegisterChild(segmentContainer)
    mainContainer:SetChildResizerSides(segmentContainer, {left = false, right = false, top = false, bottom = false})
    windowFrame.SegmentContainer = segmentContainer
    windowFrame.SegmentScroll = breakdownMidnight.CreateSectionScroll(windowFrame, sectionIds.Segments, segmentContainer, "$parentSegmentScroll", defaultSettings.segments.width, defaultSettings.segments.height, "Segments", windowFrame.segmentData)
    breakdownMidnight.SegmentScrollInit(segmentContainer, windowFrame)

    --playerContainer:HookScript("OnSizeChanged", onSizeChanged)
    local onSegmentsSizeChanged = function()
        local segmentScroll = windowFrame:GetSegmentScroll()
        local header = segmentScroll:GetHeader()
        if header:DoesColumnExists(2) then --wait the first refresh
            local headerTable = header:GetHeaderTable()
            local firstColumnWidth = header:GetColumnWidth(1)
            local secondColumnWidth = header:GetColumnWidth(2)
            local headerPadding = header.options.padding or 0
            local segmentWidth = segmentContainer:GetWidth()

            local calculatedThirdColumnWidth = math.max(16, math.floor(segmentWidth - firstColumnWidth - secondColumnWidth - (headerPadding * 2) - 2))
            headerTable[3].width = calculatedThirdColumnWidth
            header:SetHeaderTable(headerTable)

            local headersWidth = breakdownMidnight.GetProfile().headers_width
            headersWidth[sectionIds.Segments] = headersWidth[sectionIds.Segments] or {}
            headersWidth[sectionIds.Segments].name = calculatedThirdColumnWidth

            windowFrame.SegmentScroll:RefreshMe()
        end
    end
    segmentContainer:HookScript("OnSizeChanged", onSegmentsSizeChanged)

    local onPlayersSizeChanged = function()
        local playerScroll = windowFrame:GetPlayerScroll()
        local header = playerScroll:GetHeader()
        if header:DoesColumnExists(2) then --wait the first refresh
            local headerTable = header:GetHeaderTable()
            local firstColumnWidth = header:GetColumnWidth(1)
            local secondColumnWidth = header:GetColumnWidth(2)
            local headerPadding = header.options.padding or 0
            local playerWidth = playerContainer:GetWidth()

            local calculatedThirdColumnWidth = math.max(16, math.floor(playerWidth - firstColumnWidth - secondColumnWidth - (headerPadding * 2) - 2))
            headerTable[3].width = calculatedThirdColumnWidth
            header:SetHeaderTable(headerTable)

            local headersWidth = breakdownMidnight.GetProfile().headers_width
            headersWidth[sectionIds.Players] = headersWidth[sectionIds.Players] or {}
            headersWidth[sectionIds.Players].name = calculatedThirdColumnWidth

            windowFrame.PlayerScroll:RefreshMe()
        end
    end
    playerContainer:HookScript("OnSizeChanged", onPlayersSizeChanged)

    --center, show the spells used by the selected player in the selected segment
    local sectionSpellsFrame = breakdownMidnight.CreateSectionFrame(mainContainer, "$parentSpellsContainer", "spells", defaultSettings.spells)
    mainContainer:RegisterChild(sectionSpellsFrame)
    mainContainer:SetChildResizerSides(sectionSpellsFrame, {left = true, right = true, top = false, bottom = false})
    windowFrame.SpellContainer = sectionSpellsFrame
    windowFrame.SpellScroll = breakdownMidnight.CreateSectionScroll(windowFrame, sectionIds.Spells, sectionSpellsFrame, "$parentSpellScroll", defaultSettings.spells.width, defaultSettings.spells.height, "Spell Damage", windowFrame.spellData)
    breakdownMidnight.SpellScrollInit(sectionSpellsFrame, windowFrame)

    local targetsContainer = breakdownMidnight.CreateSectionFrame(mainContainer, "$parentTargetsContainer", "targets", defaultSettings.targets)
    mainContainer:RegisterChild(targetsContainer)
    mainContainer:SetChildResizerSides(targetsContainer, {left = true, right = false, top = false, bottom = false})
    windowFrame.TargetsContainer = targetsContainer
    windowFrame.TargetsScroll = breakdownMidnight.CreateSectionScroll(windowFrame, sectionIds.Targets, targetsContainer, "$parentTargetsScroll", defaultSettings.targets.width, defaultSettings.targets.height, "Targets", windowFrame.targetsData)
    breakdownMidnight.TargetsScrollInit(targetsContainer, windowFrame)

    local comparisonContainer = breakdownMidnight.CreateSectionFrame(mainContainer, "$parentComparisonContainer", "compare", defaultSettings.compare)
    mainContainer:RegisterChild(comparisonContainer)
    mainContainer:SetChildResizerSides(comparisonContainer, {left = false, right = false, top = false, bottom = false})
    windowFrame.ComparisonContainer = comparisonContainer
    windowFrame.ComparisonScroll = breakdownMidnight.CreateSectionScroll(windowFrame, sectionIds.Compare, comparisonContainer, "$parentComparisonScroll", defaultSettings.compare.width, defaultSettings.compare.height, "Comparison", windowFrame.comparisonData)

    breakdownMidnight.RefreshSectionPoints(windowFrame)
    return mainContainer
end

---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.RefreshSectionPoints(windowFrame)
    local mainContainer = windowFrame.MainContainer
    local playerContainer = windowFrame.PlayerContainer
    local segmentContainer = windowFrame.SegmentContainer
    local spellContainer = windowFrame.SpellContainer
    local targetsContainer = windowFrame.TargetsContainer
    local comparisonContainer = windowFrame.ComparisonContainer

    playerContainer:ClearAllPoints()
    playerContainer:SetPoint("topleft", mainContainer, "topleft", 1, -1)

    segmentContainer:ClearAllPoints()
    segmentContainer:SetPoint("topleft", playerContainer, "bottomleft", 0, -sections.sectionSpacing)
    segmentContainer:SetPoint("bottomleft", mainContainer, "bottomleft", 0, 1)

    spellContainer:ClearAllPoints()
    spellContainer:SetPoint("topleft", playerContainer, "topright", 2, 0)

    targetsContainer:ClearAllPoints()
    targetsContainer:SetPoint("topleft", segmentContainer, "topright", 2, 0)
    targetsContainer:SetPoint("bottom", mainContainer, "bottom", 0, 1)

    comparisonContainer:ClearAllPoints()
    comparisonContainer:SetPoint("topright", mainContainer, "topright", -1, -1)
end

---@param windowFrame detailsbreakdownmidnight_window
---@param dontRefresh boolean
function breakdownMidnight.ResetSectionSizes(windowFrame, dontRefresh)
    local profile = breakdownMidnight.GetProfile()
    local defaultSettings = sections.defaultSettings

    local sectionFrameByKey = {
        players = windowFrame.PlayerContainer,
        segments = windowFrame.SegmentContainer,
        spells = windowFrame.SpellContainer,
        targets = windowFrame.TargetsContainer,
        compare = windowFrame.ComparisonContainer,
    }

    for sectionKey, sectionFrame in pairs(sectionFrameByKey) do
        local sectionDefaults = defaultSettings[sectionKey]
        if (sectionFrame and sectionDefaults) then
            local profileSectionSettings = profile[sectionKey]
            profileSectionSettings.width = sectionDefaults.width
            profileSectionSettings.height = sectionDefaults.height
            sectionFrame:SetSize(sectionDefaults.width, sectionDefaults.height)
        end
    end

    profile.headers_width = {}

    breakdownMidnight.RefreshSectionPoints(windowFrame)
    if not dontRefresh then
        windowFrame:RefreshAllScrolls()
    end
end
