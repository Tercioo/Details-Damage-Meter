
local Details = _G.Details
local Loc = _G.LibStub("AceLocale-3.0"):GetLocale ( "Details" )
local SharedMedia = _G.LibStub:GetLibrary("LibSharedMedia-3.0")
local addonName, Details222 = ...
local _

---@type detailsframework
local detailsFramework = DetailsFramework
local UIParent = UIParent

---@class detailsbreakdownmidnight_profile : table
---@field players detailsbreakdownmidnight_profile_sectionsetting
---@field segments detailsbreakdownmidnight_profile_sectionsetting
---@field spells detailsbreakdownmidnight_profile_sectionsetting
---@field spelldetails detailsbreakdownmidnight_profile_sectionsetting
---@field targets detailsbreakdownmidnight_profile_sectionsetting
---@field headers_width table<number, table<string, number>>

---@class detailsbreakdownmidnight_profile_sectionsetting
---@field width number
---@field height number

---@class detailsbreakdownmidnight
---@field windowFrameMixin table
---@field lineButtonMixin table
---@field scrollBarMixin table
---@field Enums detailsbreakdownmidnight_enums
---@field Sections detailsbreakdownmidnight_sections
---@field BreakdownWindows detailsbreakdownmidnight_window[]
---@field GetBreakdownWindows fun():detailsbreakdownmidnight_window[]
---@field GetBreakdownWindow fun(windowIndex:number, shouldNotError:boolean?):detailsbreakdownmidnight_window
---@field CreateBreakdownWindow fun(windowIndex:number, parentFrame:frame?):detailsbreakdownmidnight_window
---@field HasFrameBeenCreated fun(windowIndex:number):boolean
---@field IsOpen fun(windowIndex:number):boolean
---@field Hide fun(windowIndex:number)
---@field GenerateSpellData fun(windowFrame:detailsbreakdownmidnight_window):detailsbreakdownmidnight_spells[],string[], boolean
---@field GeneratePlayerData fun(windowFrame:detailsbreakdownmidnight_window):table,string[]
---@field GenerateSegmentData fun(windowFrame:detailsbreakdownmidnight_window):table,string[]
---@field CreateMainContainer fun(parent:frame, containerName:string, width:number, height:number):df_framecontainer
---@field CreateSectionFrame fun(parent:frame, sectionName:string, sectionKey:string, settings:detailsbreakdownmidnight_sectionsetting):frame
---@field CreateSectionScroll fun(windowFrame:detailsbreakdownmidnight_window, sectionId:number, parent:frame, name:string, width:number, height:number, title:string, data:table):detailsbreakdownmidnight_sectionscroll
---@field BuildSectionLayout fun(windowFrame:detailsbreakdownmidnight_window, windowPadding:number, contentTop:number, contentWidth:number, contentHeight:number):df_framecontainer
---@field RefreshSectionPoints fun(windowFrame:detailsbreakdownmidnight_window)
---@field ResetSectionSizes fun(windowFrame:detailsbreakdownmidnight_window, dontRefresh:boolean?)
---@field OpenApocalypseBreakdown fun(windowIndex:number, instance:instance, segmentType:number, segmentId:number, attributeId:number, actorObject:actor):detailsbreakdownmidnight_window
---@field RefreshApocalypseBreakdown fun(windowIndex:number):detailsbreakdownmidnight_window
---@field CreateMainPanel fun(windowIndex:number, parentFrame:frame?):detailsbreakdownmidnight_window
---@field GetProfile fun():detailsbreakdownmidnight_profile
---@field ApplyLineTextSettings fun(fontString:fontstring)
---@field ApplyLineTextSettingsToLine fun(line:detailsbreakdownmidnight_line)
---@field ApplyLineTextSettingsToAllLines fun()
---@field ApplySectionFrameSettings fun(sectionFrame:detailsbreakdownmidnight_sectionframe)
---@field ApplySectionFrameSettingsToAllSections fun()
---@field SetupFontString fun(line:detailsbreakdownmidnight_line, fontString:fontstring)
---@field PlayerSectionInit fun(sectionFrame:detailsbreakdownmidnight_sectionframe, windowFrame:detailsbreakdownmidnight_window)
---@field SegmentScrollInit fun(sectionFrame:detailsbreakdownmidnight_sectionframe, windowFrame:detailsbreakdownmidnight_window)
---@field SpellScrollInit fun(sectionFrame:detailsbreakdownmidnight_sectionframe, windowFrame:detailsbreakdownmidnight_window)
---@field TargetsScrollInit fun(sectionFrame:detailsbreakdownmidnight_sectionframe, windowFrame:detailsbreakdownmidnight_window)
---@field OpenOptions fun()
local breakdownMidnight = {}
Details222.BreakdownWindowMidnight = breakdownMidnight

