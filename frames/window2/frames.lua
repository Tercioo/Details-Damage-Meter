
local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

local sharedMedia = LibStub("LibSharedMedia-3.0")

---@class details_allinonewindow : table
---@field Debug boolean
---@field WindowFrames table
---@field Icons table icon namespace
---@field ActorCache table<actorname, actor> a weak table with "v" mode to cache actor references
---@field HeaderColumnData details_allinonewindow_headercolumndata[] store info about each column in the header, containing width, label, align, sort, etc.
---@field HeaderColumnDataKeyToIndex table<string, number> a table connecting the column key with the index in the HeaderColumnData table
---@field TooltipScripts table<string, fun(headerColumnFrame: details_allinonewindow_line_dataframe, actorObjects: actor[], windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line, combatObject: combat)> a table with functions to show tooltips for each column, the key is the column name
---@field Print fun(self: details_allinonewindow, ...: any)
---@field RegisterEvents fun(self: details_allinonewindow) register the events used by the addon
---@field OpenWindow fun(self: details_allinonewindow, windowId: number)
---@field CloseWindow fun(self: details_allinonewindow, windowId: number)
---@field GetSettings fun(self: details_allinonewindow, windowId: number): details_allinonewindow_settings
---@field GetNumWindowsCreated fun(self: details_allinonewindow): number
---@field CreateWindowFrame fun(self: details_allinonewindow): details_allinonewindow_frame
---@field RefreshWindowLayout fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame)
---@field RefreshLineLayout fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line)
---@field CreateLineForWindow fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame, lineId: number): details_allinonewindow_line
---@field GetAllWindows fun(self: details_allinonewindow): details_allinonewindow_frame[]
---@field ExecuteOnAllOpenedWindows fun(self: details_allinonewindow, functionName: string)
---@field StartRefresher fun(self: details_allinonewindow)
---@field StopRefresher fun(self: details_allinonewindow)
---@field RefreshWindow fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame)
---@field RefreshHeader fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame)
---@field IsRefreshInProgress fun(self: details_allinonewindow): boolean
---@field SetSegmentIdOnAllWindows fun(self: details_allinonewindow, segmentId: number)
---@field RefreshColumn fun(self: details_allinonewindow, index: number, windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line, headerColumnFrame: details_allinonewindow_line_dataframe, actorContainers: actorcontainer[], columnName: string, playerName: actorname, combatObject: combat, actorObjects: actor[]): number
---@field GetActorFromCache fun(self: details_allinonewindow, actorName: actorname): actor?
---@field GetColumnData fun(self: details_allinonewindow, key: string): details_allinonewindow_headercolumndata
---@field OpenOptionsPanel fun(self: details_allinonewindow, windowFrame: details_allinonewindow_frame)
---@field RefreshOptionsPanel fun(self: details_allinonewindow)
---@field CreateOptionsPanel fun(self: details_allinonewindow)
---@field HasOpenWindow fun(self: details_allinonewindow): boolean return true if there is at least one window open

---@class details_allinonewindow_headerframe : df_headerframe
---@field windowId number

---@class details_allinonewindow_frame_functions : table
---@field GetCombat fun(self: details_allinonewindow_frame): combat?
---@field GetId fun(self: details_allinonewindow_frame): number return the window ID
---@field IsOpen fun(self: details_allinonewindow_frame): boolean return if the window is currently open
---@field GetScrollFrame fun(self: details_allinonewindow_frame): df_scrollbox return the scroll frame from the member ScrollFrame
---@field GetSegmentId fun(self: details_allinonewindow_frame): number return the segment ID from the member segmentId
---@field SetSegmentId fun(self: details_allinonewindow_frame, segmentId: number, noRefresh: boolean?) set the member segmentId
---@field ValidateSegment fun(self: details_allinonewindow_frame, noRefresh: boolean?) if the segmentId does not contain a combat, set the segmentId to current, use noRefresh to avoid refreshing the window
---@field GetHeader fun(self: details_allinonewindow_frame): details_allinonewindow_headerframe return the header frame from the member Header
---@field GetHeaderNames fun(self: details_allinonewindow_frame): string[] return the column names from the settings table
---@field CalcAndSetLineAmount fun(self: details_allinonewindow_frame) calculate how many lines can fit in the window and set this amount in the scroll frame
---@field SetSortKeyTopAndTotal fun(self: details_allinonewindow_frame, key: string, top: number, total: number) set the total value in the scroll frame, used to calculate percentages
---@field GetSortKeyTopAndTotal fun(self: details_allinonewindow_frame): string, number, number get the total value from the scroll frame
---@field GetSelectedColumnName fun(self: details_allinonewindow_frame): string get the selected column from the settings table
---@field SetSelectedColumnName fun(self: details_allinonewindow_frame, key: string) set the selected column in the settings table
---@field GetDisplay fun(self: details_allinonewindow_frame): number, number for back compatibility, return 'atributo' and 'sub_atributo' members
---@field SetDisplay fun(self: details_allinonewindow_frame, atributo: number, sub_atributo: number) for back compatibility, set 'atributo' and 'sub_atributo' members
---@field GetMode fun(self: details_allinonewindow_frame): string for back compatibility, it'll always return 2 (group mode)
---@field RefreshWindow fun(self: details_allinonewindow_frame) for back compatibility, refresh the window

---@class details_allinonewindow_frame : frame, details_allinonewindow_frame_functions
---@field windowId number
---@field segmentId number
---@field atributo number back compatibility with old instances, the changes when entering a details_allinonewindow_line_dataframe
---@field sub_atributo number back compatibility with old instances
---@field currentTotal number
---@field currentTop number
---@field sortKey string
---@field isRefreshing boolean
---@field settings details_allinonewindow_settings
---@field latestRefresh number timestamp in GetTime() of the last time the window was refreshed
---@field BackgroundTexture texture
---@field RightResizerGrip df_resizergrip
---@field Lines details_allinonewindow_line[]
---@field Header details_allinonewindow_headerframe
---@field ScrollFrame df_scrollbox the scroll frame where the lines showing player information are displayed
---@field baseframe frame back compatibility with old instances, this is a frame that will always be hidden and set all points.

---a dataframe is a frame which will have a text to show data, this data can be a damage, healing, interrupts, etc.
---@class details_allinonewindow_line_dataframe : button
---@field actorObject actor? the actor used to get the data shown in this dataframe
---@field actorObjects actor[]
---@field combatObject combat
---@field atributo number back compatibility with old instances, the changes when entering a details_allinonewindow_line
---@field sub_atributo number back compatibility with old instances
---@field windowFrame details_allinonewindow_frame
---@field line details_allinonewindow_line
---@field Text fontstring the fontstring to show the data
---@field BackgroundTexture texture a texture placed in the background layer
---@field onEnterCallback fun(self: details_allinonewindow_line_dataframe, actorObjects: actor[], windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line, combatObject: combat) function to run when the mouse enter the frame, it is set using SetOnEnterCallback
---@field SetOnEnterCallback fun(self: details_allinonewindow_line_dataframe, func: fun(self: details_allinonewindow_line_dataframe, actorObjects: actor[], windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line, combatObject: combat)) set the function to run when the mouse enter the frame, the function receives as self the dataframe, and has access to actorObjects, windowFrame and line members
---@field GetActor fun(self: details_allinonewindow_line_dataframe): actor? return the actor used to get the data shown in this dataframe
---@field SetDisplay fun(self: details_allinonewindow_line_dataframe, atributo: number, sub_atributo: number) set the atributo and sub_atributo members in the windowFrame, used for back compatibility when opening the breakdown window
---@field GetDisplay fun(self: details_allinonewindow_line_dataframe): number, number return the atributo and sub_atributo members in the windowFrame, used for back compatibility when opening the breakdown window

