
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@class details_allinonewindow : table
---@field windowFrames table
---@field GetSettings fun(self: details_allinonewindow, windowId: number): details_allinonewindow_settings
---@field GetNumWindowsCreated fun(self: details_allinonewindow): number
---@field CreateWindowFrame fun(self: details_allinonewindow): frame
---@field RefreshWindowFrame fun(self: details_allinonewindow, windowId: number)
---@field CreateLineForWindow fun(self: details_allinonewindow, window: details_allinonewindow_frame): details_allinonewindow_line


---@class details_allinonewindow_settings : table
---@field position table
---@field size table
---@field scale number

---@class details_allinonewindow_line : frame

---@class details_allinonewindow_headerframe : df_headerframe
---@field windowId number

---@type details_allinonewindow
---@diagnostic disable-next-line: missing-fields
local AllInOneWindow = {
    windowFrames = {},
}

---@param self details_allinonewindow
---@param windowId number
function AllInOneWindow:GetSettings(windowId)
    local windowSetting = Details.window2_data[windowId]
    return windowSetting
end

---@param self details_allinonewindow
function AllInOneWindow:GetNumWindowsCreated()
    return #self.windowFrames
end

---run when the user clicks a column header
---@param headerFrame df_headerframe
---@param columnHeader df_headercolumnframe
local onColumnHeaderClickCallback = function(headerFrame, columnHeader)
    AllInOneWindow:RefreshWindowFrame(headerFrame:GetParent())
end

---@param headerFrame details_allinonewindow_headerframe
---@param setting string
---@param columnName string
---@param columnWidth number
local onHeaderColumnOptionChanged = function(headerFrame, setting, columnName, columnWidth) --setting is usually "width"

end

--~header
local headerOptions = {
    padding = 2,
    header_height = 14,
    reziser_shown = true,
    reziser_width = 2,
    reziser_color = {.5, .5, .5, 0.7},
    reziser_max_width = 246,
    header_click_callback = onColumnHeaderClickCallback,
    header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
    text_color = {1, 1, 1, 0.823},
}

local windowMethods = {
    GetId = function(self)
        return self.windowId
    end,
}

---@class details_allinonewindow_frame : frame
---@field Header details_allinonewindow_headerframe
---@field GetId fun(self: details_allinonewindow_frame): number

---@param self details_allinonewindow
function AllInOneWindow:CreateWindowFrame()
    local windowId = self:GetNumWindowsCreated()+1

    ---@type details_allinonewindow_frame
    local window = CreateFrame("Frame", "DetailsAllInOneWindow" .. windowId, UIParent, "BackdropTemplate")
    detailsFramework:Mixin(window, windowMethods)

    detailsFramework:ApplyStandardBackdrop(window)

	local headerTable = {}

	---create the header frame, the header frame is the frame which shows the columns names to describe the data shown in the window
	---@type details_allinonewindow_headerframe
	local header = detailsFramework:CreateHeader(window, headerTable, headerOptions)
	header:SetPoint("topleft", window, "topleft", 2, -2)
	header:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)
	header.windowId = windowId
	window.Header = header

    return window
end