---@class detailsbreakdownmidnight_window : df_roundedpanel
---@field windowIndex number
---@field MainContainer df_framecontainer
---@field PlayerScroll detailsbreakdownmidnight_sectionscroll
---@field SegmentScroll detailsbreakdownmidnight_sectionscroll
---@field SpellScroll detailsbreakdownmidnight_sectionscroll
---@field SpellDetailsScroll detailsbreakdownmidnight_sectionscroll
---@field TargetsScroll detailsbreakdownmidnight_sectionscroll
---@field ComparisonScroll detailsbreakdownmidnight_sectionscroll
---@field PlayerContainer frame
---@field SegmentContainer frame
---@field SpellContainer frame
---@field SpellDetailsContainer frame
---@field TargetsContainer frame
---@field ComparisonContainer frame
---@field TitleIcon texture
---@field TitleText fontstring
---@field playerData table
---@field segmentData table
---@field spellData table
---@field spellDetailsData table
---@field targetsData table
---@field comparisonData table
---@field instance instance
---@field currentActorObject damagemeter_combat_source
---@field currentSegmentType number
---@field currentSegmentId number
---@field currentAttributeId number
---@field bIsBuilt boolean?
---@field playerPerAttribute table
---@field GetCurrentAttributeId fun(windowFrame: detailsbreakdownmidnight_window):number?
---@field GetCurrentSegmentId fun(windowFrame: detailsbreakdownmidnight_window):number?
---@field GetCurrentSegmentType fun(windowFrame: detailsbreakdownmidnight_window):number?
---@field GetIndex fun(windowFrame: detailsbreakdownmidnight_window):number
---@field GetInstance fun(windowFrame: detailsbreakdownmidnight_window):instance
---@field GetPlayerObject fun(windowFrame: detailsbreakdownmidnight_window):damagemeter_combat_source?
---@field GetPlayerScroll fun(windowFrame: detailsbreakdownmidnight_window):detailsbreakdownmidnight_sectionscroll
---@field GetSegment fun(windowFrame: detailsbreakdownmidnight_window):table
---@field GetSegmentScroll fun(windowFrame: detailsbreakdownmidnight_window):detailsbreakdownmidnight_sectionscroll
---@field GetSpellDetailsScroll fun(windowFrame: detailsbreakdownmidnight_window):detailsbreakdownmidnight_sectionscroll
---@field GetSpellScroll fun(windowFrame: detailsbreakdownmidnight_window):detailsbreakdownmidnight_sectionscroll
---@field GetStatusBarTexture fun(windowFrame: detailsbreakdownmidnight_window):string
---@field GetTargetsScroll fun(windowFrame: detailsbreakdownmidnight_window):detailsbreakdownmidnight_sectionscroll
---@field GetTitleText fun(windowFrame: detailsbreakdownmidnight_window):fontstring
---@field RefreshAllScrolls fun(windowFrame: detailsbreakdownmidnight_window)
---@field SetCurrentAttributeId fun(windowFrame: detailsbreakdownmidnight_window, attributeId: number)
---@field SetCurrentSegmentId fun(windowFrame: detailsbreakdownmidnight_window, segmentId: number)
---@field SetCurrentSegmentType fun(windowFrame: detailsbreakdownmidnight_window, segmentType: number)
---@field SetInstance fun(windowFrame: detailsbreakdownmidnight_window, instance: instance)
---@field SetPlayerObject fun(windowFrame: detailsbreakdownmidnight_window, actorObject: actor?)
---@field SetTitle fun(windowFrame: detailsbreakdownmidnight_window)