---@class details_allinonewindow_line : button, df_headerfunctions
---@field index number
---@field onMouseUpTime number
---@field ExpandedChildren button[]
---@field FramesForData details_allinonewindow_line_dataframe[]|details_allinonewindow_line_statusbar_iconbutton[]
---@field BackgroundTexture texture a texture placed in the background layer
---@field HighlightTexture texture a texture placed in the highlight layer, shown when the mouse passes over
---@field StatusBar details_allinonewindow_line_statusbar
---@field PlayerIconTexture texture a shortcut to the texture used in the player icon frame
---@field GetFrameForData fun(self: details_allinonewindow_line, columnId: number): details_allinonewindow_line_dataframe|details_allinonewindow_line_statusbar_iconbutton
---@field GetAllFramesForData fun(self: details_allinonewindow_line): table
---@field GetStatusBar fun(self: details_allinonewindow_line): details_allinonewindow_line_statusbar

---@class details_allinonewindow_line_statusbar : statusbar
---@field StatusBarTexture texture
---@field OverlayTexture texture
---@field HighlightTexture texture
---@field PlayerIconFrame details_allinonewindow_line_statusbar_iconbutton
---@field ExpandButton details_allinonewindow_line_statusbar_expandbutton

---@class details_allinonewindow_line_statusbar_iconbutton : button
---@field Text fontstring
---@field Texture texture
---@field BackgroundTexture texture
---@field SetOnEnterCallback fun(self: details_allinonewindow_line_dataframe, func: fun(self: details_allinonewindow_line_dataframe), actorObjects: actor[], windowFrame: details_allinonewindow_frame, line: details_allinonewindow_line, combatObejct: combat) set the function to run when the mouse enter the frame, the function receives as self the dataframe, and has access to actorObjects, windowFrame and line members
---@field GetActor fun(self: details_allinonewindow_line_dataframe): actor? return the actor used to get the data shown in this dataframe
---@field SetDisplay fun(self: details_allinonewindow_line_dataframe, atributo: number, sub_atributo: number) set the atributo and sub_atributo members in the windowFrame, used for back compatibility when opening the breakdown window
---@field GetDisplay fun(self: details_allinonewindow_line_dataframe): number, number return the atributo and sub_atributo members in the windowFrame, used for back compatibility when opening the breakdown window

---@class details_allinonewindow_line_statusbar_expandbutton : button
---@field isExpanded boolean
---@field Texture texture this texture is usualy an arrow down or up

--declaring the classes for the settings table
---@class details_allinonewindow_settings : table
---@field data details_allinonewindow_settings_data
---@field header details_allinonewindow_settings_header
---@field window details_allinonewindow_settings_window
---@field lines details_allinonewindow_settings_lines
---@field titlebar details_allinonewindow_settings_titlebar

---@class details_allinonewindow_settings_data : table
---@field segmentId number

---@class details_allinonewindow_settings_header : table
---@field column_names string[]
---@field column_selected string
---@field background_color number[]
---@field column_order table<string, number> the order of the columns, this is used to restore the order when a column is removed and added back
---@field column_width table<string, number> column name and its width
---@field column_show_text table<string, boolean> true to show the text in the column in the header, false to hide it
---@field column_show_icon table<string, boolean> true to show the icon in the column in the header, false to hide it
---@field column_selected_color number[] this is the background color of the column frames when its header is selected

---@class details_allinonewindow_settings_window : table
---@field is_open boolean
---@field position table
---@field width number
---@field height number
---@field line_amount number
---@field background_texture string
---@field background_color number[]
---@field strata string
---@field clickthrough_window boolean
---@field clickthrough_incombatonly boolean
---@field locked boolean
---@field header_ontop boolean

---@class details_allinonewindow_settings_lines : table
---@field height number
---@field space_between number
---@field highlight boolean
---@field always_show_player boolean
---@field texture_background string
---@field texture_background_color number[]
---@field texture_background_colorbyclass boolean
---@field texture_main string
---@field texture_main_colorbyclass boolean
---@field texture_main_color number[]
---@field texture_overlay string
---@field texture_overlay_color number[]
---@field icon_enabled boolean
---@field icon_spec string
---@field icon_class string
---@field icon_line_startafter boolean
---@field icon_show_faction boolean
---@field totalbar_enabled boolean
---@field totalbar_ontop boolean
---@field totalbar_grouponly boolean
---@field totalbar_color number[]
---@field text_color number[]
---@field text_size number
---@field text_x_offset number
---@field text_y_offset number
---@field text_font string
---@field text_percent_type number
---@field text_left_colorbyclass boolean
---@field text_left_outline string
---@field text_left_shadow_color number[]
---@field text_left_shadow_offset number[]
---@field text_show_rank boolean
---@field text_centered boolean

---@class details_allinonewindow_settings_titlebar : table
---@field height number

---@type details_allinonewindow_settings
local defaultSettings = {
    data =  {
        segmentId = DETAILS_SEGMENTID_CURRENT,
    },
    header = {
        column_selected = "dmgdps",
        column_names = {"icon", "rank", "pname", "dmgdps", "healhps", "death", "interrupt", "dispel"},
        column_order = {},
        column_width = {},
        column_show_text = {},
        column_show_icon = {},
        background_color = {.2, .2, .2, 0.834},
        column_selected_color = {.3, .3, .3, 0.2},
    },
    window = {
        position = {},
        width = 200, --automatically calculated
        height = 100, --automatically calculated
        line_amount = 5,
        background_texture = "Details Ground",
        background_color = {.1, .1, .1, 0.834},
        strata = "LOW", --LOW, MEDIUM, HIGH, DIALOG
        clickthrough_window = false, --the window ignores mouse clicks
        clickthrough_incombatonly = true, --when enabled, the clickthrough is only active when in combat
        locked = false, --when disabled, resizers are not shown and the window is locked
        header_ontop = true, --the header is on top of the window
        is_open = true, --whether the window is open or closed
    },

    lines = {
        height = 20, --height of each line
        space_between = 1, --pixels between each line
        highlight = true, --show a white texture with low alpha when hovering over a line
        always_show_player = true, --when enabled, the player line will always be shown
        texture_background = "You Are the Best!",
        texture_background_color = {.1, .1, .1, 0.3},
        texture_background_colorbyclass = true,
        texture_main = "You Are the Best!", --the texture used in the statusbar
        texture_main_colorbyclass = true, --when enabled, the texture color will be based on the player's class
        texture_main_color = {.3, .3, .3, 0.834}, --the color of the texture used in the statusbar when not colored by class
        texture_overlay = "Details Vidro", --the texture used in the statusbar overlay
        texture_overlay_color = {.3, .3, .3, 0}, --the color of the texture overlay used in the statusbar, alpha zero by default to hide it
        icon_enabled = true, --show the player icon on the left side of the line
        icon_spec = [[Interface\AddOns\Details\images\spec_icons_normal]], --always show the spec if the unit spec is known
        icon_class = [[Interface\AddOns\Details\images\classes_small]], --fallback to class texture if spec is unknown
        icon_line_startafter = true, --places the line left side attached to icon right side, otherwise it attached to the icon left side. transparent icons might want to disable this.
        icon_show_faction = true, --while in a battleground, show the faction icon if the unit is an enemy
        totalbar_enabled = false, --show the total bar
        totalbar_ontop = false, --show the total bar on top of the lines, otherwise it will be below
        totalbar_grouponly = true, --only show the total bar when the player is in a group
        totalbar_color = {.3, .3, .3, 0.834},

        text_color = {1, 1, 1, 0.823}, --the text color used in the lines
        text_size = 13, --the text size used in the lines
        text_x_offset = 0, --the text horizontal offset, used to align the text with the statusbar
        text_y_offset = 0, --the text vertical offset, used to align the text with the statusbar
        text_centered = false,
        text_font = "Accidental Presidency",
        text_percent_type = 1, --type 1: relative to total, 2: relative to top player
        text_left_colorbyclass = false,
        text_left_outline = "NONE",
        text_left_shadow_color = {0, 0, 0, 1},
        text_left_shadow_offset = {1, -1},
        text_show_rank = true, --show the rank number before the name
    },

    titlebar = {
        height = 20,
    },
}

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow
AllInOneWindow.WindowFrames = {}
AllInOneWindow.Icons = {}
AllInOneWindow.ActorCache = Details222.Tables.MakeWeakTable()

