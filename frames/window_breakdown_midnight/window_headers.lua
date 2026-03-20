
local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

---@class detailsbreakdownmidnight : table
---@field OnHeaderColumnOptionChanged fun(headerFrame: detailsbreakdownmidnight_header, optionName: string, columnName: string, value: any)
---@field OnHeaderColumnClick fun(headerFrame: detailsbreakdownmidnight_header, columnHeader: df_headercolumnframe)
---@field CreateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, parent: frame, sectionId: number, scrollFrame: detailsbreakdownmidnight_sectionscroll, headerLabels: string[]?) : detailsbreakdownmidnight_header
---@field UpdateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, sectionId: number, headerLabels: string[])

---@class detailsbreakdownmidnight_header : df_headerframe
---@field ScrollOwner detailsbreakdownmidnight_sectionscroll
---@field WindowOwner detailsbreakdownmidnight_window
---@field sectionId number
---@field refreshColumn boolean
---@field GetScrollBar fun(self: detailsbreakdownmidnight_header) : detailsbreakdownmidnight_sectionscroll

local realtimeHeaderRefreshInterval = 0.016

local headerMixin = {
    ---@param self detailsbreakdownmidnight_header
    ---@return detailsbreakdownmidnight_sectionscroll
    GetScrollBar = function(self)
        local scrollFrame = self.ScrollOwner
        return scrollFrame
    end,
}

---@param headerFrame detailsbreakdownmidnight_header
---@return boolean
local isAnyHeaderColumnResizing = function(headerFrame)
    for i = 1, #headerFrame.columnHeadersCreated do
        local columnHeader = headerFrame.columnHeadersCreated[i]
        if (columnHeader and columnHeader.bInUse and columnHeader.bIsRezising) then
            return true
        end
    end
    return false
end

---@return table<number, table<string, number>>
local getHeadersWidthTable = function()
    local profile = breakdownMidnight.GetProfile()
    local headersWidth = profile.headers_width
    if not headersWidth then
        profile.headers_width = {}
        headersWidth = profile.headers_width
    end
    return headersWidth
end

---@param sectionId number
---@param columnKey string
---@return number|nil
local getSavedHeaderWidth = function(sectionId, columnKey)
    local headersWidth = getHeadersWidthTable()

    local sectionWidths = headersWidth[sectionId]
    if (type(sectionWidths) ~= "table") then
        headersWidth[sectionId] = {}
        sectionWidths = headersWidth[sectionId]
    end

    local savedWidth = sectionWidths[columnKey]
    if (type(savedWidth) == "number" and savedWidth > 0) then
        return savedWidth
    end
end

---@param sectionId number
---@param columnKey string
---@param newWidth number
local saveHeaderWidth = function(sectionId, columnKey, newWidth)
    local headersWidth = getHeadersWidthTable()
    local sectionWidths = headersWidth[sectionId]

    if (type(sectionWidths) ~= "table") then
        headersWidth[sectionId] = {}
        sectionWidths = headersWidth[sectionId]
    end

    sectionWidths[columnKey] = newWidth
end

---@param sectionId number
---@param columnLabel string
---@param columnIndex number
---@return string
local getColumnKey = function(sectionId, columnLabel, columnIndex)
    local sectionIds = breakdownMidnight.Enums.SectionIds
    --for spell and player sections, first column is icon, second is rank and third is name
    if (sectionId == sectionIds.Spells or sectionId == sectionIds.Players) then
        if (columnIndex == 1) then
            return "icon"

        elseif (columnIndex == 2) then
            return "rank"

        elseif (columnIndex == 3) then
            return "name"
        end
    end

    --segment section columns are icon, elapsed and name
    if (sectionId == sectionIds.Segments) then
        if (columnIndex == 1) then
            return "icon"

        elseif (columnIndex == 2) then
            return "elapsed"

        elseif (columnIndex == 3) then
            return "name"
        end
    end

    local normalized = columnLabel:lower()
    if (normalized == "name" or normalized == "spell name" or normalized == "player name" or normalized == "segment name") then
        return "name"

    elseif (normalized == "amount" or normalized == "total") then
        return "amount"

    elseif (normalized == "dps" or normalized == "ps") then
        return "dps"

    elseif (normalized == "%") then
        return "percent"
    end

    return "value" .. columnIndex
end

---@param sectionId number
---@return boolean
local shouldAddIconAndRankColumns = function(sectionId)
    local sectionIds = breakdownMidnight.Enums.SectionIds
    return sectionId == sectionIds.Spells or sectionId == sectionIds.Players
end