---@class detailsbreakdownmidnight_line : button, df_headerfunctions
---@field data table
---@field Text fontstring
---@field Texts fontstring[]
---@field Icon texture
---@field IconFrame frame
---@field Highlight texture
---@field SelectedTexture texture
---@field Background texture
---@field StatusBar statusbar
---@field GetData fun(line: detailsbreakdownmidnight_line):table
---@field SetData fun(line: detailsbreakdownmidnight_line, data: table)
---@field GetScroll fun(line: detailsbreakdownmidnight_line):detailsbreakdownmidnight_sectionscroll
---@field GetSectionFrame fun(line: detailsbreakdownmidnight_line):frame
---@field GetWindow fun(line: detailsbreakdownmidnight_line):detailsbreakdownmidnight_window

---@class detailsbreakdownmidnight_sectionscroll : df_scrollbox
---@field sectionId number
---@field isSpells boolean
---@field Header detailsbreakdownmidnight_header
---@field NoDataPanel frame
---@field NoDataText fontstring
---@field AttributeNameText fontstring
---@field GetHeader fun(scroll: detailsbreakdownmidnight_sectionscroll):detailsbreakdownmidnight_header
---@field GetWindow fun(scroll: detailsbreakdownmidnight_sectionscroll):detailsbreakdownmidnight_window
---@field UpdateScrollLineAmount fun(scroll: detailsbreakdownmidnight_sectionscroll)
---@field UpdateAttributeMenuAnchor fun()? only for spell scroll

breakdownMidnight.BreakdownWindows = breakdownMidnight.BreakdownWindows or {}

local CONST_WINDOW_WIDTH = 1100
local CONST_WINDOW_HEIGHT = 640
local CONST_WINDOW_PADDING = 5

function breakdownMidnight.GetProfile()
    return Details.breakdown_midnight
end

---@param windowIndex number
---@return number
local getWindowIndex = function(windowIndex)
    assert(type(windowIndex) == "number", "windowIndex must be a number")
    assert(windowIndex >= 1, "windowIndex must be >= 1")
    return math.floor(windowIndex)
end

---get an existing breakdown window by index
---@param windowIndex number
---@param shouldNotError boolean?
---@return detailsbreakdownmidnight_window?
function breakdownMidnight.GetBreakdownWindow(windowIndex, shouldNotError)
    local index = getWindowIndex(windowIndex)
    local windowFrame = breakdownMidnight.BreakdownWindows[index]
    if (not windowFrame and not shouldNotError) then
        error("breakdown window " .. index .. " does not exist")
    end
    return windowFrame
end

---return all cached breakdown windows
---@return detailsbreakdownmidnight_window[]
function breakdownMidnight.GetBreakdownWindows()
    return breakdownMidnight.BreakdownWindows
end