function Details222.AllInOneWindow:Initialize()
    --get profile
    local windowSetting = Details.window2_data
    local windowCount = #windowSetting
    --this will open all windows created
    for i = 1, windowCount do
        --need to check if this window was opened on the last session
        if (windowSetting[i].window.is_open) then
            AllInOneWindow:OpenWindow(i)
        end
    end
end

AllInOneWindow.Debug = true
function AllInOneWindow:Print(...)
    if (self.Debug) then
        print("|cFFFF8800AllInOneWindow:|r", ...)
    end
end

---get an actor from the cache
---@param self details_allinonewindow
---@param actorName actorname
---@return actor?
function AllInOneWindow:GetActorFromCache(actorName)
    return self.ActorCache[actorName]
end

---@type details_allinonewindow_frame_functions
local windowFunctionsMixin = {
    ---returns the window id
    ---@param self details_allinonewindow_frame
    ---@return number windowId
    GetId = function(self)
        return self.windowId
    end,

    ---return true if the window is open
    ---@param self details_allinonewindow_frame
    ---@return boolean isOpen
    IsOpen = function(self)
        return self:IsShown()
    end,

    ---return the scroll frame used in the window
    ---@param self details_allinonewindow_frame
    ---@return df_scrollbox scrollFrame
    GetScrollFrame = function(self)
        return self.ScrollFrame
    end,

    ---return the segment id used in the window
    ---@param self details_allinonewindow_frame
    ---@return number segmentId
    GetSegmentId = function(self)
        return self.segmentId
    end,

    ---set the segment id used in the window
    ---@param self details_allinonewindow_frame
    ---@param segmentId number
    ---@param noRefresh boolean
    SetSegmentId = function(self, segmentId, noRefresh)
        self.segmentId = segmentId
        --refresh the window
        if (not noRefresh) then
            AllInOneWindow:RefreshWindow(self)
        end
    end,

    ---@param self details_allinonewindow_frame
    ---@param noRefresh boolean
    ValidateSegment = function(self, noRefresh)
        local segmentId = self:GetSegmentId()
        if (segmentId ~= DETAILS_SEGMENTID_CURRENT and segmentId ~= DETAILS_SEGMENTID_OVERALL) then
            local combat = Details:GetCombat(segmentId)
            if (not combat) then
                self:SetSegmentId(DETAILS_SEGMENTID_CURRENT, noRefresh)
            end
        end
    end,

    ---return the header frame used in the window
    ---@param self details_allinonewindow_frame
    ---@return details_allinonewindow_headerframe
    GetHeader = function(self)
        return self.Header
    end,

    ---this function return the settings table with the header column data
    ---@param self details_allinonewindow_frame
    ---@return string[] columnNames
    GetHeaderNames = function(self)
        return self.settings.header.column_names
    end,

    GetCombat = function(self)
        return Details:GetCombat(self:GetSegmentId())
    end,

    ---@param self details_allinonewindow_frame
    CalcAndSetLineAmount = function(self)
        --calculate how many lines can fit in the window, for this we get the window height minus the header height and divide by line height+space
        local lineHeight = self.settings.lines.height
        local headerHeight = self:GetHeader():GetHeight()
        local availableHeight = self:GetHeight() - headerHeight
        local lineLimitToUpdate = math.floor(availableHeight / (lineHeight + 2))
        local scrollFrame = self:GetScrollFrame()
        scrollFrame:SetNumFramesShown(lineLimitToUpdate)
    end,

    SetSortKeyTopAndTotal = function(self, key, top, total)
        self.sortKey = key
        self.currentTop = top
        self.currentTotal = total
    end,

    GetSortKeyTopAndTotal = function(self)
        return self.sortKey, self.currentTop, self.currentTotal
    end,

    GetSelectedColumnName = function(self)
        return self.settings.header.column_selected
    end,
    SetSelectedColumnName = function(self, key)
        self.settings.header.column_selected = key
    end,

    ---for back compatibility, return atributo and sub_atributo members
    ---@param self details_allinonewindow_frame
    ---@return number atributo
    ---@return number sub_atributo
    GetDisplay = function(self)
        return self.atributo, self.sub_atributo
    end,

    ---@param self details_allinonewindow_frame
    ---@param atributo number
    ---@param sub_atributo number
    SetDisplay = function(self, atributo, sub_atributo)
        self.atributo = atributo
        self.sub_atributo = sub_atributo
    end,

    ---for back compatibility, it'll always return 2 (group mode)
    ---@param self details_allinonewindow_frame
    ---@return number modeId
    GetMode = function(self)
        return 2
    end,

    ---for back compatibility, refresh the window
    ---@param self details_allinonewindow_frame
    RefreshWindow = function(self)
        AllInOneWindow:RefreshWindow(self)

        if (Details:IsBreakdownWindowOpen()) then
            Details:GetActorObjectFromBreakdownWindow():MontaInfo()
        end
    end,

    SetSegmentFromCooltip = function(_, instance, segmentId, bForceChange) --back compatibility with old instances
        ---@cast instance details_allinonewindow_frame
        return instance:SetSegmentId(segmentId, bForceChange)
    end,
}

---@param self details_allinonewindow
---@param windowId number
function AllInOneWindow:GetSettings(windowId)
    local windowSetting = Details.window2_data[windowId]
    if (not windowSetting) then
        windowSetting = detailsFramework.table.copy({}, defaultSettings)
        Details.window2_data[windowId] = windowSetting
    else
        detailsFramework.table.deploy(windowSetting, defaultSettings)
    end
    return windowSetting
end

---@param self details_allinonewindow
function AllInOneWindow:GetNumWindowsCreated()
    return #self.WindowFrames
end

function AllInOneWindow:GetAllWindows()
    return self.WindowFrames
end

