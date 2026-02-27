local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

---@class detailsbreakdownmidnight : table
---@field OnHeaderColumnOptionChanged fun(headerFrame: detailsbreakdownmidnight_header, optionName: string, columnName: string, value: any)
---@field OnHeaderColumnClick fun(headerFrame: detailsbreakdownmidnight_header, columnHeader: df_headercolumnframe)
---@field CreateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, parent: frame, sectionId: string, scrollFrame: df_scrollbox?, headerLabels: string[]?) : df_headerframe
---@field UpdateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, sectionId: string, headerLabels: string[])

---@class detailsbreakdownmidnight_header : df_headerframe
---@field ScrollOwner df_scrollbox
---@field WindowOwner detailsbreakdownmidnight_window
---@field sectionId string

---@param sectionId string
---@param columnLabel string
---@param columnIndex number
---@return string
local getColumnKey = function(sectionId, columnLabel, columnIndex)
    --for spell section, first column is icon and second is name
    if (sectionId == "spells") then
        if (columnIndex == 1) then
            return "icon"
        elseif (columnIndex == 2) then
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

---@param sectionId string
---@param headerLabels string[]?
---@return table
local buildHeaderTable = function(sectionId, headerLabels)
    --fallback labels when no data label set exists yet
    local labels = headerLabels or {"Name"}

    --spell section always has icon column first
    if (sectionId == "spells") then
        local fullLabels = {""}
        for i = 1, #labels do
            fullLabels[#fullLabels+1] = labels[i]
        end
        labels = fullLabels
    end

    local headerTable = {}
    for i = 1, #labels do
        local key = getColumnKey(sectionId, labels[i], i)
        local isNameColumn = key == "name"
        local isAmountColumn = key == "amount"

        headerTable[#headerTable+1] = {
            name = key,
            key = key,
            text = labels[i],
            width = (key == "icon" and 20) or (isNameColumn and 190) or 70,
            align = "left",
            canSort = true,
            selected = isAmountColumn or nil,
            dataType = isAmountColumn and "number" or "string",
            order = isNameColumn and "ASC" or "DESC",
            offset = 0,
        }
    end

    return headerTable
end

---@param headerFrame detailsbreakdownmidnight_header
---@param optionName string
---@param columnName string
---@param value any
function breakdownMidnight.OnHeaderColumnOptionChanged(headerFrame, optionName, columnName, value)
    --placeholder for saving header column options
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
---@param sectionId string
---@param scrollFrame df_scrollbox
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

    header.ScrollOwner = scrollFrame
    header.WindowOwner = windowFrame
    header.sectionId = sectionId
    header:SetColumnSettingChangedCallback(breakdownMidnight.OnHeaderColumnOptionChanged)
    return header
end

---@param windowFrame detailsbreakdownmidnight_window
---@param sectionId string
---@param headerLabels string[]
function breakdownMidnight.UpdateSectionHeader(windowFrame, sectionId, headerLabels)
    local scrollFrame
    if (sectionId == "spells") then
        scrollFrame = windowFrame:GetSpellScroll()
    elseif (sectionId == "players") then
        scrollFrame = windowFrame:GetPlayerScroll()
    elseif (sectionId == "segments") then
        scrollFrame = windowFrame:GetSegmentScroll()
    elseif (sectionId == "spell_details") then
        scrollFrame = windowFrame:GetSpellDetailsScroll()
    elseif (sectionId == "targets") then
        scrollFrame = windowFrame:GetTargetsScroll()
    end

    if (not scrollFrame or not scrollFrame.Header) then
        return
    end

    local headerTable = buildHeaderTable(sectionId, headerLabels)
    scrollFrame.Header:SetHeaderTable(headerTable)
end