---@param self details_allinonewindow
---@param window details_allinonewindow_frame
---@return details_allinonewindow_line line
function AllInOneWindow:CreateLineForWindow(window)
    ---@type details_allinonewindow_line
    local line = CreateFrame("Frame", "DetailsAllInOneWindowLine" .. window:GetId(), window, "BackdropTemplate")

    line.Icon = line:CreateTexture("$parentIcon", "artwork")
    line.Icon:SetPoint("topleft", line, "topleft", 1, -1)
    line.Icon:SetPoint("bottomleft", line, "bottomleft", 1, 1)

    --stopped here, creating the line frames
    --for reference, the comment below hasjthe content from breakdown spell frames lua file.
    --[=[
        spellBar.index = index

        --size and positioning
        spellBar:SetHeight(CONST_SPELLSCROLL_LINEHEIGHT)
        local y = (index-1) * CONST_SPELLSCROLL_LINEHEIGHT * -1 + (1 * -index) - 15
        spellBar:SetPoint("topleft", self, "topleft", 1, y)
        spellBar:SetPoint("topright", self, "topright", -1, y)

        spellBar:EnableMouse(true)
        spellBar:RegisterForClicks("AnyUp", "AnyDown")
        spellBar:SetAlpha(0.823)
        spellBar:SetFrameStrata("high")
        spellBar:SetScript("OnEnter", onEnterSpellBar)
        spellBar:SetScript("OnLeave", onLeaveSpellBar)
        spellBar:SetScript("OnMouseDown", onMouseDownBreakdownSpellBar)
        spellBar:SetScript("OnMouseUp", onMouseUpBreakdownSpellBar)
        spellBar.onMouseUpTime = 0
        spellBar.ExpandedChildren = {}

        DF:Mixin(spellBar, DF.HeaderFunctions)

        ---@type breakdownspellbarstatusbar
        local statusBar = CreateFrame("StatusBar", "$parentStatusBar", spellBar)
        statusBar:SetAllPoints()
        statusBar:SetAlpha(0.5)
        statusBar:SetMinMaxValues(0, 100)
        statusBar:SetValue(50)
        statusBar:EnableMouse(false)
        statusBar:SetFrameLevel(spellBar:GetFrameLevel() - 1)
        spellBar.statusBar = statusBar

        ---@type texture this is the statusbar texture
        local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
        statusBar:SetStatusBarTexture(statusBarTexture)
        statusBar:SetStatusBarColor(1, 1, 1, 1)

        ---@type texture background texture
        local backgroundTexture = statusBar:CreateTexture("$parentTextureBackground", "border")
        backgroundTexture:SetAllPoints()
        statusBar.backgroundTexture = backgroundTexture

        ---@type texture overlay texture to use when the spellbar is selected
        local statusBarOverlayTexture = statusBar:CreateTexture("$parentTextureOverlay", "overlay", nil, 7)
        statusBarOverlayTexture:SetTexture([[Interface/AddOns/Details/images/overlay_indicator_1]])
        statusBarOverlayTexture:SetVertexColor(1, 1, 1, 0.2)
        statusBarOverlayTexture:SetAllPoints()
        statusBarOverlayTexture:Hide()
        spellBar.overlayTexture = statusBarOverlayTexture
        statusBar.overlayTexture = statusBarOverlayTexture

        ---@type texture shown when the mouse hoverover this spellbar
        local hightlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
        hightlightTexture:SetColorTexture(1, 1, 1, 0.2)
        hightlightTexture:SetAllPoints()
        statusBar.highlightTexture = hightlightTexture

        --button to expand the bar when there's spells merged
        ---@type breakdownexpandbutton
        local expandButton = CreateFrame("button", "$parentExpandButton", spellBar, "BackdropTemplate")
        expandButton:SetSize(CONST_BAR_HEIGHT, CONST_BAR_HEIGHT)
        expandButton:RegisterForClicks("LeftButtonDown")
        spellBar.expandButton = expandButton

        ---@type texture
        local expandButtonTexture = expandButton:CreateTexture("$parentTexture", "artwork")
        expandButtonTexture:SetPoint("center", expandButton, "center", 0, 0)
        expandButtonTexture:SetSize(CONST_BAR_HEIGHT-2, CONST_BAR_HEIGHT-2)
        expandButton.texture = expandButtonTexture

        --frame which will show the spell tooltip
        ---@type frame
        local spellIconFrame = CreateFrame("frame", "$parentIconFrame", spellBar, "BackdropTemplate")
        spellIconFrame:SetSize(CONST_BAR_HEIGHT - 2, CONST_BAR_HEIGHT - 2)
        spellIconFrame:SetScript("OnEnter", onEnterSpellIconFrame)
        spellIconFrame:SetScript("OnLeave", onLeaveSpellIconFrame)
        spellBar.spellIconFrame = spellIconFrame

        --create the icon to show the spell texture
        ---@type texture
        local spellIcon = spellIconFrame:CreateTexture("$parentTexture", "overlay")
        spellIcon:SetAllPoints()
        spellIcon:SetTexCoord(.1, .9, .1, .9)
        detailsFramework:SetMask(spellIcon, Details:GetTextureAtlas("iconmask"))
        spellBar.spellIcon = spellIcon

        --create a square frame which is placed at the right side of the line to show which targets for damaged by the spell
        ---@type breakdowntargetframe
        local targetsSquareFrame = CreateFrame("frame", "$parentTargetsFrame", statusBar, "BackdropTemplate")
        targetsSquareFrame:SetSize(CONST_SPELLSCROLL_LINEHEIGHT, CONST_SPELLSCROLL_LINEHEIGHT)
        targetsSquareFrame:SetAlpha(.7)
        targetsSquareFrame:SetScript("OnEnter", onEnterSpellTarget)
        targetsSquareFrame:SetScript("OnLeave", onLeaveSpellTarget)
        targetsSquareFrame:SetFrameLevel(statusBar:GetFrameLevel()+2)
        spellBar.targetsSquareFrame = targetsSquareFrame

        ---@type texture
        local targetTexture = targetsSquareFrame:CreateTexture("$parentTexture", "overlay")
        targetTexture:SetTexture(CONST_TARGET_TEXTURE)
        targetTexture:SetAllPoints()
        targetTexture:SetDesaturated(true)
        spellBar.targetsSquareTexture = targetTexture
        targetsSquareFrame.texture = targetTexture

        spellBar:AddFrameToHeaderAlignment(spellIconFrame)
        spellBar:AddFrameToHeaderAlignment(targetsSquareFrame)

        --create texts
        ---@type fontstring[]
        spellBar.InLineTexts = {}

        for i = 1, 16 do
            ---@type fontstring
            local fontString = spellBar:CreateFontString("$parentFontString" .. i, "overlay", "GameFontHighlightSmall")
            fontString:SetJustifyH("left")
            fontString:SetTextColor(1, 1, 1, 1)
            fontString:SetNonSpaceWrap(true)
            fontString:SetWordWrap(false)
            spellBar["lineText" .. i] = fontString
            spellBar.InLineTexts[i] = fontString
            fontString:SetTextColor(1, 1, 1, 1)
            spellBar:AddFrameToHeaderAlignment(fontString)
        end

        spellBar:AlignWithHeader(self.Header, "left")
        return spellBar
    --]=]

    return line
end

---@param self details_allinonewindow
---@param window details_allinonewindow_frame
---@param line details_allinonewindow_line
function AllInOneWindow:RefreshLineForWindow(window, line)
    local icon = line.Icon
    local height = window.settings.line_height

end

---@param self details_allinonewindow
---@param window details_allinonewindow_frame
function AllInOneWindow:RefreshWindowFrame(window)


end