function AllInOneWindow:ExecuteOnAllOpenedWindows(functionName)
    local allWindows = AllInOneWindow:GetAllWindows()
    for i = 1, #allWindows do
        local windowFrame = allWindows[i]
        if (windowFrame:IsOpen()) then
            local func = windowFrame[functionName]
            if (func) then
                func(windowFrame)
            end
        end
    end
end

function AllInOneWindow:SetSegmentIdOnAllWindows(segmentId)
    for i = 1, #self.WindowFrames do
        local windowFrame = self.WindowFrames[i]
        if (windowFrame:IsOpen()) then
            windowFrame:SetSegmentId(segmentId)
        end
    end
end

--return if there is at least one window open
function AllInOneWindow:HasOpenWindow()
    for _, windowFrame in pairs(self.WindowFrames) do
        if (windowFrame:IsOpen()) then
            return true
        end
    end
    return false
end

function AllInOneWindow:CloseWindow(windowId)
    local windowFrame = self.WindowFrames[windowId]
    if (windowFrame) then
        windowFrame:Hide()
        windowFrame.settings.window.is_open = false
    end
end

function AllInOneWindow:OpenWindow(windowId) --~open õpen
    local windowFrame = self.WindowFrames[windowId]
    if (not windowFrame) then
        windowFrame = self:CreateWindowFrame()
        windowFrame:SetPoint("center", UIParent, "center", 0, 0)
        windowFrame.settings = self:GetSettings(windowId)
        --wipe(windowFrame.settings) --debug
        windowFrame.latestRefresh = -1
        self.WindowFrames[windowId] = windowFrame

        --check if there is new columnNames to add to the order
        for i = 1, #AllInOneWindow.HeaderColumnData do
            local columnName = AllInOneWindow.HeaderColumnData[i].name
            if (columnName and not windowFrame.settings.header.column_order[columnName]) then
                windowFrame.settings.header.column_order[columnName] = i
            end
        end

        windowFrame:SetSize(windowFrame.settings.window.width, windowFrame.settings.window.height)

        local LibWindow = LibStub("LibWindow-1.1")
        LibWindow.RegisterConfig(windowFrame, windowFrame.settings.window.position)
        LibWindow.MakeDraggable(windowFrame)
        LibWindow.RestorePosition(windowFrame)

        windowFrame:SetPoint("center", UIParent, "center", 0, 100)

        --[=[
            C_Timer.After(1, function()
                if (windowFrame:IsOpen()) then
                --clear all point
                    windowFrame:ClearAllPoints()
                    windowFrame:SetPoint("center", UIParent, "center", 0, 100)
                end
            end)
        --]=]

        windowFrame:SetMovable(true)
        windowFrame:SetResizable(true)

        windowFrame:CalcAndSetLineAmount()

        windowFrame.segmentId = windowFrame.settings.data.segmentId or DETAILS_SEGMENTID_CURRENT
    end

    AllInOneWindow:RegisterEvents()

    local noRefresh = true
    windowFrame:ValidateSegment(noRefresh)

    windowFrame:Show()
    self:RefreshWindowLayout(windowFrame)

    local debugSizes = false
    if (debugSizes) then
        print("window size:", windowFrame:GetWidth(), windowFrame:GetHeight())
        local header = windowFrame:GetHeader()
        print("header size:", header:GetWidth(), header:GetHeight())
        local scrollFrame = windowFrame:GetScrollFrame()
        print("scrollFrame size:", scrollFrame:GetWidth(), scrollFrame:GetHeight())
    end

    self:RefreshWindow(windowFrame)

    C_Timer.After(1, function()
        if (windowFrame:IsOpen()) then
            self:RefreshWindow(windowFrame)
        end
    end)

    windowFrame.settings.window.is_open = true
end

function Details:OpenAllInOneWindow(windowId)
    AllInOneWindow:OpenWindow(windowId)
end

---run when the user clicks a column header
---@param headerFrame df_headerframe
---@param columnHeader df_headercolumnframe
local onColumnHeaderClickCallback = function(headerFrame, columnHeader, columnIndex, order)
    ---@type details_allinonewindow_frame
    local windowFrame = headerFrame:GetParent()
    windowFrame:SetSelectedColumnName(columnHeader.key)
    AllInOneWindow:RefreshWindow(windowFrame)
end

---@param headerFrame details_allinonewindow_headerframe
---@param optionName string
---@param columnName string
---@param value any
local onHeaderColumnOptionChanged = function(headerFrame, optionName, columnName, value) --setting is usually "width"
    if (optionName == "width") then
        local newHeaderColumnWidth = value
        ---@type details_allinonewindow_frame
        local windowFrame = headerFrame:GetParent()
        windowFrame.settings.header.column_width[columnName] = newHeaderColumnWidth
        C_Timer.After(0, function()
            AllInOneWindow:RefreshHeader(windowFrame)
            AllInOneWindow:RefreshWindowLayout(windowFrame)
        end)
    end
end


--~header
local headerOptions = {
    padding = 2,
    propagate_clicks = true,
    header_height = 14,
    reziser_shown = true,
    reziser_width = 2,
    reziser_color = {.5, .5, .5, 0.7},
    reziser_max_width = 246,
    header_click_callback = onColumnHeaderClickCallback,
    header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
    text_color = {1, 1, 1, 0.823},
}