---@param columnKey string
---@return number
local getDefaultWidthForColumnKey = function(columnKey)
    if (columnKey == "icon") then
        return 22

    elseif (columnKey == "rank") then
        return 20

    elseif (columnKey == "elapsed") then
        return 55

    elseif (columnKey == "name") then
        return 190
    end

    return 70
end

---@param sectionId number
---@param headerLabels string[]?
---@return string[]
local buildLabelsForSection = function(sectionId, headerLabels)
    local hasHeaderLabels = headerLabels and #headerLabels > 0
    local baseLabels = hasHeaderLabels and headerLabels or {"Name"}

    if (not shouldAddIconAndRankColumns(sectionId)) then
        local labels = {}
        for i = 1, #baseLabels do
            labels[#labels+1] = baseLabels[i]
        end
        return labels
    end

    local labels = {"", "#"}
    for i = 1, #baseLabels do
        labels[#labels+1] = baseLabels[i]
    end

    return labels
end

---@param sectionId number
---@param columnLabel string
---@param columnIndex number
---@return table
local buildHeaderColumnData = function(sectionId, columnLabel, columnIndex)
    local key = getColumnKey(sectionId, columnLabel, columnIndex)
    local isNameColumn = key == "name"
    local isAmountColumn = key == "amount"
    local savedWidth = getSavedHeaderWidth(sectionId, key)

    return {
        name = key,
        key = key,
        text = columnLabel,
        width = savedWidth or getDefaultWidthForColumnKey(key),
        align = "left",
        canSort = true,
        selected = isAmountColumn or nil,
        dataType = isAmountColumn and "number" or "string",
        order = isNameColumn and "ASC" or "DESC",
        offset = 0,
    }
end

---@param sectionId number
---@param headerLabels string[]?
---@return table
local buildHeaderTable = function(sectionId, headerLabels)
    local labels = buildLabelsForSection(sectionId, headerLabels)

    local headerTable = {}
    for i = 1, #labels do
        headerTable[#headerTable+1] = buildHeaderColumnData(sectionId, labels[i], i)
    end

    return headerTable
end

---@param headerFrame detailsbreakdownmidnight_header
---@param optionName string
---@param columnName string
---@param value any
function breakdownMidnight.OnHeaderColumnOptionChanged(headerFrame, optionName, columnName, value)
    if (optionName == "width") then
        local sectionId = headerFrame.sectionId
        saveHeaderWidth(sectionId, columnName, value)

        --get the windowFrame
        local windowFrame = headerFrame.WindowOwner
        windowFrame:RefreshAllScrolls()

        headerFrame.refreshColumn = true
        local scrollFrame = headerFrame.ScrollOwner
        scrollFrame:Refresh()
    end
end

---@param headerFrame detailsbreakdownmidnight_header
---@param columnHeader df_headercolumnframe
function breakdownMidnight.OnHeaderColumnClick(headerFrame, columnHeader)
    --refresh owner scroll when clicking a header column
    local scrollFrame = headerFrame.ScrollOwner
    scrollFrame:Refresh()
end

---@param windowFrame detailsbreakdownmidnight_window
---@param parent frame
---@param sectionId number
---@param scrollFrame detailsbreakdownmidnight_sectionscroll
---@param headerLabels string[]?
---@return detailsbreakdownmidnight_header
function breakdownMidnight.CreateSectionHeader(windowFrame, parent, sectionId, scrollFrame, headerLabels)
    local headerOptions = {
        padding = 2,
        header_height = 14,
        reziser_shown = true,
        reziser_width = 2,
        reziser_color = {.5, .5, .5, 0.7},
        reziser_max_width = 260,
        header_click_callback = breakdownMidnight.OnHeaderColumnClick,
        header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
        text_color = {1, 1, 1, 0.823},
    }

    local headerTable = buildHeaderTable(sectionId, headerLabels)
    local header = detailsFramework:CreateHeader(parent, headerTable, headerOptions)
    ---@cast header detailsbreakdownmidnight_header

    Mixin(header, headerMixin)

    header.ScrollOwner = scrollFrame
    header.WindowOwner = windowFrame
    header.sectionId = sectionId
    header:SetColumnSettingChangedCallback(breakdownMidnight.OnHeaderColumnOptionChanged)

    return header
end

---@param windowFrame detailsbreakdownmidnight_window
---@param sectionId number
---@param headerLabels string[]
function breakdownMidnight.UpdateSectionHeader(windowFrame, sectionId, headerLabels)
    local scrollFrame = windowFrame:GetScrollForSectionId(sectionId)

    if (not scrollFrame or not scrollFrame.Header) then
        return
    end

    local headerTable = buildHeaderTable(sectionId, headerLabels)
    scrollFrame.Header:SetHeaderTable(headerTable)
end