---create and cache a breakdown window and its scroll sections
---@param windowIndex number
---@param parentFrame frame?
---@return detailsbreakdownmidnight_window
function breakdownMidnight.CreateBreakdownWindow(windowIndex, parentFrame)
    local index = getWindowIndex(windowIndex)

    parentFrame = parentFrame or UIParent
    local panelName = "DetailsBreakdownMidnightMainPanel" .. index
    local panelOptions = {
        width = CONST_WINDOW_WIDTH,
        height = CONST_WINDOW_HEIGHT,
        roundness = 10,
        color = {0.07, 0.07, 0.09, 0.96},
        border_color = {0.25, 0.25, 0.25, 0.8},
    }

    ---@type detailsbreakdownmidnight_window
    local windowFrame = detailsFramework:CreateRoundedPanel(parentFrame, panelName, panelOptions)
    windowFrame:SetPoint("center", parentFrame, "center", 0, 0)
    windowFrame:SetFrameStrata("HIGH")
    detailsFramework:MakeDraggable(windowFrame)

    windowFrame:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            self:Hide()
        end
    end)

    windowFrame.windowIndex = index
    windowFrame.playerData = windowFrame.playerData or {}
    windowFrame.segmentData = windowFrame.segmentData or {}
    windowFrame.spellData = windowFrame.spellData or {}
    windowFrame.spellDetailsData = windowFrame.spellDetailsData or {}
    windowFrame.targetsData = windowFrame.targetsData or {}
    windowFrame.comparisonData = windowFrame.comparisonData or {}
    windowFrame.currentSegmentType = 1
    windowFrame.currentSegmentId = 1
    windowFrame.currentAttributeId = 0
    windowFrame.playerPerAttribute = {}

    Mixin(windowFrame, breakdownMidnight.windowFrameMixin)
    table.insert(UISpecialFrames, panelName)

    local titleIcon = detailsFramework:CreateTexture(windowFrame, "DetailsBreakdownMidnightTitleIcon" .. index, 24, 24, "artwork")
    titleIcon:SetPoint("topleft", windowFrame, "topleft", CONST_WINDOW_PADDING, -5)
    windowFrame.TitleIcon = titleIcon

    local titleText = detailsFramework:CreateLabel(windowFrame, Loc["STRING_PLAYER_DETAILS"] or "Breakdown", 12, "DETAILS_HEADER_YELLOW")
    titleText:SetPoint("left", titleIcon, "right", 4, 0)
    windowFrame.TitleText = titleText

    local closeButton = detailsFramework:CreateCloseButton(windowFrame, "DetailsBreakdownMidnightCloseButton" .. index)
    closeButton:SetPoint("topright", windowFrame, "topright", -CONST_WINDOW_PADDING, -CONST_WINDOW_PADDING)

    local resetButton = detailsFramework:CreateButton(windowFrame, function()
        --breakdownMidnight.ResetSectionSizes(windowFrame)
        breakdownMidnight.OpenOptions()

    end, 80, 16, "options", nil, nil, nil, nil, "DetailsBreakdownMidnightResetSizeButton" .. index)
    resetButton:SetPoint("right", closeButton, "left", -2, 0)
    resetButton:SetTemplate(detailsFramework:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE"))

    --scale bar
	local scaleBar = detailsFramework:CreateScaleBar(windowFrame, Details.player_details_window)
    scaleBar:SetHeight(16)
	scaleBar.label:AdjustPointsOffset(-3, 1)
	scaleBar.label:SetTextColor{0.8902, 0.7294, 0.0157, 1}
	scaleBar.label:SetIgnoreParentAlpha(true)
    scaleBar:ClearAllPoints()
    scaleBar:SetPoint("right", resetButton, "left", -4, 0)
    scaleBar.label:ClearAllPoints()
    scaleBar.label:SetPoint("right", scaleBar, "left", -2, 0)
	windowFrame:SetScale(Details.player_details_window.scale)

    local sectionOptions = breakdownMidnight.Sections or {}
    local contentTop = sectionOptions.contentTop or 30
    local contentHeight = CONST_WINDOW_HEIGHT - contentTop - CONST_WINDOW_PADDING
    local contentWidth = CONST_WINDOW_WIDTH - (CONST_WINDOW_PADDING * 2)

    local mainContainer = breakdownMidnight.BuildSectionLayout(windowFrame, CONST_WINDOW_PADDING, contentTop, contentWidth, contentHeight)
    mainContainer:EnableMouse(false)

    windowFrame.bIsBuilt = true
    breakdownMidnight.BreakdownWindows[index] = windowFrame

    return windowFrame
end

---return if the midnight breakdown panel has already been created
---example: local hasBeenCreated = breakdownMidnight.HasFrameBeenCreated(1) --check if the breakdown panel with index 1 has been created
---@param windowIndex number
---@return boolean
function breakdownMidnight.HasFrameBeenCreated(windowIndex)
    local shouldNotError = true
    local windowFrame = breakdownMidnight.GetBreakdownWindow(windowIndex, shouldNotError)
    return windowFrame and windowFrame.IsObjectType and windowFrame:IsObjectType("Frame") or false
end

---return if the midnight breakdown panel is currently visible
---example: local isOpen = breakdownMidnight.IsOpen(1) --check if the breakdown panel with index 1 is open
---@param windowIndex number
---@return boolean
function breakdownMidnight.IsOpen(windowIndex)
    local shouldNotError = true
    local windowFrame = breakdownMidnight.GetBreakdownWindow(windowIndex, shouldNotError)
    return windowFrame and windowFrame:IsShown() or false
end

---hide the midnight breakdown panel
---example: breakdownMidnight.Hide(1) --hide the breakdown panel with index 1
---@param windowIndex number
function breakdownMidnight.Hide(windowIndex)
    local windowFrame = breakdownMidnight.GetBreakdownWindow(windowIndex)
    windowFrame:Hide()
end

---open the apocalypse breakdown panel and set context for segment, attribute and actor
---@param windowIndex number
---@param segmentType number
---@param segmentId number
---@param attributeId number
---@param actorObject actor
---@return detailsbreakdownmidnight_window
function breakdownMidnight.OpenApocalypseBreakdown(windowIndex, instance, segmentType, segmentId, attributeId, actorObject)
    local index = getWindowIndex(windowIndex)
    assert(type(segmentType) == "number", "segmentType must be a number")
    assert(type(segmentId) == "number", "segmentId must be a number")
    assert(type(attributeId) == "number", "attributeId must be a number")

    local shouldNotError = true
    local windowFrame = breakdownMidnight.GetBreakdownWindow(index, shouldNotError)
    if (not windowFrame) then
        windowFrame = breakdownMidnight.CreateBreakdownWindow(index)
    end

    local headersWidth = breakdownMidnight.GetProfile().headers_width
    local hasSavedColumnData = false
    for _, sectionWidths in pairs(headersWidth) do
        if (type(sectionWidths) == "table" and next(sectionWidths)) then
            hasSavedColumnData = true
            break
        end
    end
    if (not hasSavedColumnData) then
        breakdownMidnight.ResetSectionSizes(windowFrame, true)
    end

    windowFrame:SetColor(unpack(Details.frame_background_color))

    breakdownMidnight.ApplySectionFrameSettingsToAllSections()

    if segmentId == -1 then
        segmentType = 0
    elseif (segmentId == 0) then
        segmentType = 1
    end

    windowFrame:SetInstance(instance)
    windowFrame:SetCurrentSegmentType(segmentType)
    windowFrame:SetCurrentSegmentId(segmentId)
    windowFrame:SetCurrentAttributeId(attributeId)
    windowFrame:SetPlayerObject(actorObject)

    breakdownMidnight.SetTitle(windowFrame)

    --local lowerInstanceId = Details:GetLowerInstanceNumber()
    --local instance = 

    windowFrame:Show()
    windowFrame:RefreshAllScrolls()

    return windowFrame
end

---refresh an existing apocalypse breakdown panel using its current context
---@param windowIndex number
---@return detailsbreakdownmidnight_window
function breakdownMidnight.RefreshApocalypseBreakdown(windowIndex)
    local index = getWindowIndex(windowIndex)
    local windowFrame = breakdownMidnight.GetBreakdownWindow(index)

    local instance = windowFrame:GetInstance()
    local segmentType = windowFrame:GetCurrentSegmentType()
    local segmentId = windowFrame:GetCurrentSegmentId()
    local attributeId = windowFrame:GetCurrentAttributeId()
    local actorObject = windowFrame:GetPlayerObject()

    assert(instance, "instance is missing for breakdown window " .. index)
    assert(type(segmentType) == "number", "segmentType is missing for breakdown window " .. index)
    assert(type(segmentId) == "number", "segmentId is missing for breakdown window " .. index)
    assert(type(attributeId) == "number", "attributeId is missing for breakdown window " .. index)
    assert(actorObject, "actorObject is missing for breakdown window " .. index)

    return breakdownMidnight.OpenApocalypseBreakdown(index, instance, segmentType, segmentId, attributeId, actorObject)
end

function breakdownMidnight.SetTitle(windowFrame)
    local segmentType, segmentId, attributeId, actorObject = windowFrame:GetCurrentSegmentType(), windowFrame:GetCurrentSegmentId(), windowFrame:GetCurrentAttributeId(), windowFrame:GetPlayerObject()
    local titleIcon = windowFrame:GetTitleIcon()
    local titleText = windowFrame:GetTitleText()
    titleIcon:SetTexture(actorObject.specIconID)
    titleText:SetText(actorObject.name)
end

--public alias for bar click handlers
Details.OpenApocalypseBreakdown = breakdownMidnight.OpenApocalypseBreakdown

--backward compatibility
breakdownMidnight.CreateMainPanel = breakdownMidnight.CreateBreakdownWindow