---this function get called when the scrollbox needs to refresh its lines
---it get the data for each line and update the line by the column names
---@param self df_scrollbox
---@param data actorname[]
---@param offset number
---@param totalLines number
local windowScrollRefreshFunc = function(self, data, offset, totalLines) --~refresh

    local ToK = Details:GetCurrentToKFunction()
    ---@type details_allinonewindow_frame
    local windowFrame = self:GetParent()
    local headerFrame = windowFrame:GetHeader()
    local headerNames = windowFrame:GetHeaderNames()
    local combatObject = windowFrame:GetCombat()

    windowFrame.isRefreshing = true

    if not combatObject then
        return
    end

    if (windowFrame.latestRefresh == GetTime()) then
        --return
    end
    windowFrame.latestRefresh = GetTime()

    ---@type actorcontainer[]
    local containers = {
        combatObject:GetContainer(DETAILS_ATTRIBUTE_DAMAGE),
        combatObject:GetContainer(DETAILS_ATTRIBUTE_HEAL),
        combatObject:GetContainer(DETAILS_ATTRIBUTE_ENERGY),
        combatObject:GetContainer(DETAILS_ATTRIBUTE_MISC),
    }

    local key, top, total = windowFrame:GetSortKeyTopAndTotal()

    --get the selected --column_selected_color
    --local columnIndex, order, columnName = headerFrame:GetSelectedColumn()


    for i = 1, totalLines do
    	local index = i + offset
        ---@type string
		local playerName = data[index]
        if (playerName) then
            local line = self:GetLine(i)
            ---@cast line details_allinonewindow_line

            if (line) then
                line:ResetFramesToHeaderAlignment()
                line.PlayerIconTexture:Hide()

                local actorObjects = {
                    containers[DETAILS_ATTRIBUTE_DAMAGE]:GetActor(playerName),
                    containers[DETAILS_ATTRIBUTE_HEAL]:GetActor(playerName),
                    containers[DETAILS_ATTRIBUTE_ENERGY]:GetActor(playerName),
                    containers[DETAILS_ATTRIBUTE_MISC]:GetActor(playerName),
                }

                local statusBarWidth = AllInOneWindow.HeaderColumnData[2].width + AllInOneWindow.HeaderColumnData[3].width + 4
                local statusBar = line:GetStatusBar()
                statusBar:SetWidth(statusBarWidth)

                for headerIndex, headerName in ipairs(headerNames) do
                    local headerColumnFrame = line:GetFrameForData(headerIndex)
                    local result = AllInOneWindow:RefreshColumn(index, windowFrame, line, headerColumnFrame, containers, headerName, playerName, combatObject, actorObjects)

                    if (AllInOneWindow.TooltipScripts[headerName]) then
                        headerColumnFrame:SetOnEnterCallback(AllInOneWindow.TooltipScripts[headerName], actorObjects, windowFrame, line, combatObject)
                    else
                        headerColumnFrame:SetOnEnterCallback(nil)
                    end

                    local columnData = AllInOneWindow:GetColumnData(headerName)
                    headerColumnFrame:SetSize(columnData.width - 2, line:GetHeight() - 2)
                    headerColumnFrame:SetDisplay(columnData.attribute, columnData.subAttribute)

                    line:AddFrameToHeaderAlignment(headerColumnFrame)

                    if (key == headerName) then --this is the selected header
                        statusBar:SetMinMaxValues(0, top)
                        statusBar:SetValue(result)

                        headerColumnFrame.BackgroundTexture:SetVertexColor(unpack(windowFrame.settings.header.column_selected_color))
                    else
                        headerColumnFrame.BackgroundTexture:SetVertexColor(0, 0, 0, 0)
                    end

                    if (headerName == "rank" or headerName == "pname") then
                        statusBarWidth = statusBarWidth + columnData.width
                    end

                    --pergunta: precisa mostrar a scrollbar?
                end

                if (windowFrame.settings.lines.texture_main_colorbyclass) then
                    local r, g, b = Details:GetBarColor(actorObjects[1] or actorObjects[2] or actorObjects[3] or actorObjects[4])
                    statusBar:SetStatusBarColor(r, g, b, 1)
                else
                    statusBar.StatusBarTexture:SetVertexColor(unpack(windowFrame.settings.lines.texture_main_color))
                end

                line:AlignWithHeader(headerFrame, "left")
            else
                --print("no line:", i, index, playerName)
            end
        end
    end

    windowFrame.isRefreshing = false
end


--functions to run when the mouse enter a line or leave
local windowLineOnEnter = function(line)

end
local windowLineOnLeave = function(line)

end

--functions to run when the line receives a mouse down and mouse up event
local windowLineOnMouseDown = function(line, button)
    --print("mouse down on line", line.index, button)
end
local windowLineOnMouseUp = function(line, button)
    --print("mouse up on line", line.index, button)
end
--function to run when the player icon is hovered over and clicked
local onEnterPlayerIconFrame = function(playerIconFrame)
    --cooltip showing 'entered icon' phrase
    GameCooltip:Preset(2)
    GameCooltip:SetOwner(playerIconFrame)
    GameCooltip:AddLine("Entered Icon")
    GameCooltip:Show()
end
local onLeavePlayerIconFrame = function(playerIconFrame)
    GameCooltip:Hide()
end
local onClickPlayerIconFrame = function(playerIconFrame)
    --print("Clicked Icon")
end

---@param self details_allinonewindow_line
---@param columnId number
local getFrameForData = function(self, columnId)
    return self.FramesForData[columnId]
end

---@param self details_allinonewindow_line
local getAllFramesForData = function(self)
    return self.FramesForData
end

---@param self details_allinonewindow_line
local getStatusBar = function(self)
    return self.StatusBar
end

--data frame functions (data frame are the frames used to show data in each column of a line (e.g. damage, healing, etc), each line has multiple data frames)
---@param self details_allinonewindow_line_dataframe
---@param func fun(self: details_allinonewindow_line_dataframe, func: fun(self: details_allinonewindow_line_dataframe))
---@param actorObjects actor[]
---@param windowFrame details_allinonewindow_frame
---@param line details_allinonewindow_line
---@param combatObject combat
local setDataFrameOnEnterCallbackFunction = function(self, func, actorObjects, windowFrame, line, combatObject)
    self.onEnterCallback = func
    if (func) then
        self.actorObjects = actorObjects
        --self.windowFrame = windowFrame
        self.line = line
        self.combatObject = combatObject
    else
        self.actorObjects = nil
        --self.windowFrame = nil
        self.line = nil
        self.combatObject = nil
    end

    windowLineOnEnter(self:GetParent())
end

---@param self details_allinonewindow_line_dataframe
---@param atributo number
---@param sub_atributo number
local setDataFrameDisplayFunction = function(self, atributo, sub_atributo)
    self.atributo = atributo
    self.sub_atributo = sub_atributo
end

---@param self details_allinonewindow_line_dataframe
---@return number, number
local getDataFrameDisplayFunction = function(self)
    return self.atributo, self.sub_atributo
end

---@param self details_allinonewindow_line_dataframe
---@param button string
local onClickDataFrameFunction = function(self, button)
    local attribute, subAttribute = self:GetDisplay()
    --OpenBreakdownWindow() will call GetDisplay on the windowFrame, so we need to set there the 'atributo' and 'sub_atributo' members
    self.windowFrame:SetDisplay(attribute, subAttribute)



    if (attribute == DETAILS_ATTRIBUTE_DAMAGE or attribute == DETAILS_ATTRIBUTE_HEAL) then
        Details:OpenBreakdownWindow(self.windowFrame, self:GetActor())
    else
        --do nothing when clicked
    end
end

---@param self details_allinonewindow_line_dataframe
---@return actor?
local getDataFrameActor = function(self)
    return self.actorObject
end

---@param self details_allinonewindow_line_dataframe
local onEnterDataFrameFunction = function(self)
    self.Text:SetTextColor(1, 1, 0, 1)

    if (self.onEnterCallback) then
        self.onEnterCallback(self, self.actorObjects, self.windowFrame, self.line, self.combatObject)
    end
end

---@type fun(self: details_allinonewindow_line_dataframe)
local onLeaveDataFrameFunction = function(self)
    self.Text:SetTextColor(1, 1, 1, 1)
    GameCooltip:Hide()
end

---create a data frame to be used in a line, this frame will show the data for a specific column, each line has multiple data frames
---@param windowFrame details_allinonewindow_frame
---@param line details_allinonewindow_line
---@param columnId number
local createHeaderColumnDataFrame = function(windowFrame, line, columnId) --~dataframe
    ---@type details_allinonewindow_line_dataframe
    local headerColumnFrame = CreateFrame("button", "$parentFrameForData" .. columnId, line)
    headerColumnFrame.windowFrame = windowFrame
    headerColumnFrame.line = line
    --the size of the frame will be set later to follow the header width

    --create a background texture
    local backgroundTexture = headerColumnFrame:CreateTexture("$parentBackground", "background")
    backgroundTexture:SetAllPoints()
    backgroundTexture:SetColorTexture(1, 1, 1)
    headerColumnFrame.BackgroundTexture = backgroundTexture

    headerColumnFrame.SetOnEnterCallback = setDataFrameOnEnterCallbackFunction
    headerColumnFrame.GetActor = getDataFrameActor
    headerColumnFrame.SetDisplay = setDataFrameDisplayFunction
    headerColumnFrame.GetDisplay = getDataFrameDisplayFunction

    headerColumnFrame:SetScript("OnClick", onClickDataFrameFunction)
    headerColumnFrame:SetScript("OnEnter", onEnterDataFrameFunction)
    headerColumnFrame:SetScript("OnLeave", onLeaveDataFrameFunction)
    line.FramesForData[#line.FramesForData+1] = headerColumnFrame

    headerColumnFrame:SetPropagateMouseMotion(true) --let the mouse motion propagate to the line
    headerColumnFrame:SetPropagateMouseClicks(true) --let the click propagate to the line

    --the text to show the data
    local text = headerColumnFrame:CreateFontString("$parentText", "overlay", "GameFontHighlightSmall")
    text:SetPoint("left", headerColumnFrame, "left", 2, 0)
    text:SetJustifyH("left")
    text:SetTextColor(1, 1, 1, 1)
    text:SetNonSpaceWrap(true)
    text:SetWordWrap(false)

    headerColumnFrame.Text = text
end

---@param scrollFrame df_scrollbox
---@param lineId number
---@return details_allinonewindow_line line
local createLineForWindow = function(scrollFrame, lineId) --~line
    ---@type details_allinonewindow_frame
    local windowFrame = scrollFrame:GetParent()

    ---@type details_allinonewindow_line
    local line = CreateFrame("Button", "$parentLine" .. lineId, scrollFrame, "BackdropTemplate")
    line:EnableMouse(true)
    line:RegisterForClicks("AnyUp", "AnyDown")
    line:SetScript("OnEnter", windowLineOnEnter)
    line:SetScript("OnLeave", windowLineOnLeave)
    line:SetScript("OnMouseDown", windowLineOnMouseDown)
    line:SetScript("OnMouseUp", windowLineOnMouseUp)
    line.index = lineId
    line.onMouseUpTime = 0
    line.ExpandedChildren = {}
    line.FramesForData = {}

    detailsFramework:Mixin(line, detailsFramework.HeaderFunctions)

    line.GetFrameForData = getFrameForData
    line.GetAllFramesForData = getAllFramesForData
    line.GetStatusBar = getStatusBar

    --the height of the line is set later on an update function

    do --line textures
        local backgroundTexture = line:CreateTexture("$parentTextureBackground", "background")
        backgroundTexture:SetAllPoints()
        line.BackgroundTexture = backgroundTexture

        local highlightTexture = line:CreateTexture("$parentTextureHighlight", "highlight")
        highlightTexture:SetColorTexture(1, 1, 1, 0.2)
        highlightTexture:SetAllPoints()
        line.HighlightTexture = highlightTexture
    end

    --the statusbar which will fill the line according with the percentage given by the data
    ---@type details_allinonewindow_line_statusbar
    local statusBar = CreateFrame("StatusBar", "$parentStatusBar", line)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:EnableMouse(false)
    statusBar:SetFrameLevel(line:GetFrameLevel()+1)
    line.StatusBar = statusBar

    do --statusbar textures
        ---@type texture this is the statusbar texture
        local statusBarTexture = statusBar:CreateTexture("$parentTexture", "artwork")
        statusBarTexture:SetTexture([[Interface\WORLDSTATEFRAME\WORLDSTATEFINALSCORE-HIGHLIGHT]])
        statusBar:SetStatusBarTexture(statusBarTexture)
        statusBar:SetStatusBarColor(0, 1, 0, 1)
        statusBar.StatusBarTexture = statusBarTexture

        local overlayTexture = statusBar:CreateTexture("$parentTextureOverlay", "overlay", nil, 7)
        overlayTexture:SetTexture([[Interface/AddOns/Details/images/overlay_indicator_1]])
        overlayTexture:SetVertexColor(1, 1, 1, 0.2)
        overlayTexture:SetAllPoints()
        overlayTexture:Hide()
        statusBar.OverlayTexture = overlayTexture

        local highlightTexture = statusBar:CreateTexture("$parentTextureHighlight", "highlight")
        highlightTexture:SetColorTexture(1, 1, 1, 0.1)
        highlightTexture:SetAllPoints()
        statusBar.HighlightTexture = highlightTexture
    end

    --frame which will show the player tooltip when hovering over the icon
    ---@type details_allinonewindow_line_statusbar_iconbutton
    local playerIconFrame = CreateFrame("button", "$parentIconFrame", line) --icon position is static
    playerIconFrame:SetPoint("topleft", line, "topleft", 1, -1)
    playerIconFrame:SetPoint("bottomleft", line, "bottomleft", 1, 1)
    playerIconFrame:SetFrameLevel(statusBar:GetFrameLevel()+1)
    playerIconFrame:SetScript("OnEnter", onEnterPlayerIconFrame)
    playerIconFrame:SetScript("OnLeave", onLeavePlayerIconFrame)
    playerIconFrame:SetScript("OnClick", onClickPlayerIconFrame)
    playerIconFrame.SetOnEnterCallback = setDataFrameOnEnterCallbackFunction
    playerIconFrame.GetActor = getDataFrameActor
    playerIconFrame.SetDisplay = setDataFrameDisplayFunction
    playerIconFrame.GetDisplay = getDataFrameDisplayFunction
    statusBar.PlayerIconFrame = playerIconFrame

    --the text to show the data, if the icon isn't shown
    playerIconFrame.Text = playerIconFrame:CreateFontString("$parentText", "overlay", "GameFontHighlightSmall")
    playerIconFrame.Text:SetPoint("left", playerIconFrame, "left", 2, 0)
    playerIconFrame.Text:SetJustifyH("left")
    playerIconFrame.Text:SetTextColor(1, 1, 1, 1)
    playerIconFrame.Text:SetNonSpaceWrap(true)
    playerIconFrame.Text:SetWordWrap(false)

    --create a background texture
    playerIconFrame.BackgroundTexture = playerIconFrame:CreateTexture("$parentBackground", "background")
    playerIconFrame.BackgroundTexture:SetAllPoints()
    playerIconFrame.BackgroundTexture:SetColorTexture(1, 1, 1, 0)

    --the icon to show the class or spec icon, it's size only require a width
    ---@type texture
    playerIconFrame.Texture = playerIconFrame:CreateTexture("$parentIcon", "artwork")
    playerIconFrame.Texture:SetAllPoints()

    --shortcut for the icon
    line.PlayerIconTexture = playerIconFrame.Texture

    line.FramesForData[#line.FramesForData+1] = playerIconFrame

    ---@type details_allinonewindow_line_statusbar_expandbutton
    local expandButton = CreateFrame("button", "$parentExpandButton", statusBar, "BackdropTemplate")
    expandButton:SetSize(20, 20) --this size is updated later in an update function
    expandButton:SetFrameLevel(statusBar:GetFrameLevel()+1)
    expandButton:RegisterForClicks("LeftButtonDown")
    expandButton:Hide()
    statusBar.ExpandButton = expandButton

    ---@type texture
    local expandButtonTexture = expandButton:CreateTexture("$parentTexture", "artwork")
    expandButtonTexture:SetPoint("center", expandButton, "center", 0, 0)
    expandButtonTexture:SetSize(20, 20)
    expandButton.Texture = expandButtonTexture

    local maxColumns = 16

    --create data frames to hold information for each column (data frames)
    for columnId = 1, maxColumns do
        createHeaderColumnDataFrame(windowFrame, line, columnId)
    end

    return line
end

---@param self details_allinonewindow_frame
local onWindowSizeChanged = function(self)
    if (self.isRefreshing) then
        C_Timer.After(0, function()
            if (self:IsOpen()) then
                self:GetScript("OnSizeChanged")(self)
            end
        end)
        return
    end

    local settings = self.settings
    settings.window.width = self:GetWidth()
    settings.window.height = self:GetHeight()

    local LibWindow = LibStub("LibWindow-1.1")
    LibWindow.SavePosition(self)

    self:CalcAndSetLineAmount()
    local scrollFrame = self:GetScrollFrame()
    scrollFrame:Refresh()
end

--this function only creates the frames, do not refresh anything
---@param self details_allinonewindow
---@return details_allinonewindow_frame window
function AllInOneWindow:CreateWindowFrame() --~create
    local windowId = self:GetNumWindowsCreated()+1

    ---@type details_allinonewindow_frame
    local windowFrame = CreateFrame("Frame", "DetailsAllInOneWindow" .. windowId, UIParent, "BackdropTemplate")
    detailsFramework:Mixin(windowFrame, windowFunctionsMixin)
    windowFrame.windowId = windowId

    windowFrame.baseframe = CreateFrame("Frame", "$parentBaseFrame", windowFrame)
    windowFrame.baseframe:SetAllPoints()
    windowFrame.baseframe:Hide()

    windowFrame:SetSortKeyTopAndTotal("dmg", 0.1, 0.1) --avoid division by zero

    windowFrame:SetScript("OnSizeChanged", onWindowSizeChanged)

    detailsFramework:MakeDraggable(windowFrame)

    windowFrame.Lines = {}

    --title
    local titleFontString = windowFrame:CreateFontString("$parentTitle", "overlay", "GameFontNormal")
    titleFontString:SetPoint("bottomleft", windowFrame, "topleft", 2, 2)
    titleFontString:SetJustifyH("left")
    titleFontString:SetText("Details! for Midnight (under development)")
    --font color
    titleFontString:SetTextColor(1, 1, 1, 0.5)

    --topleft button to close the window
    local closeButton = CreateFrame("button", "$parentCloseButton", windowFrame)
    closeButton:SetSize(18, 18)
    closeButton:SetPoint("topleft", windowFrame, "topleft", 1, 0)
    closeButton.Icon = closeButton:CreateTexture("$parentIcon", "artwork")
    closeButton.Icon:SetPoint("center", closeButton, "center", 0, 0)
    closeButton.Icon:SetSize(closeButton:GetSize())
    closeButton.Icon:SetTexture([[Interface\AddOns\Details\assets\textures\icons\close.png]])
    closeButton:SetFrameLevel(windowFrame:GetFrameLevel()+2)
    closeButton:SetScript("OnClick", function()
        AllInOneWindow:CloseWindow(windowFrame.windowId)
    end)

    --topleft button to open the options panel
    local optionsButton = CreateFrame("button", "$parentOptionsButton", windowFrame)
    optionsButton:SetSize(14, 14)
    optionsButton:SetPoint("left", closeButton, "right", 2, 0)
    optionsButton.Icon = optionsButton:CreateTexture("$parentIcon", "artwork")
    optionsButton.Icon:SetPoint("center", optionsButton, "center", 0, 0)
    optionsButton.Icon:SetSize(optionsButton:GetSize())
    optionsButton.Icon:SetTexture([[Interface\AddOns\Details\assets\textures\icons\wrench.png]])
    optionsButton:SetFrameLevel(windowFrame:GetFrameLevel()+2)
    optionsButton:SetScript("OnClick", function()
        AllInOneWindow:OpenOptionsPanel(windowFrame)
    end)

    local selectCombatButton = CreateFrame("button", "$parentSelectCombatButton", windowFrame)
    selectCombatButton:SetSize(14, 14)
    selectCombatButton:SetPoint("left", optionsButton, "right", 2, 0)
    selectCombatButton.Icon = selectCombatButton:CreateTexture("$parentIcon", "artwork")
    selectCombatButton.Icon:SetPoint("center", selectCombatButton, "center", 0, 0)
    selectCombatButton.Icon:SetSize(selectCombatButton:GetSize())
    selectCombatButton.Icon:SetTexture([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]])
    selectCombatButton:SetFrameLevel(windowFrame:GetFrameLevel()+2)
    selectCombatButton:SetScript("OnClick", function()
        Details.BuildSegmentMenu(selectCombatButton, 1, windowFrame)
    end)

    local scrollWidth = 2
    local scrollHeight = 2
    local scrollLineAmount = 40
    local scrollLineHeight = 20

    local scrollFrame = detailsFramework:CreateScrollBox(windowFrame, "$parentMainScroll", windowScrollRefreshFunc, {}, scrollWidth, scrollHeight, scrollLineAmount, scrollLineHeight)
    scrollFrame:SetFrameLevel(windowFrame:GetFrameLevel()+1)
    detailsFramework:ReskinSlider(scrollFrame)
    windowFrame.ScrollFrame = scrollFrame
    scrollFrame:SetBackdrop(nil)

    detailsFramework:ApplyStandardBackdrop(windowFrame)

	local headerTable = {}

	---create the header frame, the header frame is the frame which shows the columns names to describe the data shown in the window
	---@type details_allinonewindow_headerframe
	local headerFrame = detailsFramework:CreateHeader(windowFrame, headerTable, headerOptions)
    headerFrame:SetFrameLevel(windowFrame:GetFrameLevel()+1)
    headerFrame:SetPropagateMouseClicks(true) --let the click propagate to the windowFrame
	headerFrame:SetColumnSettingChangedCallback(onHeaderColumnOptionChanged)
	headerFrame.windowId = windowId
	windowFrame.Header = headerFrame

    --creating the lines after the header creation
    for lineId = 1, scrollLineAmount do
        scrollFrame:CreateLine(createLineForWindow)
    end

    local backgroundTexture = windowFrame:CreateTexture("$parentBackground", "background")
    backgroundTexture:SetAllPoints()
    windowFrame.BackgroundTexture = backgroundTexture

    local leftGrip, rightGrip = detailsFramework:CreateResizeGrips(windowFrame, {width = 20, height = 20})
    leftGrip:Hide()
    rightGrip:SetScript("OnMouseDown", function()
        windowFrame:StartSizing("TOP")
    end)
    rightGrip:SetScript("OnMouseUp", function()
        windowFrame:StopMovingOrSizing()
    end)
    windowFrame.RightResizerGrip = rightGrip
    rightGrip:Hide()

    return windowFrame
end

local refreshCache = {}

---@param self details_allinonewindow
---@param windowFrame details_allinonewindow_frame
function AllInOneWindow:RefreshWindowLayout(windowFrame)
    local settings = windowFrame.settings

    windowFrame:SetFrameStrata(settings.window.strata)

    local header = windowFrame:GetHeader()

    if (settings.window.clickthrough_window and not settings.window.clickthrough_incombatonly) then
        windowFrame:EnableMouse(false) --do propagate to children?
    end

    if (settings.window.locked) then
        windowFrame.RightResizerGrip:Hide()
    else
        windowFrame.RightResizerGrip:Show()
        windowFrame.RightResizerGrip:Hide() --development as there is no more window resize
    end

    if (settings.window.header_ontop) then
        header:SetPoint("topleft", windowFrame, "topleft", 2, -2)
    else
        header:SetPoint("bottomleft", windowFrame, "bottomleft", 2, -2)
    end

    --get the scrollframe
    local scrollFrame = windowFrame.ScrollFrame
    scrollFrame:ClearAllPoints()
    scrollFrame:SetPoint("topleft", header, "bottomleft", 0, -1)
    scrollFrame:SetPoint("topright", header, "bottomright", 0, -1)
    scrollFrame:SetPoint("bottomright", windowFrame, "bottomright", 0, 2)

    windowFrame.BackgroundTexture:SetTexture(sharedMedia:Fetch("statusbar", settings.window.background_texture))
    windowFrame.BackgroundTexture:SetVertexColor(unpack(settings.window.background_color))

    local lineFont = sharedMedia:Fetch("font", settings.lines.text_font)
    refreshCache.lineFont = lineFont

    --get the lines used in the window frame from the scroll frame
    ---@type details_allinonewindow_line[]
    local lines = scrollFrame:GetLines()
    --refresh the line layouts
    for i = 1, #lines do
        local line = lines[i]
        AllInOneWindow:RefreshLineLayout(windowFrame, line)
    end

    AllInOneWindow:RefreshHeader(windowFrame)

    local amountOfLines = settings.window.line_amount
    local lineHeight = settings.lines.height
    local spaceBetween = settings.lines.space_between
    local headerHeight = header:GetHeight()

    local totalHeight = 7 + (lineHeight * amountOfLines) + (spaceBetween * (amountOfLines - 1)) + headerHeight --~height
    windowFrame:SetHeight(totalHeight)
end

---@param self details_allinonewindow
---@param windowFrame details_allinonewindow_frame
---@param line details_allinonewindow_line
function AllInOneWindow:RefreshLineLayout(windowFrame, line)
    --this function get the window settings (a table) and apply it to its lines
    --get the scrollframe
    local scrollFrame = windowFrame.ScrollFrame

    --settings
    local settings = windowFrame.settings
    local index = line.index

    --calculate the point of this line
    local height = settings.lines.height
    line:SetHeight(height)

    --calculate the X offset to when the line start after the icon and the Y offset
    local yOffset = -(index - 1) * (height + settings.lines.space_between) --increment negativelly

    --set the line points
    line:ClearAllPoints()
    line:SetPoint("topleft", scrollFrame, "topleft", 0, yOffset)
    line:SetPoint("topright", scrollFrame, "topright", 0, yOffset)

    local backgroundTexture = line.BackgroundTexture
    backgroundTexture:SetTexture(settings.lines.texture_background)
    backgroundTexture:SetVertexColor(unpack(settings.lines.texture_background_color))
    --if (settings.lines.texture_background_colorbyclass) then
    --backgroundTexture:SetVertexColor(unpack(settings.lines.texture_background_color)) --set the class color
    --end

    local highlightTexture = line.HighlightTexture
    if (settings.lines.highlight) then
        highlightTexture:Show()
    else
        highlightTexture:Hide()
    end

    local statusBar = line.StatusBar
    --fetch texture from shared media
    local texturePath = sharedMedia:Fetch("statusbar", settings.lines.texture_main)
    statusBar.StatusBarTexture:SetTexture(texturePath)

    local xOffset = settings.lines.icon_enabled and settings.lines.icon_line_startafter and height or 0 -- value = 20
    statusBar:SetPoint("topleft", line, "topleft", xOffset, 0)
    statusBar:SetPoint("bottomleft", line, "bottomleft", xOffset, 0)

    local overlayTexture = statusBar.OverlayTexture
    overlayTexture:SetTexture(settings.lines.texture_overlay)
    overlayTexture:SetVertexColor(unpack(settings.lines.texture_overlay_color))

    local frameIcon = statusBar.PlayerIconFrame --frameIcon is parented to the line
    if (settings.lines.icon_enabled) then
        frameIcon:Show()
        frameIcon:SetWidth(height-2)
        frameIcon:SetHeight(height-2)
        frameIcon.Texture:SetTexture(settings.lines.icon_spec)
    else
        frameIcon:Hide()
    end

    for i = 1, #line.FramesForData do
        local frame = line.FramesForData[i]
        local fontString = frame.Text
        fontString:SetTextColor(unpack(settings.lines.text_color))
        fontString:SetFont(refreshCache.lineFont, settings.lines.text_size, settings.lines.text_left_outline)
        fontString:SetShadowColor(unpack(settings.lines.text_left_shadow_color))
        fontString:SetShadowOffset(unpack(settings.lines.text_left_shadow_offset))

        if (settings.lines.text_centered) then
            fontString:SetJustifyH("CENTER")
            fontString:ClearAllPoints()
            fontString:SetPoint("center", frame, "center", settings.lines.text_x_offset, settings.lines.text_y_offset)
        else
            fontString:SetJustifyH("LEFT")
            fontString:ClearAllPoints()
            fontString:SetPoint("left", frame, "left", 2 + settings.lines.text_x_offset, settings.lines.text_y_offset)
        end
    end

end

--[=[
    lines = {
        updates in real time:
        always_show_player = true, --when enabled, the player line will always be shown
        texture_background_color = {.1, .1, .1, 0.3},
        texture_background_colorbyclass = true,
        texture_main_colorbyclass = true, --when enabled, the texture color will be based on the player's class
        texture_main_color = {.3, .3, .3, 0.834}, --the color of the texture used in the statusbar when not colored by class
        icon_spec = [[Interface\AddOns\Details\images\spec_icons_normal]], --always show the spec if the unit spec is known
        icon_class = [[Interface\AddOns\Details\images\classes_small]], --fallback to class texture if spec is unknown
        icon_show_faction = true, --while in a battleground, show the faction icon if the unit is an enemy
        totalbar_ontop = false, --show the total bar on top of the lines, otherwise it will be below
        totalbar_grouponly = true, --only show the total bar when the player is in a group
        totalbar_color = {.3, .3, .3, 0.834},

        updates during layout:
        height = 20, --height of each line
        space_between = 1, --pixels between each line
        highlight = true, --show a white texture with low alpha when hovering over a line
        texture_background = "You Are the Best!",
        texture_main = "You Are the Best!", --the texture used in the statusbar
        texture_overlay = "Details Vidro", --the texture used in the statusbar overlay
        texture_overlay_color = {.3, .3, .3, 0}, --the color of the texture overlay used in the statusbar, alpha zero by default to hide it
        icon_enabled = true, --show the player icon on the left side of the line
        icon_line_startafter = true, --places the line left side attached to icon right side, otherwise it attached to the icon left side. transparent icons.
        totalbar_enabled = false, --show the total bar

        updates in real time:
        text_show_rank = true, --show the rank number before the name
        text_percent_type = 1, --type 1: relative to total, 2: relative to top player
        text_left_colorbyclass = false,

        updates during layout:
        text_x_offset = 0, --the text vertical offset, used to align the text with the statusbar
        text_y_offset = 0, --the text vertical offset, used to align the text with the statusbar
        text_centered = false,
        text_color = {1, 1, 1, 0.823}, --the text color used in the lines
        text_size = 11, --the text size used in the lines
        text_font = "Accidental Presidency",
        text_left_outline = "NONE",
        text_left_shadow_color = {0, 0, 0, 1},
        text_left_shadow_offset = {1, -1},
    },
--]=]
